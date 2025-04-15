#FEliX
dockimage_obmcbuilder=$(shell docker image ls | grep -o obmcbuilder)

help:
	echo "setup     #setup env"
	echo "pull 	    #get openbmc 2.14.0 source code to local"
	echo "build     #build obmc-phosphor image"
	echo "qemu      #kill old qemu and re-launch it with openbmc/build/evb-ast2600/tmp/deploy/images/evb-ast2600/*.mtd"

pull:
	-git clone --single-branch --branch=2.14.0 https://github.com/openbmc/openbmc.git
	-git clone --single-branch --branch=2.14.0 https://github.com/openbmc/openbmc.git openbmc_orig_2.14.0

check:
	echo "dockimage_obmcbuilder=$(dockimage_obmcbuilder)"

build_container:
	@echo "dockimage_obmcbuilder=$(dockimage_obmcbuilder)"
	@if [ -z "$(dockimage_obmcbuilder)" ]; then \
	      	echo "golden obmcbuilder not exist! going to build" ;\
			docker build --build-arg userid=$(shell id -u) --build-arg groupid=$(shell id -g) --build-arg username=$(shell id -un) --tag obmcbuilder:latest . ;\
	   else \
	      	echo "golden obmcbuilder exist." ;\
			echo "skip build obmcbuilder container image." ;\
	   fi

build_openbmc: build_container
	if [ -z "$(shell docker ps | grep -o felix_obmcbuilder)" ]; then \
			echo "container is not running, try to launch...." ;\
			chmod +x entrycontainer ;\
			./entrycontainer bash /build_scripts/build_obmc-phosphor-image.sh ;\
		else \
			echo "(container is running, use exec -it)" ;\
			docker inspect felix_obmcbuilder |sed -n '/Mounts/,/Config/{p}' ;\
			docker exec -it --user 1010 felix_obmcbuilder bash /build_scripts/build_obmc-phosphor-image.sh ;\
		fi
			
entrycontainer: enter_container

enter_container:
	if [ -z "$(shell docker ps | grep -o felix_obmcbuilder)" ]; then \
			echo "container is not running, try to launch...." ;\
			make launch_container ;\
		else \
			echo "(container is running, use exec -it)" ;\
			docker exec -it felix_obmcbuilder /bin/bash  ;\
		fi

launch_container:
	@echo "Launching obmcbuilder for $(shell whoami)..."
	@echo " mount in obmcbuilder container:"
	@echo "   /home/felix/openbmc       -> $(shell realpath ./openbmc)"
	@echo "   /home/felix/build_scripts -> $(shell realpath ./build_scripts)"
	@chmod +x entrycontainer
	@./entrycontainer

build: build_openbmc
