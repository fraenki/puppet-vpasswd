# == Define Resource Type: vpasswd::dovecot
#
# This is a shortcut for vpasswd::file to have some useful predefined settings.
#
define vpasswd::dovecot (
  # global configuration
  $hash                 = undef,
  $parent_gid           = undef,
  $parent_shell         = '/bin/sh',
  $parent_uid           = undef,
  # user configuration
  $alias_login_enabled  = true,
  $mailbox_base         = '/var/mail',
  $quota                = '1024M',
  $quota_enabled        = true,
  # file configuration
  $file                 = undef,
  $group                = 'dovecot',
  $mode                 = '0600',
  $owner                = 'dovecot',
) {

  # predefined configuration
  $flavour  = 'dovecot'
  $requires = { feature => 'mail' }

  if $file { $my_file = $file }
  else {
    case $::osfamily {
      'freebsd': {
        $my_file = '/usr/local/etc/dovecot/users'
      }
      default: {
        $my_file = '/etc/dovecot/users'
      }
    }
  }

  if $parent_gid { $my_parent_gid = $parent_gid }
  else {
    case $::osfamily {
      'debian':  { $my_parent_gid = '133' }
      'freebsd': { $my_parent_gid = '143' }
      'redhat':  { $my_parent_gid = '97' }
      default:   { $my_parent_gid = '0' }
    }
  }

  if $parent_uid { $my_parent_uid = $parent_uid }
  else {
    case $::osfamily {
      'debian':  { $my_parent_uid = '121' }
      'freebsd': { $my_parent_uid = '143' }
      'redhat':  { $my_parent_uid = '97' }
      default:   { $my_parent_uid = '0' }
    }
  }

  # Pass config values as hash to keep vpasswd::file simple.
  $config = {
    alias_login_enabled => $alias_login_enabled,
    mailbox_base        => $mailbox_base,
    quota               => $quota,
    quota_enabled       => $quota_enabled,
  }

  # Instantiate file
  vpasswd::file { $title:
    config       => $config,
    file         => $my_file,
    flavour      => $flavour,
    group        => $group,
    hash         => $hash,
    mode         => $mode,
    owner        => $owner,
    parent_gid   => $my_parent_gid,
    parent_shell => $parent_shell,
    parent_uid   => $my_parent_uid,
    requires     => $requires,
  }

}
