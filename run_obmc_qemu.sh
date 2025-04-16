#!/bin/bash
[ ! -f qemu_get_base_port_by_user.sh ] && "Bad working folder, should be root folder of git project." && exit 2
vMyBasePort="$(./qemu_get_base_port_by_user.sh)"
[ -z $vMyBasePort ] && "Cannot find qemu port for you ($(whoami)). check qemu_get_base_port_by_user.sh. Quit." && exit 2

vMyQemuSshPort=$(( $vMyBasePort + 22 ))
vMyQemuHttpPort=$(( $vMyBasePort + 80 ))
vMyQemuHttpsPort=$(( $vMyBasePort + 43 ))
vMyQemuUdpPort=$(( $vMyBasePort + 23 ))
vMyRunningPid=$(ps -elf|grep qemu|awk "/:$vMyQemuSshPort/{print \$4}")
[[ ! -z $vMyRunningPid ]] && vMyRunningQemu=$(netstat -ntpave|grep ":$vMyQemuSshPort ")

vMyImage="openbmc/build/tmp/deploy/images/evb-ast2600/obmc-phosphor-image-evb-ast2600.static.mtd"

#for debug
for k in vMyBasePort vMyQemuSshPort vMyRunningPid vMyRunningQemu; do
    eval echo "$k=\$$k"
done

#kill exiting qemu
[[ ! -z $vMyRunningPid ]] && echo "kill exiting qemu pid=$vMyRunningPid...." && kill $vMyRunningPid && sleep 2

echo "Run qemu in background with $vMyImage"
nohup ./qemu-system-aarch64 -m 1024 -M ast2600-evb -nographic -smp 2 -drive file=${vMyImage},format=raw,if=mtd -net nic -net user,hostfwd=:0.0.0.0:${vMyQemuSshPort}-:22,hostfwd=:0.0.0.0:${vMyQemuHttpsPort}-:443,hostfwd=:0.0.0.0:${vMyQemuHttpPort}-:80,hostfwd=udp:0.0.0.0:${vMyQemuUdpPort}-:623,hostname=qemu 2>&1 > my_qemu.log &

sleep 1
vMyRunningPid=$(ps -elf|grep qemu|awk "/:$vMyQemuSshPort/{print \$4}")
echo "vMyRunningPid=$vMyRunningPid"
echo $vMyRunningPid > my_qemu.run

ls -l my_qemu.log
timeout 10 tail -f my_qemu.log

echo
echo "Run qemu in background with $vMyImage"
echo "  Image: $vMyImage"
echo "  Log:   my_qemu.log"
echo "  PID:   ${vMyRunningPid}"
echo "  SSH-PORT:    ${vMyQemuSshPort}"
echo "  HTTP-PORT:   ${vMyQemuHttpPort}"
echo "  HTTPS-PORT:  ${vMyQemuHttpsPort}"
echo

if [ -z "${vMyRunningPid}" ]; then
    echo "launch QEMU failed!!!"
    exit 2
else
    exit 0
fi
