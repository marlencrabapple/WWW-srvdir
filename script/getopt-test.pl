#!/usr/bin/env perl
package getopt_test;

use v5.40;
use utf8;

$ENV{DEBUG} = 1;

use lib 'lib';

use WWW::srvdir::Base 'dmsg';
use Getopt::Long qw'GetOptionsFromArray :config  auto_abbrev';

our $aref = [];
our $_scalar = "";
our $scalar = \$_scalar;
our $scalar_str = $scalar;
our $scalar_num = $scalar;
our $href = { asdf => undef, fdsa => "$0" };

GetOptions( 'space-delim=s{1,}'  => $aref
	 ,  'single-arg=s'    => $scalar
	 ,  'int|single-int=i'    => $scalar_num
	 ,  'str|scalar|single-str=s'    => $scalar_str
	 ,  'key-value|kv=s%' => $href );

sub run {
  dmsg({'@ARGV' => \@ARGV, aref => $aref
		    , scalar => { 
			    any => $scalar
			  , str => $scalar_str
			  , num => $scalar_num }
		  , href => $href }
  );
}

run