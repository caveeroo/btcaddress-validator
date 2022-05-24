#/bin/bash

while getopts u:a:f: flag
do
    case "${flag}" in
        a) btcaddress=${OPTARG};;
    esac
done
if [ -z "$btcaddress" ]
then
        read -p 'Btc address: ' btcaddress
fi

dir="$(mktemp)"

rm $dir && mkdir $dir

curl https://awebanalysis.com/en/bitcoin-address-validate/ -o $dir/result -c $dir/cookies.txt -s

token=$(grep 'token" content="' $dir/result > $dir/a && grep -oP 'content="\K\w+' -m1 $dir/a)

curl https://awebanalysis.com/en/bitcoin-address-validate/ -b $dir/cookies.txt -X POST -d '_token='"$token"'&btc_addr='"$btcaddress" -o $dir/result -s

grep "$btcaddress" $dir/result -A 10 > $dir/results

isitvalid=$(grep badge- $dir/results -A 1 > $dir/isitvalid && grep Add $dir/isitvalid | sed -e 's/^[ \t]*//')

hashtype=$(grep badge-secondary $dir/results > $dir/hashtype && grep -oP '">\K\w+.+?(?=</div)' $dir/hashtype)

linkblockchain="https://blockchain.info/address/$btcaddress"

echo "$isitvalid"
if [ "$isitvalid" = "Valid Bitcoin Address" ]; then
        echo "Address type: $hashtype"
        echo "Address info: $linkblockchain"
fi

rm -rf $dir