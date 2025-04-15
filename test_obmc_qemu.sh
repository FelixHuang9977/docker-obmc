#!/bin/bash
[ ! -f lib_fx_expect.sh ] && "Cannot find lib_fx_expect.sh, make setup first." && exit 2
source lib_fx_expect.sh

[ ! -f qemu_get_base_port_by_user.sh ] && "Bad working folder, should be root folder of git project." && exit 2
vMyBasePort="$(./qemu_get_base_port_by_user.sh)"
[ -z $vMyBasePort ] && "Cannot find qemu port for you ($(whoami)). check qemu_get_base_port_by_user.sh. Quit." && exit 2
vMyQemuSshPort=$(( $vMyBasePort + 22 ))
vMyQemuHttpPort=$(( $vMyBasePort + 80 ))
vMyQemuHttpsPort=$(( $vMyBasePort + 43 ))
vMyQemuUdpPort=$(( $vMyBasePort + 23 ))
vMyRunningPid=$(ps -elf|grep qemu|awk "/:$vMyQemuSshPort/{print \$4}")

FX_SET_TIMEOUT 400
FX_SPAWN ssh -o StrictHostKeyChecking=accept-new -p $vMyQemuSshPort root@127.0.0.1
FX_WISH "password:"
FX_SEND "0penBmc\n"
FX_SEND "ip ro\nhostname\n"
FX_WISH "evb-ast2600"
FX_RUN


