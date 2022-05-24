#/bin/bash

show_help () {
        echo "Btc address validator options: "
        echo
        echo "-a | --address    Provide a btc address to analyze"
        echo "-r | --report     Provide an abuse report of the specified address"
}

while :; do
        case "$1" in
                -h|-\?|--help)
                        show_help
                        exit
                        ;;
                -a|--address)
                        if [ "$2" ]; then
                                btcaddress=$2
                                shift
                        else
                                die 'ERROR: "--address" requires a non-empty address.'
                        fi
                        shift
                        ;;
                -r|--report)
                        abusereport="true"
                        shift
                        ;;
                *)
                        break
        esac
done

if [ -z "$btcaddress" ]
then
        read -p 'Btc address: ' btcaddress
fi

bold=$(tput bold)

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
        if [ "$abusereport" = "true" ]; then
                echo
                echo "Checking abuse reports"
                curl https://www.bitcoinabuse.com/reports/112FWGSL2q7rVTgabQuJbo3WwKid8dMEtj -o $dir/abusereport -s
                grep -oP '<td>.+' $dir/abusereport > $dir/relevantinfo
                reportcount=$(sed -n 2p $dir/relevantinfo | grep -oP 'td>\K\d+')
                echo
                echo '\033[1mThis address has been reported '"$reportcount" 'times\033[0m'
                echo "Printing all reports..."
                echo
                j=1
                for i in $(seq 4 $((($reportcount*3)+3)))
                do
                        if [ $((($i-4)%3)) = 0 ];then
                                echo "Report n$j"
                                j=$(($j+1))
                        fi
                        sed -n $(echo $i)p $dir/relevantinfo | sed -e 's/<[^>]*>//g'
                        echo
                done
        fi
fi

rm -rf $dir