#/bin/bash

help()
{
   echo ""
   echo "Usage: $0 -p idPrefix -n idNum -s signer -d directory"
   echo "\t-p prefix of identities"
   echo "\t-n numbers of identities created under idPrefix"
   echo "\t-s signing identity"
   echo "\t-d directory to write ndncert files"
   echo "\t-h print this help message"
   exit 1
}

while getopts "p:n:s:d:" opt
do
   case "$opt" in
      p ) idPrefix="$OPTARG" ;;
      n ) idNum="$OPTARG" ;;
      s ) signer="$OPTARG" ;;
      d ) dir="$OPTARG" ;;
      h ) help ;;
      ? ) help ;;
   esac
done

echo "signer $signer"

if [ $# -le 3 ] 
then 
    help
    exit 1
fi

if [ ! -d "$dir" ]; then
    echo "creating $dir"
    mkdir $dir
fi

for i in `seq 1 $idNum`
do  
    identity=$idPrefix$i
    if ndnsec get-default -c -i $identity 2>/dev/null
    then
        echo "signing $identity with $signer"
        ndnsec sign-req $identity | ndnsec cert-gen -s $signer -i anchor - | ndnsec cert-install -
        ndnsec cert-dump -i $identity > $dir/signed-$i.ndncert
    fi
done