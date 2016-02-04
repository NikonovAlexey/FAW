#!/usr/bin/perl 
#===============================================================================
#
#         FILE: check.pl
#
#        USAGE: ./check.pl  
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
#      CREATED: 14.08.2012 11:05:36
#     REVISION: ---
#===============================================================================

use FindBin qw($Bin);
use lib "$Bin/../lib/";

use FAW::Form;
#use FAW::Element;
use feature ':5.10';

my $form = {
    action      => '/user/login',
    formname    => 'loginuser',
    fields      => [
        {
            type    => 'input', 
            name    => 'username',
            label   => 'login name:',
            note    => 'tell me your login.',
            error   => 'someone is wrong!!!',
            tooltip => 'enter your name',
        },
        {
            type    => 'password', 
            name    => 'password',
            label   => 'password:',
            note    => 'tell me your password.',
            error   => 'someone is wrong!!!',
            tooltip => 'enter your password',
        }
    ],
};

my $fawform = FAW::Form->new($form);
#my $faw = FAW::Element->new($el);
#say $faw->render_element;
#say $faw->render_js;
say $fawform->render_openform;
say $fawform->render_items;
say $fawform->render_closeform;

#$faw->type('simple');
