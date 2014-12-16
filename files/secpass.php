<?php
// ----------------------------------------------------------------------
// <copyright file="secpass.php" company="Ahrenstein">
//     Copyright (c) 2014 Ahrenstein., All Rights Reserved.
//     Authors:
//          Matthew Ahrenstein 2014 @ahrenstein
// </copyright>
// Original code based on https://github.com/ahrensteinllc/SecurePassGenWeb
// ----------------------------------------------------------------------

      //This function converts a string to the sum of the ASCII values of each character in the string
      function stringToSeed($string)
      {
                  $seed = '';
                  $length = strlen($string);
                  for($i = 0; $i < $length; ++ $i)
                  {
                        $seed += ord($string{$i}); //Here I'm going through each part of the string and using ord to get each character's value, and add it to the seed
                  }
                  return (int) $seed; //Return the seed as an integer here
      }

      //This function performs the password generation algorithm. Sadly due to code level differences, it will not generate passwords that match the C# version
      function GenPass($sFQDN, $sSeedPhrase)
      {
            $sPasswordSeed = $sFQDN . $sSeedPhrase; //This sets the password seed we will use to generate the random number seed
            $sPassword = ""; //We will store the result here
            $upperDone = $lowerDone = $specialDone = $numberDone = false; //Set flags to determine if we have the required character types for the password complexity rules
            $iSeed = stringToSeed($sPasswordSeed); //Convert our password seed to an integer so we can seed the random number generator

            mt_srand($iSeed); //Seed the random number generator

            while (strlen($sPassword) < 8)
            {

                  $nextChar = chr(mt_rand(33,126));
                  if ($upperDone != true AND ctype_upper($nextChar) == true) //Make sure we have at least 1 upper case character
                  {
                        $sPassword .= $nextChar;
                        $upperDone = true;
                  }
                  elseif ($lowerDone != true AND ctype_lower($nextChar) == true) //Make sure we have at least 1 lower case character
                  {
                        $sPassword .= $nextChar;
                        $lowerDone = true;
                  }
                  elseif (strlen($sPassword) != 0 AND strlen($sPassword) <= 7) //This loop prevents the password from starting or ending in a number/symbol
                  {
                        if ($numberDone != true AND ctype_digit($nextChar) == true) //Make sure we have at least 1 numerical character
                        {
                              $sPassword .= $nextChar;
                              $numberDone = true;
                        }
                        elseif ($specialDone != true AND ctype_alnum($nextChar) == false) //Make sure we have at least 1 special character
                        {
                              $sPassword .= $nextChar;
                              $specialDone = true;
                        }
                  }
                  if (strlen($sPassword) == 7) //Forces the last character to be a letter of either case
                  {
                        $upperDone = false;
                        $lowerDone = false;
                  }
                  if ($upperDone AND $lowerDone AND $numberDone AND $specialDone) //Keeps us from running out of options until the loop hits 8 characters
                  {
                        $upperDone = $lowerDone = $numberDone = $specialDone = false;
                  }
            }
            return $sPassword;
      }

$serverFQDN = $argv[1]; //Get the FQDN from command line
$serverSeed = $argv[2]; //Get the seed from command line
$ptextPass = ""; //Variable for plaintext passwordi
$hashPass = ""; //Variable for the SHA-512 password for puppet to use
//The below if/else checks to make sure we have the correct amount of arguments
if (count($argv) == 3)
{
	$ptextPass = GenPass($serverFQDN, $serverSeed); //Generate the password from the CLI args
	$hashCommand = "/usr/bin/mkpasswd -m sha-512 -S iTFgQCF0 " . escapeshellarg ($ptextPass); //This creates a hash command and escapes the password which could contain ' or "
	$hashPass = exec("$hashCommand"); //This will perform the has command and store it in a variable to echo out for Facter
	echo $hashPass; //Echo the SHA-512 string of the password and it's salt out for use in puppet

}
else
{
	echo "Usage is: " . $argv[0] . " <server FQDN> <Secret Seed Phrase>";
		exit;
}

?>
