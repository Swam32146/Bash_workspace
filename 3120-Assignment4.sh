#! /bin/bash

capPercentage=60

emailAddress=()

emailFlag=""

capFlag=""

emailInputFlag="None"


while [ $# -gt 0 ] 
    do
    case $1 in
    -c)
        capFlag=1
        # IF the thing after -c is a number, then it will update capPercentage
        if [[ $2 =~ ^[0-9]+$ ]]; then
            # This shift kicks out the -c
            # So that the shift at the end of the case
            # Is still all good
            shift
            capPercentage=$1
        fi

        ;;
    "email-address")
        emailFlag=1
        # As this switch is at the end, I can assume that everything after is an email Addy

        ;;
    # Every last argument should be an email now,
    # so I will update emailInputFlag so that it 
    # says yes there was an email input, and will 
    # add the emails to the array
    *)
	emailInputFlag="Yes"
    emailAddress+="$1"
	;;
    esac
    shift
done

if [[ "$emailFlag" == "" || "$emailInputFlag" == "None" ]]; then
    echo -e "Please specify a email address\nUse this sytax:\nemail-address [email adresses seperated by whitespaces]" >&2 
    exit 1
fi


# Function send email
# param $1 = Subject Line, $2 = the line + header 
send_email()
    {
    for emailAddy in "${emailAddress[@]}"; do 
        # making sure there is a domain attatched
        if [[ "$emailAddy" != "*@*" ]]; then
            emailAddy+="@cyberserver.uml.edu"
        fi
        mailx -s "$1" "$emailAddy" <<< "$(echo -e "$2")"
    done
    }





# My stratyegy for this is as follows
# take stuff from the df command
# put each line in an array
# iterate through array, cutting the info i need
# if something bad
# echo "$dfHeader"
# echo  "${array[indx]}"

dfResult="$(df -k -t ext4 -t ext2)"

dfHeader="$(head -n 1 <<< "$dfResult")"

mapfile -t dfArray <<< "$dfResult"

# Removing the header
dfArray=("${dfArray[@]:1}")

for dfLine in "${dfArray[@]}"; do
    # I dont know why, but on the cyberserver 
    # its actually the 9th value and the 10 value for the mount
    # So I will jsut remove the extra spaces
    dfLine="$(echo "$dfLine" | tr -s ' ')"
    usageCheck="$(cut -d' ' -f5 <<< "$dfLine")"
    usageCheck=${usageCheck%\%}

    if [[ $usageCheck -ge $capPercentage ]]; then
        mountLocal="$(cut -d' ' -f6 <<< "$dfLine")"
        if [[ $usageCheck -ge 90 ]]; then
            subjectCritical="Critical Warning: the file system $mountLocal is greater than or equal to 90% capacity"
            messageToSend="$dfHeader\n$dfLine"
            send_email "$subjectCritical" "$messageToSend"
        else
            subjectUhOh="Warning: the file system $mountLocal is above ${capPercentage}% used"
            messageToSend="$dfHeader\n$dfLine"
            send_email "$subjectUhOh" "$messageToSend"
        fi
    fi
done

