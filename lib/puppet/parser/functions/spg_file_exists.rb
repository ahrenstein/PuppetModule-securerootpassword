# ----------------------------------------------------------------------
# <copyright file="spg_file_exists.rb" company="Ahrenstein">
#     Copyright (c) 2014 Ahrenstein., All Rights Reserved.
#     Authors:
#          Matthew Ahrenstein 2014 @ahrenstein
# </copyright>
# ----------------------------------------------------------------------

#This fact checks if a file exists and returns 1 for true or 0 for false
#This fact is used by securerootpass to perform a sort of Try/Catch on changing the root password if the script used by the spg_pass fact is missing
require "puppet"
module Puppet::Parser::Functions
	newfunction(:spg_file_exists, :type => :rvalue) do |args|
		if File.exists?(args[0])
			return 1
		else
			return 0
		end
	end
end
