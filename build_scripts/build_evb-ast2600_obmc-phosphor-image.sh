#/bin/bash
mkdir -p build
. setup evb-ast2600 build
#rm tmp/deploy/images/evb-ast2600/*.mtd 
bitbake -c clean obmc-phosphor-image
bitbake obmc-phosphor-image
ls -l tmp/deploy/images/evb-ast2600/*.mtd && exit 0
[[ $? -ne 0 ]] && echo "build failed in container, debug me!!!" && bash