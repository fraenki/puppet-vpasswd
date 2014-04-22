# == Define Resource Type: vpasswd::file
#
# This type will create a passwd-like file.
#
# === Requirement/Dependencies:
#
# Currently requires the puppetlabs/concat and puppetlabs/stdlib module.
#
define vpasswd::file (
  # global configuration
  $hash         = undef,
  $parent_gid   = '0',
  $parent_shell = '/bin/sh',
  $parent_uid   = '0',
  # user settings
  $config       = {},
  $requires     = {},
  # file configuration
  $file         = undef,
  $flavour      = undef,
  $group        = 'root',
  $mode         = '0600',
  $owner        = 'root',
) {

  include stdlib

  validate_hash($config)
  validate_string($file)
  validate_absolute_path($file)
  validate_string($flavour)
  validate_hash($hash)

  # Title must not collide with our separator
  if $user =~ /.*\#.*/ {
    fail("vpasswd::file[${title}]: 'title' must not contain the '#' sign")
  }

  # Flavour tells us what the resulting file should look like
  # NOTE: Intentionally not checking the value of $flavour to support
  #       adding homebrew erb template files without changing any code.
  if $flavour == undef or size($flavour) < 1 {
    fail("vpasswd::file[${title}]: 'flavour' must be specified")
  }

  concat { $file:
    owner => $owner,
    group => $group,
    mode  => $mode,
  }

  # The $target file must never be empty, or we'll see concat errors.
  concat::fragment { "vpasswd::file header ${file}":
    target  => $file,
    order   => '10',
    content => template('vpasswd/header.erb'),
  }

  # Add a prefix to the username to prevent duplicate resource declarations.
  each($hash) |$user, $options| {
    # Username must not collide with our separator
    if $user =~ /.*\#.*/ {
      fail("vpasswd::file[${title}][${user}]: username must not contain the '#' sign")
    }

    # Instantiate user
    vpasswd::user { "${title}#${user}":
      # prevent duplicate resource declaration
      hash          => $options,
      # global configuration
      file          => $file,
      flavour       => $flavour,
      global_config => $config,
      parent_gid    => $parent_gid,
      parent_shell  => $parent_shell,
      parent_uid    => $parent_uid,
      requires      => $requires,
    }
  }

}
