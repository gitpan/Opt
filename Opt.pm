# Opt
# by Ramasubramanian, Balaji 2007.01.25 (Ver. 0.1.0)
# This program is ALPHA version
#
#Function GetOpt:
#================
# The function GetOpt is intended for use in getting the options specified at the command prompt and their values
# Author: Balaji Ramasubramanian <balaji.ramasubramanian@gmail.com>
# Version : 1.0
#
#Syntax:
#=======
#	$error, @values, @info = GetOpt(optionstring, rulestring, arglist)
#
# The optionstring and rulestring are being described here. 
#
#optionstring:
#=============
# The option string is a collection of option specifiers separated by commas. Leading spaces after commas are skipped. 
# Each option specifier is consisted of a list of option patterns and a datatype, separated by a colon (:). Two kinds of 
# datatypes are possible - b(oolean) and s(tring). The option patterns are separated by an or symbol (|). The option patterns
# are small words beginning with minus sign (-). The following are a few examples of option string:
#	"-help|h:b, -infile|-in:s, -outfile|-out:s"
# A boolean type has an implicit value of 1. In other words, the value of the boolean option need not be specified at the prompt. 
# The value of a string type needs to be specified. The value of a string may not start with -. 
# In both cases, default values can be specified in the option string. The default value has different meanings for the string 
# and the boolean type. In the string type, the default value is assumed if the option is not specified. In the boolean type however,
# the default value specified is the value returned into the variable, if the option is specified in the arguement list. For example,
# if an option specifier is
# 	"-max:b=10"
# then, the return value of this boolean will be 10 if specified, and 0 if unspecified at the command prompt. 
#
# Another example of the option string is
# 	"-skipExecution|skip:b, -file:s, -log:s=example.log"
#
#rulestring:
#===========
# The rule string is a collection of rules separated by commas. Leading spaces after commas are skipped. Each rule has two parts to it.
# 1. Rule name - one of xor, and, req
# 2. The arguement(s). req is the only rule that accepts a single arguement. The arguement(s) is/are the index of the option specified 
#    in the option string. The first option has an index of 1. 
#
# A description of the rules is given below:
#
#     Rule name            Function
#       xor                Exactly one of the options must be specified. If the option has a default value, it isn't
#       		   considered as specified, if the other is specified. Atleast one should be specified. If 
#       		   none of them is specified and if one has a default value, the default value is taken and
#       		   no error is flagged. If however, none have default values, then one of them must be
#       		   specified at the prompt. 
#       and		   Both of the options must be specified. If one of the options has a default value, the default
#       		   is taken. 
#       req		   This option is mandatory
#
# None of these rules is mandatory to specify. Multiple rules may be separated in a rule string by a comma. 
#
#Return values:
#==============
#Error:
#------
# GetOpt gets the values of the options according to the specifications and checks for rule conformance. It further checks if any
# option beyond the defined set is specified. In case the options specified donot conform to the rules or if any undefined
# option is specified, then the function returns an error, in the variable $error. The value will be either 0 for no error
# or -1 for errors. 
#Values:
#-------
# GetOpt returns the values of the options in the order of the option specifications. 
#Info:
#-----
# This section is important to understand. These return values of the GetOpt function can be used powerfully in any script. 
#
# These values indicate if the option has been exercised and if it has any value. Thus four possibilities emerge:
# 	Exercised	Value provided		Description
# 	   No			No		The option is not at all specified at the prompt. It does not have even a
# 	   					default value. 
# 	   No			Yes		This option is not specified in the prompt. The value returned in this case
# 	   					is the default value of this option. 
# 	   Yes			No		This is an erroneous use of the option at the prompt. The value of the option
# 	   					is not specified at the prompt. This will result in an error. 
# 	   Yes			Yes		This option is used in the prompt. Even if the default value is specified in the
# 	   					option string, the value specified at the prompt is returned. 
#
#Examples:
#=========
# In this section, we shall explore a few examples of the usage of this function in a script: 
# 
# 	my ($err, $help, $ffile, $sfile, @e) = &GetOpt("-help|-h:b, -ffile|-f:s=data, -sfile|-s:s", "xor 2 3", @ARGV);
# 	print "$err $help $ffile $sfile @e\n";
#
# At the command prompt, the above script try.pl:
#   % try.pl -help
#   0 1 0 0 3 0 0
#   % try.pl -f newdata
#   0 0 newdata 0 0 3 0
#   % try.pl -s otherdata
#   0 0 0 otherdata 0 0 3
#   % try.pl -f newdata -s otherdata
#   -1 0 newdata otherdata 0 3 3
#
#License and Bugs:
#=================
# This code is available under the GPL. For help, queries and bugs contact the author at balaji.ramasubramanian@gmail.com
#
#Further possible enhancements:
#==============================
# 1. It would be much better if a sort of a boolean expression of the options could be given in the rule string. However, 
#    that would be useful for very special cases and I shall not get into that for now. Instead, one could use the values
#    returned in the info for implementing such complex rules. The intent was to support some simple oft-used rules. 
#     
# 2. There should be an automatic help message generator. The option string and the rule string should be enough information
#    for the function to generate the help message. Again, I don't have time for this. It's not tough. The next release may 
#    have this feature. The problem with this feature is that if command-line arguments without options are to be specified, then
#    we cannot generate the help message. 
#
#
#
#
#
#
################################################END OF DOCUMENTATION##########################################################

