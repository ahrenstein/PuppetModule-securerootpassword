# ----------------------------------------------------------------------
# <copyright file="init.pp" company="Ahrenstein">
#     Copyright (c) 2014 Ahrenstein., All Rights Reserved.
#     Authors:
#          Matthew Ahrenstein 2014 @ahrenstein
# </copyright>
# ----------------------------------------------------------------------

class securerootpassword (
    #This allows us to override the password. If it's not UNDEF when we start, then it ignores the fact/secpass script and uses what we gave it.
      $rootpassword = "UNDEF", #Must be generated via mkpasswd -m sha-512 -S SALT PASSWORD
      $serverSeed = "DEFAULT SEED" #This is the default seed. This must be changed in Hiera or your environment is essentially secured with a default password
) {

  #We need PHP-CLI for executing the secpass script
  package { 'Package-php5-cli':
    name   => 'php5-cli',
    ensure => latest,
  }

  #We need whois for the mkpasswd function used by the secpass script
  package { 'Package-whois':
    name   => 'whois',
    ensure => latest,
  }

  #Create the directory for secpass to work from
  file { 'Directory-autotools':
    ensure  => directory,
    path    => '/autotools',
    owner   => 'root',
    group   => 'root',
    mode    => 700,
    require => [ Package['Package-php5-cli'], Package['Package-whois']], #Don't bother with autotools if packages can't be installed
  }

  #Add the secpass script to the autotools directory
  file { 'File-secpass':
    ensure  => file,
    path    => '/autotools/secpass.php',
    owner   => 'root',
    group   => 'root',
    mode    => 600,
    source  => 'puppet:///modules/securerootpassword/secpass.php',
    require => File['Directory-autotools'], #Don't make the file without autotools directory existing
  }

  #Make sure 
  file { 'File-seedtxt':
    ensure  => file,
    path    => '/autotools/seed.txt',
    owner   => 'root',
    group   => 'root',
    mode    => 600,
    content => "$serverSeed", #Example seed string
    require => File['Directory-autotools'],
  }

  #This if block checks if $rootpassword is overridden by Hiera. If not, it uses the custom fact
  #If it is overridden just use the Hiera set password
  if $rootpassword == "UNDEF" {
    #This if block acts as a Try/Catch against secpass.php disappearing. This way the module
    #doesn't fail if puppet randomly decides to try setting the password and running the $spg_fact
    #before deploying the file
    if $spg_pass =~ /\:/ {
      notice ('ERROR: secpass.php is not available so we aren\'t touching the root password until the next puppet run!')
    }
    else {
      user { 'User-root':
        name     => 'root',
        ensure   => present,
        password => $spg_pass,
      }
    }
  }
  #If $rootpassword is defined in Hiera then we will use that variable instead.
  #This will happen even if secpass.php is missing since it isn't used here
  else {
    user { 'User-root':
      name     => 'root',
      ensure   => present,
      password => "$rootpassword",
    }
  }
}
