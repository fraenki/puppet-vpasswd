# == Define Resource Type: vpasswd::user
#
# This type will create an entry in a passwd-like file.
#
# === Requirement/Dependencies:
#
# Currently requires the puppetlabs/concat and puppetlabs/stdlib module.
#
define vpasswd::user (
  # parent class / global configuration
  $file          = undef,
  $flavour       = undef,
  $parent_gid    = undef,
  $parent_shell  = undef,
  $parent_uid    = undef,
  $global_config = {},
  $requires      = {},
  # user attributes
  $comment       = 'puppet-managed user',
  $enabled       = true,
  $features      = {},
  $gid           = undef,
  $home          = undef,
  $maildir       = undef,
  $password      = '!',
  $settings      = {},
  $shell         = undef,
  $uid           = undef,
  # extended user settings
  $hash          = {}
) {

  include concat::setup
  include stdlib

  validate_hash($global_config)
  validate_hash($hash)

  # These checks are somewhat redundant if vpasswd::file is used too,
  # but they are required in any other case.
  unless $file {
    fail("vpasswd::user[${title}]: 'file' must be set")
  }
  unless $flavour {
    fail("vpasswd::user[${title}]: 'flavour' must be specified")
  }

  validate_absolute_path($file)

  # Evaluate user configuration
  $my_comment  = $hash['comment']  ? { undef  => $comment, default => $hash['comment'] }
  $my_enabled  = $hash['enabled']  ? { undef  => $enabled, default => $hash['enabled'] }
  $my_features = $hash['features'] ? { undef  => $features, default => $hash['features'] }
  $my_gid      = $hash['gid']      ? { undef  => $gid, default => $hash['gid'] }
  $my_home     = $hash['home']     ? { undef  => $home, default => $hash['home'] }
  $my_password = $hash['password'] ? { undef  => $password, default => $hash['password'] }
  $my_settings = $hash['settings'] ? { undef  => $settings, default => $hash['settings'] }
  $my_shell    = $hash['shell']    ? { undef  => $shell, default => $hash['shell'] }
  $my_uid      = $hash['uid']      ? { undef  => $uid, default => $hash['uid'] }

  # Validate data
  validate_hash($my_features)
  validate_hash($my_settings)

  # Extract real username
  $my_username = split($title, '#')[1]

  # Validate username
  if ( $my_username == undef or size($my_username) < 1 ) {
    fail("vpasswd::user[${title}]: failed to evaluate username")
  }

  # Try to auto-detect the password scheme
  case $my_password {
    /^\$1\$.*/:  { $my_password_scheme = 'MD5-CRYPT' }
    /^\$2a\$.*/: { $my_password_scheme = 'BLF-CRYPT' }
    /^\$5\$.*/:  { $my_password_scheme = 'SHA256-CRYPT' }
    /^\$6\$.*/:  { $my_password_scheme = 'SHA512-CRYPT' }
    default:     { $my_password_scheme = 'PLAIN' }
  }

  # Choose either global or user-specific configuration
  $global_alias_login_enabled = $global_config['alias_login_enabled']
  $alias_login_enabled = $my_settings['alias_login_enabled'] ? {
    undef   => $global_alias_login_enabled,
    default => $my_settings['alias_login_enabled'],
  }
  $mailbox_base = $global_config['mailbox_base'] ? {
    undef => '/var/mail',
    default => $global_config['mailbox_base'],
  }
  $user_maildir = $my_settings['maildir']
  $my_maildir = $my_settings['maildir'] ? {
    undef   => "${mailbox_base}/${my_username}",
    default => "${mailbox_base}/${user_maildir}",
  }
  $my_quota = $my_settings['quota'] ? {
    undef   => $global_config['quota'],
    default => $my_settings['quota'],
  }

  # Enable quota
  if ($global_config['quota_enabled'] != false
    and $settings['quota_enabled'] != false)
    and $my_quota != undef {
    $quota_enabled = true
  }
  else { $quota_enabled = false }

  # Check required feature
  $require_feature = $requires['feature']
  if $require_feature != undef and $my_features[$require_feature] != true {
    $force_disabled = true
  }

  # Final user validation
  if $force_disabled != true {
    # Add a fragement to the pool.
    concat::fragment { "vpasswd::user ${title}":
      target  => $file,
      order   => '20',
      content => template("vpasswd/${flavour}.erb"),
    }
  }

}