package Opt;
use vars qw($VERSION);
$VERSION='0.1.1';

sub getOptValue {
	### Can have four possible values 
	#not sepecified - 0
	#default - 1
	#not valued - 2
	#specified - 3
	my $exists = 0; 
	my $retval = 0;
	my ($pattern, @A) = @_;
	
	### Separate the pattern into type and pattern string
	my ($patt,$type) = split /\:/, "$pattern";

	### Separate pattern string further if optional matches included
	my @patt = split /\|/, "$patt";

	### Set the default value
	if ($type =~ /\=/) {
		($type,$retval) = split /\=/, $type;
		$exists = 1;
	}
	for my $i (0..$#A) {
		### Check for each of the optional matches in the arguements
		for my $j (0..$#patt) {
			if (($A[$i] eq $patt[$j]) && ($type =~ /^s/) && ($i != $#A)) {
			### String types are followed by values
				$retval = $A[$i + 1]; $exists = 3; $i++;
			} elsif (($A[$i] eq $patt[$j]) && ($type =~ /^s/) && ($i == $#A)) {
				$exists = 2;
			} elsif (($A[$i] eq $patt[$j]) && ($type =~ /^b/)) {
			### Boolean types have an implicit value of 1 or the default value specified. 
				if (!$exists) {$retval = 1}; $exists = 3;
			}
		}
	}
	
	### Unspecified Boolean defaults removed
	if (($exists != 3) && ($type =~ /^b/)) {$retval = 0;}
	
	return ($exists, $retval);
}


sub optXOR {
	my $valid = 0;
	my ($rule, @e) = @_;
	my ($exc, $x, $y) = split /\s+/, $rule;
	if (((($e[$x-1] == 3) && ($e[$y-1]<=1)) xor (($e[$y-1] == 3) && ($e[$x-1]<=1))) xor ($e[$x-1]==1 || $e[$y-1]==1)) {
		$valid = 1;
	}
	return $valid;
}



sub optAND {
	my $valid = 0;
	my ($rule, @e) = @_;
	my ($and, $x, $y) = split /\s+/, $rule;
	if (($e[$x-1]==1 || $e[$x-1]==3) and ($e[$y-1]==1 || $e[$y-1]==3)) {
		$valid = 1;
	}
	return $valid;
}



sub optMandatory {
	my $valid = 0;
	my ($rule, @e) = @_;
	my ($mand, $x) = split /\s+/, $rule;
	if ($e[$x-1] == 3) {
		$valid = 1;
	}
	return $valid;
}


sub noOtherOpts {
	my ($A, @patt) = @_;
	my @p; my @A = split /\s/, $A;
	for my $pattern (@patt) {
		my ($p, $type) = split /\:/, $pattern;
		my @diff = split /\|/, $p;
		for my $x (@diff) {
			push @p, $x;
		}
	}

	$other = 0;
	for (my $i = 0; (($i <= $#A) && (!$other)); $i++) {
		$other = 0;
		if ($A[$i] =~ /^-/) {
			$found = 0;
			for (my $k = 0; (($k <= $#p) && (!$found)); $k++) {
				if ($A[$i] eq $p[$k]) {
					$found = 1;
				}
			}
			$other = !$found;
			if ($other) {
				print "Unknown option $A[$i]\n";
			}
		}
	}
	return !$other;
}


sub GetOpt {
	my ($pattList, $ruleList, @A) = @_;
	### Separate patterns commas. Leading spaces after commas are ignored
	my @patt = split (/\,\s*/, "$pattList");
	my (@e, @values);
	for my $i (0..$#patt) {
		($e[$i], $values[$i]) = &getOptValue($patt[$i], @A);
	}

	### Check for unvalued options
	my $follow = 1;
	for my $v (@e) {
		if ($v == 2) {$follow = 0;}
	}
	
	### Make checks on the option rules
	if ($follow) {
		my @rules = split (/\,\s*/, "$ruleList");
		for (my $i=0; ($i<=$#rules) && ($follow); $i++) {
			if ($rules[$i] =~ /^xor.*/) {
				$follow = &optXOR($rules[$i], @e);
			} elsif ($rules[$i] =~ /^req.*/) {
				$follow = &optMandatory($rules[$i], @e);
			} elsif ($rules[$i] =~ /^and.*/) {
				$follow = &optAND($rules[$i], @e);
			} else {
				die "Unknown rule \"$rules[$i]\". Aborting.\n";
			}
		}
	}

	### Check for any other options not defined
	if ($follow) {
		my $A = join ' ', @A;
		$follow = &noOtherOpts($A, @patt);
	}

	return ($follow-1, @values, @e);
}

1;
__END__

=head1 NAME

    Opt - Get command line options and their values

=head1 DESCRIPTION

    This module allows you to read command-line options and their values.

    This module can handle any command-line interface.

=head1 SYNOPSIS

    use Opt;
    use strict;

    my ($error, $opt1, $opt2, $opt3, @info) = &Opt::GetOpt("-opt1:b, -opt2:s=string2, -opt3:s", "req 1, xor 2 3", @ARGV);
    if ($error) {
        print "Errors detected in specifying options.\nUsage:<usage string>";
    } else {
        ### Rest of the code
	if ($opt1) {
	    if ($info[1]==1) {
	        ### If the value is a default value
		print "Default value for opt2 is taken\n";
	    } elsif ($info[1]==3) {
	        ### If the value is not default
		print "Non-default value as given = $opt2";
	    }
	}
    }

=head1 INSTALLATION

    The module can be installed using the standard Perl procedure:

        perl Makefile.PL
        make
        make test       # No tests defined in the version 0.1.1
        make install    # You may need to be root
        make clean      # or make realclean

    Windows users without a working "make" can get nmake from:
        ftp://ftp.microsoft.com/Softlib/MSLFILES/nmake15.exe

=head1 USAGE

    The Synopsis above gives an example of how to use the perl module and the function GetOpt.
    In addition, extensive documentation is provided in the perl module itself. 
    The perl module can be usually found in the path /usr/lib/perl/5.8/ or /usr/lib/perl/5.8.8/ etc.

=head1 VERSION

    This is the 0.1.1 version distribution of the Opt.pm module

=head1 AUTHOR

    Balaji Ramasubramanian (balaji.ramasubramanian@gmail.com)

=head1 SUPPORT

    Of course, I'll welcome e-mails.
    And now, I have a website. If you have a question or suggestion, 
    please let me know.

    http://balaji.ramasubramanian.googlepages.com/

