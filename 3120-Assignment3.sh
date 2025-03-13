#!/bin/bash

USAGE="$0 -f directory
$0 -d  directory
$0 -d -f directory

-f my_rename files 
-d my_rename directories 
"

usage ()
    {
    echo  "$USAGE"
    exit 1
    }

pathname ()
    {
    # function provided for the student
    echo  "${1%/*}"
    }

basename ()
    {
    # function provided for the student
    echo  "${1##*/}"
    }

find_dirs ()
    {
    # function provided for the student
    find "$1" -depth -type d -name '* *' -print
    }

find_files ()
    {
    # function provided for the student
    find "$1" -depth -type f -name '* *' -print
    }

my_rename()
    {
    # the student must implement this function to my_rename
    # $1 to $2
    # The following error checking must happen:
    #	1. check if the directory where $1 resided is writeable, 
    #      if not then report an error
    #	2. check if "$2" exists -if it does report and error and don't
    #      do the mv command
    #   3. check the status of the mv command and report any errors

    # Every function will only have a string pointing to a directory
    # I can use pathname / basename for the files name 

    


    # Setting this flag to 0 so it always starts at 0
    # if this becomes 1, then there is a second arg, and we need to not do the mv command
    exitCheck="0"

    ogPath=$(pathname "$1")

    # Check if the directory where $1 is Writeable
    # If the directory is ! NOT writeable, it will print the error to stderr
    if [[ ! -w "$ogPath" ]]; then
        echo "This directory $ogPath isnt writeable" >&2
    fi

    # Check if there is a $2
    if [[ -n "$2" ]]; then
        echo "This function only takes one argument" >&2
        exitCheck="1"
    fi

    # Here I baisicly have the last element in the directory path
    # Which is what i need to change
    toChangeName=$(basename "$1")

    # The new name needs to be toChangeName with whitespaces replaced by
    # dashes
    newName=$(echo "$toChangeName" | tr ' ' -)

    # Now we need to move toChangeName to newName
    # I can mv it with no problems because the depth option always makes sure I
    # move the ends first and then move closer to the root
    # I can use just variables for the move

    # I will set up the new path and old path

    newPath="$ogPath/$newName"

    # This can just be $1 , but for readability I want it to be clearly evident my train of thought.
    # We might have a problem here where I need to start with a directory that isnt going to be changed
    # So if ogPath is a directory that needs to be changed, then we got some problems
    # All my testing, I input the files, both, and dirs folder as the srguments and it worked
    
    oldPath="$ogPath/$toChangeName"

    if [[ ! "$exitCheck" == "1" ]]; then
        if mv "$oldPath" "$newPath"; then
            : # Workin
        else
            echo "mv failed: $?" >&2
        fi
    fi
    }

fix_dirs ()
    {
    # The student must implement this function
    # to actually call the my_rename funtion to 
    # change the name of the directory from having spaces to
    # changing all of the spaces to -'s
    # if the name were "a b", the new name would be a-b
    # if the name were "a   b" the new name would be a--b
    

    # The thing with these should be they pass the directory to find_dirs
    # find_dirs output should be mapped to an array
    
    dirsFound="$(find_dirs "$1")"

    mapfile -t dirArray <<< "$dirsFound"

    # The array gets iterated through and each value from the find_dirs 
    # command gets changed by its basename (IMPLEMENTED IN my_rename)
    for dirPath in "${dirArray[@]}"; do
        #here i call the my_rename function to do its thing with the path from the find_dirs function

        my_rename "$dirPath"
    done
    
    }

fix_files ()
    {
    # The student must implement this function
    # to actually call the my_rename funtion to 
    # change the name of the file from having spaces to
    # changing all of the spaces to -'s
    # if the name were "a b", the new name would be a-b
    # if the name were "a   b" the new name would be a--b


    # Logically copied from the fix_dirs function

    filesFound="$(find_files "$1")"

    mapfile -t fileArray <<< "$filesFound"

    for filePath in "${fileArray[@]}"; do
        my_rename "$filePath"
    done

    }

WFILE=
WDIR=
DIR=

if [ "$#" -eq 0 ]
   then
   usage
   fi

while [ $# -gt 0 ] 
    do
    case $1 in
    -d)
        WDIR=1
        ;;
    -f)
        WFILE=1
        ;;
    -*)
        usage 
        ;;
    *)
	if [ -d "$1" ]
	    then
	    DIR="$1"
	else
	    echo  "$1 does not exist ..."
	    exit 1
	    fi
	;;
    esac
    shift
    done

# The student must implement the following:
# - if the directory was not specified, the script should 
#   print a message and exit

# - if the Directory specified is the current directory, the script 
#   print a error message and exit

# - if the directory specified is . or .. the script should print
#   an error message and exit

# - if both -f and -d are not specified, the script should print a
#   message and exit
#

# This is a if block that will make sure there is a directory
# if $DIR is empty, it will exit and print a message
if [[ "$DIR" == "" ]]; then
    echo "Directory is not specified"
    exit 1
fi

# This is the block that determines if the Directory specified is the current directory
# If $DIR is . OR the expanded $PWD , OR .. it will print a message to stderr and stdout
# then exit
if [[ "$DIR" == "$PWD" || "$DIR" == "." || "$DIR" == ".." ]]; then
    pwdErrorMsg="You cannot use the current or previus directory"
    echo "$pwdErrorMsg" >&2
    exit 1
fi

# This checks if -f and -d are unspecified
# If WDIR AND WFILE is empty, then it exits
if [[ "$WDIR" == "" && "$WFILE" == "" ]]; then
    pwdErrorMsg="Please use a switch, like -f or -d, to use this script"
    echo  "$pwdErrorMsg" >&2
    exit 1
fi

# Working below this
if [ "$WDIR" -a "$WFILE" ]
    then
    fix_files "$DIR"
    fix_dirs "$DIR"
elif [ "$WDIR" ]
    then
    fix_dirs "$DIR"
elif [ "$WFILE" ]
    then
    fix_files "$DIR"
    fi
