#!/bin/bash
## This is the Parsing Process

## Set Colors
red='\e[1;31m%s\e[0m\n'
green='\e[1;32m%s\e[0m\n'
yellow='\e[1;33m%s\e[0m\n'
blue='\e[1;34m%s\e[0m\n'
magenta='\e[1;35m%s\e[0m\n'
cyan='\e[1;36m%s\e[0m\n'

## Set File Directory
FILES=/etc/piholeparser/lists/*.lst

## Start File Loop
for f in $FILES
do

echo ""
printf "$blue"    "___________________________________________________________"
echo ""
printf "$green"   "Processing list from $f"

for source in `cat $f`;
do
echo ""
printf "$cyan"    "$source"
sudo curl --silent $source >> "$f".ads.txt
echo -e "\t`wc -l "$f".ads.txt | cut -d " " -f 1` lines downloaded"
done

## Filter
printf "$yellow"  "Filtering non-url content..."
sudo perl /etc/piholeparser/parser.pl "$f".ads.txt > "$f".ads_parsed.txt
echo -e "\t`wc -l "$f".ads_parsed.txt | cut -d " " -f 1` lines after parsing"

## Duplicate Removal
printf "$yellow"  "Removing duplicates..."
sort -u "$f".ads_parsed.txt > "$f".ads_unique.txt
sudo rm "$f".ads_parsed.txt
echo -e "\t`wc -l "$f".ads_unique.txt | cut -d " " -f 1` lines after deduping"
sudo cat "$f".ads_unique.txt >> "$f".txt
sudo rm "$f".ads_unique.txt

## Remove Empty Files
if 
[ -s "$f".txt ]
then
echo ""
printf "$yellow"  "File will be moved to the parsed directory."
sudo mv "$f".txt /etc/piholeparser/parsed/
sudo rename "s/.lst.txt/.txt/" /etc/piholeparser/parsed/*.txt
else
echo ""
printf "$red"     "File Empty. It will be deleted."
rm -rf "$f".txt
fi

## Create Mirrors
if 
test $(stat -c%s "$f".ads.txt) -ge 100000000
then
echo ""
printf "$red"     "Mirror File Too Large For Github. Deleting."
sudo rm "$f".ads.txt
else
echo ""
printf "$yellow"  "Creating Mirror of Unparsed File."
sudo mv "$f".ads.txt /etc/piholeparser/mirroredlists/
sudo rename "s/.lst.ads.txt/.txt/" /etc/piholeparser/mirroredlists/*.txt
fi

echo ""
printf "$magenta" "___________________________________________________________"
echo ""

## End File Loop
done
