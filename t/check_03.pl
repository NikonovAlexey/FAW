#!/usr/bin/perl 
#===============================================================================
#
#         FILE: check.pl
#
#        USAGE: ./check.pl  
#
#  DESCRIPTION: check uRBAC module
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 27.05.2014 21:43:03
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More qw(no_plan);
use FindBin qw($Bin);
use lib "$Bin/../lib/";

BEGIN { use_ok('FAW::uRoles'); }
require_ok( 'FAW::uRoles' );

my $faw = FAW::uRoles->new();
my $user = "";
my $role = "";
my $role2= "";

diag( "Работа с ресурсом: одна роль, максимум привилегий, неявное указание действий доступа, доступ для всех" );
$user = "admin";
$role = "all";
cmp_ok($faw->check_role($user, "post",   $role), "==", 0, "$user обновляет данные указанного ресурса");
cmp_ok($faw->check_role($user, "get",    $role), "==", 0, "$user читает данные указанного ресурса");
cmp_ok($faw->check_role($user, "put",    $role), "==", 0, "$user создаёт новый ресурс указанного типа");
cmp_ok($faw->check_role($user, "delete", $role), "==", 0, "$user удаляет указанный ресурс");
cmp_ok($faw->check_role($user, "other",  $role), "==", 5, "$user запрашивает нетипичное действие");

diag( "Работа с ресурсом: одна роль, максимум привилегий, неявное указание действий доступа, доступ для всех" );
$role = "any";
cmp_ok($faw->check_role($user, "post",   $role), "==", 0, "$user обновляет данные указанного ресурса");
cmp_ok($faw->check_role($user, "get",    $role), "==", 0, "$user читает данные указанного ресурса");
cmp_ok($faw->check_role($user, "put",    $role), "==", 0, "$user создаёт новый ресурс указанного типа");
cmp_ok($faw->check_role($user, "delete", $role), "==", 0, "$user удаляет указанный ресурс");
cmp_ok($faw->check_role($user, "other",  $role), "==", 5, "$user запрашивает нетипичное действие");

diag( "Работа с ресурсом: одна роль, типичные привилегии, неявное указание действий доступа, доступ для всех" );
$user = "manager";
cmp_ok($faw->check_role($user, "post",   $role), "==", 0, "$user обновляет данные указанного ресурса");
cmp_ok($faw->check_role($user, "get",    $role), "==", 0, "$user читает данные указанного ресурса");
cmp_ok($faw->check_role($user, "put",    $role), "==", 0, "$user создаёт новый ресурс указанного типа");
cmp_ok($faw->check_role($user, "delete", $role), "==", 0, "$user удаляет указанный ресурс");
cmp_ok($faw->check_role($user, "other",  $role), "==", 5, "$user запрашивает нетипичное действие");

diag( "Работа с ресурсом: одна роль, ГОСТЬ, неявное указание действий доступа, доступ для всех" );
$user = "guest";
cmp_ok($faw->check_role($user, "post",   $role), "==", 0, "$user обновляет данные указанного ресурса");
cmp_ok($faw->check_role($user, "get",    $role), "==", 0, "$user читает данные указанного ресурса");
cmp_ok($faw->check_role($user, "put",    $role), "==", 0, "$user создаёт новый ресурс указанного типа");
cmp_ok($faw->check_role($user, "delete", $role), "==", 0, "$user удаляет указанный ресурс");
cmp_ok($faw->check_role($user, "other",  $role), "==", 5, "$user запрашивает нетипичное действие");

diag( "Работа с ресурсом: одна роль, некорректные привилегии, неявное указание действий доступа, доступ для всех" );
$user = "any";
cmp_ok($faw->check_role($user, "post",   $role), "==", 4, "$user обновляет данные указанного ресурса");
cmp_ok($faw->check_role($user, "get",    $role), "==", 4, "$user читает данные указанного ресурса");
cmp_ok($faw->check_role($user, "put",    $role), "==", 4, "$user создаёт новый ресурс указанного типа");
cmp_ok($faw->check_role($user, "delete", $role), "==", 4, "$user удаляет указанный ресурс");
cmp_ok($faw->check_role($user, "other",  $role), "==", 4, "$user запрашивает нетипичное действие");

diag( "Работа с ресурсом: одна роль, ГОСТЬ, неявное указание действий доступа, роли НЕ совпадают" );
$user = "guest";
$role = "admin";
cmp_ok($faw->check_role($user, "post",   $role), "==", 1, "$user обновляет данные указанного ресурса");
cmp_ok($faw->check_role($user, "get",    $role), "==", 1, "$user читает данные указанного ресурса");
cmp_ok($faw->check_role($user, "put",    $role), "==", 1, "$user создаёт новый ресурс указанного типа");
cmp_ok($faw->check_role($user, "delete", $role), "==", 1, "$user удаляет указанный ресурс");
cmp_ok($faw->check_role($user, "other",  $role), "==", 5, "$user запрашивает нетипичное действие");

