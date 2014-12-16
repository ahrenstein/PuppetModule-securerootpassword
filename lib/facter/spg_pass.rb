# ----------------------------------------------------------------------
# <copyright file="spg_pass.rb" company="Ahrenstein">
#     Copyright (c) 2014 Ahrenstein., All Rights Reserved.
#     Authors:
#          Matthew Ahrenstein 2014 @ahrenstein
# </copyright>
# ----------------------------------------------------------------------

#This fact executes a PHP script that this module deploys in order to generate the sha-512 password using our secret seed, and the server FQDN
#If this fact is run with the PHP script missing, the module will fail with an error
Facter.add('spg_pass') do
      setcode do
        Facter::Core::Execution.exec('/usr/bin/php /autotools/secpass.php `/usr/bin/facter fqdn` "secretseed"')
      end
    end
