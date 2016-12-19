#!/usr/bin/env perl

#: Wrapper around the aws cloudformation estimate-template-cost, to make it a bit easier to use


use strict 'vars';

my %parsed = &parseCommandLine();

#my $command = "aws cloudformation estimate-template-cost --template-body=file://" . $parsed[0] . " --parameters $parsed[1] $parsed[2]";
my $command = "aws cloudformation estimate-template-cost --template-body=file://" . $parsed{'file'} . " --parameters $parsed{'parameterString'} $parsed{'args'}";

print "Executing [$command]\n";
print `$command`;

######################################################
######################################################
######################################################
######################################################

##See usage. The format of the command line is:
## FILE (required)
## optionally followed by any number of key=value pairs
## optionally followed by any --OPTIONS to pass to the CLI
sub parseCommandLine
{
   ##Take the command line. There should be at least one arg (the cloud
   ##formation template to use). Die with a usage message if not present.
   my @args = @ARGV;
   my $file = shift @args or die &usage();

   ##Otherwise, if the specified template doesn't exist, say so and die.
   die("File [$file] does not exist.") if(! -e $file);
 
   ##Go through the rest of the command line 
   my $parameterString = '';

   #If there are any other arguments, process them.
   my $continue = 1;
   if(@args)
   {
      while($continue == 1)
      {
         ##Check to see that the args are not the "--" parameters to send to the CLI.
         if($args[0] !~ /^--/)
         {
           ##If they aren't, parse the key=value pairs to create the parameter string 
           ##which will be passed to the CLI.
           my $item = shift @args;
           my ($key,$value) = split /=/, $item;
           $parameterString .= "ParameterKey=$key,ParameterValue=$value ";
         }
         else
         {
           ##If they are "--" parameters, we're done trying to parse key=value pairs, 
           ##so get out of the loop.
           $continue = 0;
         }
      }
   } 

   ##Return all the values as a list which can (should) be used to initialize a hash.
   ##The hash will have keys "file", "parameterString", and "args", matching what was
   ##found through the parse.
    return ('file',$file,'parameterString',$parameterString,'args',@args);
}

sub usage
{
   print "$0 FILE [key1=value1 key2=value2 ... keyN=valueN] [--OPTIONS]\n";
   print       "\tFILE is the path to the cloud formation file.\n";
   print       "\tkeyN=valueN are pairs of cloudformation key/value parameters.\n";
   print       "\t--OPTIONS are any \"--\" options to send to the aws cli.\n";
}
