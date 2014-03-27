# == Define Resource Type: vpasswd::htpasswd
#
# This is a shortcut for vpasswd::file to have some useful predefined settings.
#
define vpasswd::htpasswd (
  # global configuration
  $hash         = undef,
  $parent_gid   = undef,
  $parent_shell = undef,
  $parent_uid   = undef,
  # file configuration
  $file         = undef,
  $group        = undef,
  $mode         = '0600',
  $owner        = undef,
) {

  # predefined configuration
  $flavour  = 'htpasswd'
  $requires = { feature => 'www' }

  if $file { $my_file = $file }
  else {
    case $::osfamily {
      'freebsd': { $my_file = '/usr/local/www/apache22/.htpasswd' }
      default:   { $my_file = '/var/www/.htpasswd' }
    }
  }

  if $group { $my_group = $group }
  else {
    case $::osfamily {
      'debian':  { $my_group = 'www-data' }
      'freebsd': { $my_group = 'www' }
      'redhat':  { $my_group = 'apache' }
      default:   { $my_group = 'root' }
    }
  }

  if $owner { $my_owner = $owner }
  else {
    case $::osfamily {
      'debian':  { $my_owner = 'www-data' }
      'freebsd': { $my_owner = 'www' }
      'redhat':  { $my_owner = 'apache' }
      default:   { $my_owner = 'root' }
    }
  }

  # Instantiate file
  vpasswd::file { $title:
    file         => $my_file,
    flavour      => $flavour,
    group        => $my_group,
    hash         => $hash,
    mode         => $mode,
    owner        => $my_owner,
    parent_gid   => $parent_gid,
    parent_shell => $parent_shell,
    parent_uid   => $parent_uid,
    requires     => $requires,
  }

}
