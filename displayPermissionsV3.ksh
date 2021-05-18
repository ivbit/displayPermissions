#!/bin/ksh

# Intellectual property information START
# 
# Copyright (c) 2020 Ivan Bityutskiy 
# 
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
# 
# Intellectual property information END

# Description START
#
# The script displays permissions
# for umask, provided by user.
# If -c option is specified,
# the script uses current system's umask.
#
# Description END

# Define functions START
function syntax
{
  print -u2 -- "\nUsage:
    ./${1##*/} -h
    \tto print this help
    ./${1##*/} -c
    \tto display permissions for current system's umask\n
    Enter octal umask value, from one to three digits.
    ./${1##*/} <numeric umask value>
    \tor
    ./${1##*/}
    enter <numeric umask value> at the prompt.\n"
  exit 1
}

function makeResult
{
  local -i counter=9
  local -i2 binaryPermissions=$1
  local wall=''
  result=''
  binResult=''
  while (( counter >= 1 ))
  do
    wall=''
    [[ $counter == [47] ]] && wall=' | '
    if (( binaryPermissions & 1 ))
    then
      binResult="${wall}1$binResult"
      result="$wall${arrSymbols[counter]}$result"
    else
      binResult="${wall}0$binResult"
      result="${wall}-$result"
    fi
    (( counter--,
       binaryPermissions >>= 1 ))
  done
  binResult="| $binResult |\n"
  result="| $result |\n"
}
# Define functions END

# Declare variables START
typeset -Z3 formattedUserInput
typeset -Z3 currentUmask
typeset -i8 fileModifier=8#666
typeset -i8 dirModifier=8#777
typeset -i8 twosCompliment 
typeset -i8 filePermissions
typeset -i2 filePermissionsBinary
typeset -i8 dirPermissions
typeset -i2 dirPermissionsBinary
typeset -Z3 filePermissionsDisplay
typeset -Z9 filePermissionsBinaryDisplay
typeset -Z3 dirPermissionsDisplay
typeset -Z9 dirPermissionsBinaryDisplay
typeset arrSymbols
arrSymbols[1]='r'
arrSymbols[2]='w'
arrSymbols[3]='x'
arrSymbols[4]='r'
arrSymbols[5]='w'
arrSymbols[6]='x'
arrSymbols[7]='r'
arrSymbols[8]='w'
arrSymbols[9]='x'
typeset ugo="|  u  |  g  |  o  |\n"
typeset binResult=''
typeset result=''
# Declare variables END

# Get the options START 
if (( $# ))
then
  while getopts :hc anOption
  do
    (( ${#1} != 2 )) && syntax $0
    case $anOption in
      h)
        syntax $0
        ;;
      c)
        (( $# > 1 )) && syntax $0
        currentUmask=$(umask)
        ;;
     \?)
       syntax $0
       ;;
    esac
  done
  shift 'OPTIND - 1'
fi
# Get the options END

# If script has arguments START
(( $# > 1 )) && syntax $0
if (( $# == 1 ))
then
  formattedUserInput="$1"
  [[ "$formattedUserInput" != +([0-7]) ]] && syntax $0
fi
# If script has arguments END

# Getting the umask value START
if (( currentUmask ))
then
  formattedUserInput=$currentUmask
else
  if (( ! formattedUserInput ))
  then
    read -- inputUmask?"Enter umask, $LOGNAME: "
    formattedUserInput="$inputUmask"
    [[ "$formattedUserInput" != +([0-7]) ]] && syntax $0
  fi
fi
# Getting the umask value END

# Calculating permissions START
(( twosCompliment=~8#$formattedUserInput ))
(( filePermissions=fileModifier&twosCompliment ))
filePermissionsBinary=$filePermissions
(( dirPermissions=dirModifier&twosCompliment ))
dirPermissionsBinary=$dirPermissions
# Calculating permissions END

# Displaying result START
filePermissionsDisplay=${filePermissions#*#}
filePermissionsBinaryDisplay=${filePermissionsBinary#*#}
dirPermissionsDisplay=${dirPermissions#*#}
dirPermissionsBinaryDisplay=${dirPermissionsBinary#*#}

makeResult $filePermissionsBinary
print -- "\nRegular file permissions\n\twith umask ($formattedUserInput):"
print -- "Octal: $filePermissionsDisplay"
print -- "Binary: $filePermissionsBinaryDisplay"
print -- "$ugo$binResult$result"

makeResult $dirPermissionsBinary
print -- "Directory file permissions\n\twith umask ($formattedUserInput):"
print -- "Octal: $dirPermissionsDisplay"
print -- "Binary: $dirPermissionsBinaryDisplay"
print -- "$ugo$binResult$result"
# Displaying result END

# END OF SCRIPT

