# == Define Resource Type: vpasswd::proftpd
#
# This is a shortcut for vpasswd::file to have some useful predefined settings.
#
define vpasswd::proftpd (
  # global configuration
  $hash         = undef,
  $parent_gid   = undef,
  $parent_shell = '/bin/sh',
  $parent_uid   = undef,
  # file configuration
  $file         = undef,
  $group        = undef,
  $mode         = '0600',
  $owner        = 'root',
) {

  # predefined configuration
  $flavour  = 'proftpd'
  $requires = { feature => 'ftp' }

  if $file { $my_file = $file }
  else {
    case $::osfamily {
      'freebsd': {
        $my_file = '/usr/local/etc/proftpd/passwd'
      }
      default: {
        $my_file = '/etc/proftpd/passwd'
      }
    }
  }

  if $group { $my_group = $group }
  else {
    case $::osfamily {
      'freebsd': { $my_group = 'wheel' }
      default:   { $my_group = 'root' }
    }
  }

  if $parent_gid { $my_parent_gid = $parent_gid }
  else {
    case $::osfamily {
      'debian':  { $my_parent_gid = '65534' }
      'freebsd': { $my_parent_gid = '65534' }
      'redhat':  { $my_parent_gid = '99' }
      default:   { $my_parent_gid = '0' }
    }
  }

  if $parent_uid { $my_parent_uid = $parent_uid }
  else {
    case $::osfamily {
      'debian':  { $my_parent_uid = '123' }
      'freebsd': { $my_parent_uid = '65534' }
      'redhat':  { $my_parent_uid = '99' }
      default:   { $my_parent_uid = '0' }
    }
  }

  # Instantiate file
  vpasswd::file { $title:
    file         => $my_file,
    flavour      => $flavour,
    group        => $my_group,
    hash         => $hash,
    mode         => $mode,
    owner        => $owner,
    parent_gid   => $my_parent_gid,
    parent_shell => $parent_shell,
    parent_uid   => $my_parent_uid,
    requires     => $requires,
  }

}
