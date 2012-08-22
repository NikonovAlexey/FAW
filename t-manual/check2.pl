#!/usr/bin/perl 
#===============================================================================
#
#         FILE: check2.pl
#
#        USAGE: ./check2.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 22.08.2012 21:17:57
#     REVISION: ---
#===============================================================================

use FAW::Roles;
use feature ':5.10';

my $role = "user";

my $fawrole = FAW::Roles->new();

say $fawrole->compare_roles($role, '');
