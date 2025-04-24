#!/bin/bash         

echo "starting function signature file"

rm -f -- ./functions.sig
rm -f -- ./errors.sig

echo "RHCertificatesFactory" >> functions.sig
abi2signature < ../abi/json/contracts/RHCertificatesFactory.sol/RHCertificatesFactory.json >> functions.sig 
echo "" >> functions.sig
echo "RHCertificateToken" >> functions.sig
abi2signature < ../abi/json/contracts/RHCertificateToken.sol/RHCertificateToken.json >> functions.sig 

#move errors in other file
sed -n '/error/p' functions.sig > errors.sig

# filter out repeated custom errors
gawk -i inplace '!seen[$0]++' errors.sig

# filter out custom errors
gawk -i inplace '!/error/' functions.sig

echo "end function signature file"