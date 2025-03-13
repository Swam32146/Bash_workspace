#! /bin/bash
# I am probably using more variables then i should be, but for readability this works for me
rawInput="$@"

# This massages the input to all be colon seperated

# TODO \\ maybe handle PATHS with spaces in them.
# Is that possible?

noSpaceInput=$(echo "$rawInput" | sed 's/ /:/g')


# This makes sure that :: is always expanded to :.:
middleDotInput=$(echo "$noSpaceInput" | sed 's/::/:.:/g')

#These are to handle the .: and :. situations
firstChar="${middleDotInput:0:1}"
lastChar="${middleDotInput: -1}"

finalInput="$middleDotInput"

# By initilizing finalInput first, I can presort the . by having final input always have the first instance of . , unless theres a ::
if [[ "$lastChar" == ':' ]]; then
    finalInput+='.'
fi

if [[ "$firstChar" == ':' ]]; then
    finalInput=".$middleDotInput"
fi

# This formats it in a way I can iterate over

IFS=: read -ra ifsInput <<< "$finalInput"

# I wanted to initialize outside the loop to make sure that both of these variables are empty
finalList=''
checkList=()
for element in "${ifsInput[@]}"; do

    # This if statement alwasy makes sure that the elemnt im adding to the last list is the only one there
    # I had some issues with trying to have the wildcards on the left side.
    if [[ ! "${checkList[@]}" == *"$element"* ]]; then
        finalList+="$element:"
        checkList+=("$element")
    fi
done

# After the for loop there should always be a : because of the way I append stuff, so this is just a precaution
if [[ "${finalList: -1}" == ':' ]]; then
    finalList="${finalList%?}"
fi

echo "$finalList"

# I think this might have a problem with arguments that have a space in them, but the standard IFS is a tab or a space, so if your path has a space that sounds like a you problem.
# Hopefully no one has a path that has a IFS of a whitespace
