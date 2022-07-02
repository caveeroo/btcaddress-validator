# Btc address Validator
Fast Bitcoin Address Validator with awebanalysis.com and abuse reports generated by bitcoinabuse.com.

## Usage:

Pass the btc address you wanna check with the flag -a or execute the script and enter it.
It will provide awebanalysis.com info directly into your terminal.

```
git clone https://github.com/caveeroo/btcaddress-validator
cd btcaddress-validator
chmod +x btcvalidate.sh

./btcvalidate.sh -a <btc address>
```

## Abuse Report Collection

You can request abuse reports for the specified address with the ```-r``` flag:

```
./btcvalidate.sh -a <btc address> -r
```
