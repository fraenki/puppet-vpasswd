#vpasswd

##Table of Contents

- [Overview](#overview)
- [Module Description](#module-description)
- [Requirements](#requirements)
  - [Experimental Feature](#experimental-feature)
  - [Dependencies](#dependencies)
- [Usage](#usage)
  - [Setup HIERA: _Simple example (YAML)_](#setup-hiera-_simple-example-yaml_)
  - [Setup HIERA: _Complex example (YAML)_](#setup-hiera-_complex-example-yaml_)
  - [Basic Usage (Dovecot)](#basic-usage-dovecot)
  - [Basic Usage (ProFTPD)](#basic-usage-proftpd)
  - [Complex Example](#complex-example)
- [Reference](#reference)
  - [HIERA attribute reference](#hiera-attribute-reference)
  - [Module parameter reference](#module-parameter-reference)
  - [Performance](#performance)
  - [Iterations/Lambdas](#iterationslambdas)
- [Development](#development)

##Overview

This module manages virtual users and creates passwd-like files.

##Module Description

Virtual users are users not found in /etc/passwd. Many applications support virtual users for increased security. You will need to provide a file in passwd-like format. This module will create those files for you.

Features:

* Use HIERA to provide user data
* Choose from pre-defined schemes for Dovecot, ProFTPd and htpasswd (Apache)
* Drop your own schemes to the template directory

NOTE: To manage your mail environment - domains, addresses, routes, policies - you may want to checkout the _vmail_ module.

##Requirements

This module will not try to install packages or manage services. Its only purpose is to create files. All other things are up to you and probably other modules.

###Experimental Feature

This module requires iterations/lambdas. You need puppet 3.2+ and the future parser enabled in order to use this module.

###Dependencies

Currently requires the puppetlabs/concat and puppetlabs/stdlib module.
I recommend to use my _vmail_ module for mail domain and mail relay management.
Besides that _thias-postfix_ and _jproyo-dovecot_ are useful to manage the mail services.

##Usage

First, you need to define your users in HIERA. While this module tries to be as flexible as possible, it requires you to use the expected syntax.

###Setup HIERA: _Simple example (YAML)_

    virtual_accounts:
      john:
        comment: John Doe
        password: $1$LIq.MKZE$oYK01CVMjxPfBEicJDE9L1
        features:
          mail: true
      sue:
        comment: Sue Doe
        password: $1$LIq.MKZE$oYK01CVMjxPfBEicJDE9L1
        features:
          mail: true

###Setup HIERA: _Complex example (YAML)_

    virtual_accounts:
      john:
        comment: John Doe
        password: $1$LIq.MKZE$oYK01CVMjxPfBEicJDE9L1
        features:
          ftp: false
          mail: true
          www: false
        settings:
          aliases: [john.doe, jd]
          maildir: john_doe
          maildomains:
            company.com:
              aliases: [sales]
            example.com:
          quota: 1024M
      sue:
        comment: Sue Doe
        password: $1$LIq.MKZE$oYK01CVMjxPfBEicJDE9L1
        features:
          ftp: false
          mail: true
          www: false
        settings:
          aliases: [sue.doe, sd]
          maildir: sue_doe
          maildomains:
            company.com:
              aliases: [accounting, contact]
            example.com:
          quota: 1024M
      steve:
        comment: Steve Smith
        password: $1$LIq.MKZE$oYK01CVMjxPfBEicJDE9L1
        features:
          ftp: true
          mail: true
          www: true
        home: /stor/nfs/home/steve
        settings:
          aliases: [steve.smith, ss]
          maildir: service
          maildomains:
            company.com:
              aliases: [helpdesk, hostmaster, support]
          quota: 4096M

###Basic Usage (Dovecot)

The most basic, yet fully-working example for Dovecot:

    $virtual_accounts = hiera_hash('virtual_accounts')

    vpasswd::dovecot { 'my dovecot users':
      hash    => $virtual_accounts,
    }

This will create a passwd-like file in dovecot scheme with the following content:

    john@company.com:{MD5-CRYPT}$1$LIq.MKZE$oYK01CVMjxPfBEicJDE9L1:0:0::/var/mail/john::userdb_quota_rule=*:bytes=1024M
    john.doe@company.com:{MD5-CRYPT}$1$LIq.MKZE$oYK01CVMjxPfBEicJDE9L1:0:0::/var/mail/john::userdb_quota_rule=*:bytes=1024M
    jd@company.com:{MD5-CRYPT}$1$LIq.MKZE$oYK01CVMjxPfBEicJDE9L1:0:0::/var/mail/john::userdb_quota_rule=*:bytes=1024M
    sales@company.com:{MD5-CRYPT}$1$LIq.MKZE$oYK01CVMjxPfBEicJDE9L1:0:0::/var/mail/john::userdb_quota_rule=*:bytes=1024M
    (...)

###Basic Usage (ProFTPD)

A basic example for ProFTPD:

    $virtual_accounts = hiera_hash('virtual_accounts')

    vpasswd::proftpd { 'my proftpd users':
      hash    => $virtual_accounts,
    }

This will create a passwd-like file in ProFTPD scheme with the following content:

    john:$1$LIq.MKZE$oYK01CVMjxPfBEicJDE9L1:65534:65534:::/bin/sh
    sue:$1$LIq.MKZE$oYK01CVMjxPfBEicJDE9L1:65534:65534:::/bin/sh
    steve:$1$LIq.MKZE$oYK01CVMjxPfBEicJDE9L1:65534:65534::/stor/nfs/home/steve:/bin/sh

###Complex Example

You may want to customize the whole thing by adding your own template "flavour" to the module directory and use _vpasswd::file_ directly:

    $my_accounts = hiera_hash('my_accounts')

    vpasswd::file { 'MyApp passwd file':
      file       => '/etc/myapp.passwd',
      flavour    => 'myapp',
      group      => 'www',
      hash       => $my_accounts,
      owner      => 'www',
      requires   => { feature => 'myapp' },
    }

##Reference

###HIERA attribute reference

All currently supported attributes:

    virtual_accounts:
      john_doe:
        comment: John Doe
        password: $1$LIq.MKZE$oYK01CVMjxPfBEicJDE9L1
        features:
          ftp: false
          mail: true
          www: false
        home: /stor/nfs/home/john
        settings:
          aliases: [john.doe, jd]
          local_alias: john.doe
          maildir: john_doe/default
          maildomains:
            company.com:
              aliases: [sales]
            2ndcompany.com:
              username: ceo
              aliases: [contact, sales]
          quota: 1024M
          username: john.doe

###Module parameter reference

All currently supported parameters:

    vpasswd::dovecot { 'Dovecot passwd file':
      file         => '/foo/dovecot/users.passwd',
      flavour      => 'dovecot',
      group        => 'mail',
      hash         => $my_accounts,
      mailbox_base => '/foo/mail',
      owner        => 'mail',
      parent_gid   => '143',
      parent_uid   => '143',
      parent_shell => '/bin/sh',
      requires     => { feature => 'mail' },
    }

###Performance

This module does not scale well. The performance suffers from the _future parser_ and the large number of objects being created during a puppet run, or maybe it's the concat module. If you find a way to improve performance, please let me know.

30+ users:

    puppet-master[114547]: Compiled catalog in 2.44 seconds
    Notice: Finished catalog run in 2.38 seconds
    puppet agent --test --verbose  5.27s user 1.32s system 31% cpu 20.967 total

500+ users:

    puppet-master[10967]: Compiled catalog in 83.08 seconds
    Notice: Finished catalog run in 43.60 seconds
    puppet agent --test --verbose  95.35s user 13.63s system 17% cpu 10:34.92 total

In the latter case you want to set _configtimeout = 10m_.

###Iterations/Lambdas

Why does this module depend on experimental features like iterations/lambdas? I wanted to keep the defined types simple, but still make it possible to use the same user data multiple times (for multiple files, multiple applications). To avoid duplicate declarations I needed to use iterations (and unique names for every object, hence separators were born).

##Development

Please use the github issues functionality to report any bugs or requests for new features.
Feel free to fork and submit pull requests for potential contributions.
