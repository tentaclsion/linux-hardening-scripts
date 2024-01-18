#!/bin/bash
echo "How long is the phrase: "
read length
phrase=""
function chr {
    local c
    for c
    do
        printf "\\$((c/64*100+c%64/8*10+c%8))"
    done
}

for ((i=0;i<length*3;i++))
do
	ht=$(echo $((0 + RANDOM % 2)))
	bruh=$(echo $((0 + RANDOM % 122)))
	if [[ $ht == 0  ]]
	then
		phrase+=$(chr $bruh)
	else
		phrase+=$(chr $bruh)
	fi
done

echo $phrase 