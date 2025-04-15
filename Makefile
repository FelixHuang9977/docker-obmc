#FEliX
dockimage_obmcbuilder=$(shell docker image ls | grep -o obmcbuilder)
myContainerName=$(shell whoami)_obmcbuilder

help:
	@echo "setup     #setup env"
	@echo "pull      #get openbmc 2.14.0 source code to local"
	@echo "build     #build obmc-phosphor image"
	@echo "qemu      #kill old qemu and re-launch it with openbmc/build/evb-ast2600/tmp/deploy/images/evb-ast2600/*.mtd"

pull:
	-git clone --single-branch --branch=2.14.0 https://github.com/openbmc/openbmc.git
	-git clone --single-branch --branch=2.14.0 https://github.com/openbmc/openbmc.git openbmc_orig_2.14.0

check:
	@echo "dockimage_obmcbuilder=$(dockimage_obmcbuilder)"
	@echo "myContainerName=$(myContainerName)"
	docker ps
	echo
	ls -l openbmc/build/tmp/deploy/images/evb-ast2600/*.mtd && echo -e "\nImage is Ready.\n"

setup:
	@if [ ! -f ./qemu-system-aarch64 ]; then tar zxvf TOOLS/qemu-system-aarch64.tar.gz; fi
	@if [ ! -f lib_fx_expect.sh ]; then curl --header "PRIVATE-TOKEN: sdVq-uaxmcLxvsq9HtZV" -O http://192.168.121.23/AMI_BIOS/DIAG/diag_cli/raw/master/unittest/lib_fx_expect.sh; fi

clean:
	-@rm ./qemu-system-aarch64
	-@rm ./lib_fx_expect.sh
	-@rm my_qemu.log my_qemu.run

run: setup
	./run_obmc_qemu.sh

test: setup
	@chmod +x test_obmc_qemu.sh
	@echo "wait for qemu network ready..."
	@tail -n 1000  -f my_qemu.log | grep -m 1 "Network is Online"
	@./test_obmc_qemu.sh

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
	if [ -z "$(shell docker ps | grep -o $(myContainerName))" ]; then \
			echo "container is not running, try to launch...." ;\
			chmod +x entrycontainer ;\
			./entrycontainer bash /build_scripts/build_evb-ast2600_obmc-phosphor-image.sh ;\
		else \
			echo "(container is running, use exec -it)" ;\
			docker inspect $(myContainerName) |sed -n '/Mounts/,/Config/{p}' ;\
			docker exec -it --user 1010 $(myContainerName) bash /build_scripts/build_evb-ast2600_obmc-phosphor-image.sh ;\
		fi
			
entrycontainer: enter_container

enter_container:
	if [ -z "$(shell docker ps | grep -o $(myContainerName))" ]; then \
			echo "container is not running, try to launch...." ;\
			make launch_container ;\
		else \
			echo "(container is running, use exec -it)" ;\
			echo "(you are at container now)" ;\
			echo "## HOW to build: " ;\
			cat build_scripts/build_evb-ast2600_obmc-phosphor-image.sh ;\
			echo ;\
			echo ;\
			docker exec -it --user 1010 $(myContainerName) /bin/bash  ;\
		fi

launch_container:
	@echo "Launching obmcbuilder for $(shell whoami)..."
	@echo "  mount in obmcbuilder container:"
	@echo "    /home/$(shell whoami)/openbmc  -> $(shell realpath ./openbmc)"
	@echo "    /build_scripts                 -> $(shell realpath ./build_scripts)"
	@chmod +x entrycontainer
	@./entrycontainer

build: build_openbmc
