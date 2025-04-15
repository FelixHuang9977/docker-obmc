#/bin/bash
mkdir -p build
. setup romulus build
rm tmp/deploy/images/romulus/obmc-phosphor-image*.mtd 
bitbake -c clean obmc-phosphor-image
bitbake obmc-phosphor-image
ls tmp/deploy/images/romulus/*.mtd && echo "build successfully." && exit 0
[[ $? -ne 0 ]] && echo "build failed in container, debug me!!!" && bash