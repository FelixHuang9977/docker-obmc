#!/bin/bash
#FEliX, this script is used to provide base port for qemu
#用工號尾2碼
declare -A gDictBasePort

gDictBasePort[felix]=9700  #felix:009977, ssh=9722, http=9780, https=9743
gDictBasePort[henry]=1000  #henry:832810, ssh=1022, http=1080, https=1043
gDictBasePort[elvis]=5000  #elvis:831250, ssh=5022, http=5080, https=5043
gDictBasePort[shane]=6500  #shane:832865, ssh=6522, http=6580, https=6543
gDictBasePort[yumi]=7600   #yumi:102376 , ssh=7622, http=7680, https=7643
gDictBasePort[kevin]=7000  #kevin:831570, ssh=7022, http=7080, https=7043

vUser=${1:-$(whoami)}
vBasePort=${gDictBasePort[$vUser]}

if [[ -z $vBasePort ]]; then
    echo "ERROR!!! cannot find baseport for current user: $vUser"
else
    echo $vBasePort
fi
