# /bin/bash

for i in $(ls ../contracts | grep .sol);do solc ../contracts/$i --bin --abi --optimize --overwrite -o ../compiled/;done
for i in $(ls ../contracts/trash | grep .sol);do solc ../contracts/trash/$i --bin --abi --optimize --overwrite -o ../compiled/;done