diag( "Работа с ресурсом: одна роль, типичные привилегии, неявное указание действий доступа, роли НЕ совпадают" );
$user = "manager";
cmp_ok($faw->check_role($user, "post",   $role), "==", 1, "$user обновляет данные указанного ресурса");
cmp_ok($faw->check_role($user, "get",    $role), "==", 1, "$user читает данные указанного ресурса");
cmp_ok($faw->check_role($user, "put",    $role), "==", 1, "$user создаёт новый ресурс указанного типа");
cmp_ok($faw->check_role($user, "delete", $role), "==", 1, "$user удаляет указанный ресурс");

diag( "Работа с ресурсом: одна роль, привилегии совпадают, явное указание действий доступа" );
$user = "admin";
$role = "admin";
cmp_ok($faw->check_role($user, "post",   "$role+crd"),  "==", 3, "$user обновляет данные указанного ресурса: прав нет");
cmp_ok($faw->check_role($user, "post",   "$role+crud"), "==", 0, "$user обновляет данные указанного ресурса: права есть");
cmp_ok($faw->check_role($user, "get",    "$role+cud"),  "==", 3, "$user читает данные указанного ресурса: прав нет");
cmp_ok($faw->check_role($user, "get",    "$role+crud"), "==", 0, "$user читает данные указанного ресурса: права есть");
cmp_ok($faw->check_role($user, "put",    "$role+rud"),  "==", 3, "$user создаёт новый ресурс указанного типа: прав нет");
cmp_ok($faw->check_role($user, "put",    "$role+crud"), "==", 0, "$user создаёт новый ресурс указанного типа: права есть");
cmp_ok($faw->check_role($user, "delete", "$role+cru"),  "==", 3, "$user удаляет указанный ресурс: прав нет");
cmp_ok($faw->check_role($user, "delete", "$role+crud"), "==", 0, "$user удаляет указанный ресурс: права есть");

diag( "Работа с ресурсом: максимальные права, несколько ролей для действия, явное указание действий доступа для своей роли" );
$user = "admin";
$role = "admin";
$role2= "manager";
cmp_ok($faw->check_role($user, "post",   "$role+crd $role2"),  "==", 3, "$user обновляет данные указанного ресурса: прав нет");
cmp_ok($faw->check_role($user, "post",   "$role+crud $role2"), "==", 0, "$user обновляет данные указанного ресурса: права есть");
cmp_ok($faw->check_role($user, "get",    "$role+cud $role2"),  "==", 3, "$user читает данные указанного ресурса: прав нет");
cmp_ok($faw->check_role($user, "get",    "$role+crud $role2"), "==", 0, "$user читает данные указанного ресурса: права есть");
cmp_ok($faw->check_role($user, "put",    "$role+rud $role2"),  "==", 3, "$user создаёт новый ресурс указанного типа: прав нет");
cmp_ok($faw->check_role($user, "put",    "$role+crud $role2"), "==", 0, "$user создаёт новый ресурс указанного типа: права есть");
cmp_ok($faw->check_role($user, "delete", "$role+cru $role2"),  "==", 3, "$user удаляет указанный ресурс: прав нет");
cmp_ok($faw->check_role($user, "delete", "$role+crud $role2"), "==", 0, "$user удаляет указанный ресурс: права есть");

diag( "Работа с ресурсом: максимальные права, несколько ролей для действия, явное указание действий доступа для другой роли" );
$user = "admin";
$role = "manager";
$role2= "admin";
cmp_ok($faw->check_role($user, "post",   "$role+crd $role2"),  "==", 0, "$user обновляет данные указанного ресурса: прав у $role нет, у $role2 - есть");
cmp_ok($faw->check_role($user, "get",    "$role+cud $role2"),  "==", 0, "$user читает данные указанного ресурса: прав у $role нет, у $role2 - есть");
cmp_ok($faw->check_role($user, "put",    "$role+rud $role2"),  "==", 0, "$user создаёт новый ресурс указанного типа: прав у $role нет, у $role2 - есть");
cmp_ok($faw->check_role($user, "delete", "$role+cru $role2"),  "==", 0, "$user удаляет указанный ресурс: прав у $role нет, у $role2 - есть");
cmp_ok($faw->check_role($user, "delete", "$role+cru,$role2"),  "==", 6, "роли в списке перечислены некорректно");

diag( "Сложные ситуации: несколько ролей пользователя, одна явно указанная роль ресурса" );
$user = "admin manager";
$role = "admin";
cmp_ok($faw->check_role($user, "post",   "$role"),  "==", 0, "$user обновляет данные указанного ресурса: одна из ролей пользователя есть в списке");
cmp_ok($faw->check_role($user, "get",    "$role"),  "==", 0, "$user читает данные указанного ресурса: одна из ролей пользователя есть в списке");
cmp_ok($faw->check_role($user, "delete",    "admin+cru manager+crud"),  "==", 0, "$user читает данные указанного ресурса: одна из ролей пользователя есть в списке");
cmp_ok($faw->check_role($user, "delete",    "admin+crud manager+cru"),  "==", 0, "$user читает данные указанного ресурса: одна из ролей пользователя есть в списке");

# TODO: настроить проверку различных ролей;
# TODO: проверить случаи инвертирования ролей;

diag( "Проверки окончены" );

1;
