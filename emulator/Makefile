.ONESHELL: build/ARTIQ
build/ARTIQ: image-artiq-nix \
             emulator/SoCBuilder/build_kasli_software.py \
			 emulator/SoCBuilder/virtual_kasli.py
	${ADRUN} /bin/sh -c \
	"/nix/var/nix/profiles/default/bin/nix-shell -I artiqSrc=/artiq \
	/nix-scripts/artiq-fast/shell-dev.nix --command \
	\"PYTHONPATH=/workdir/emulator/artiq \
	  python /workdir/emulator/SoCBuilder/build_kasli_software.py\""
	${ADRUN} /bin/sh -c "chown -R $(shell id -u):$(shell id -g) build/"
	${DEXEC} or1k-elf-objdump --disassemble-all build/artiq_kasli/software/runtime/runtime.elf > build/artiq_kasli/software/runtime/runtime.obj
	touch build/ARTIQ

build/artiq_kasli/software/bootloader/bootloader.elf: build/ARTIQ

build/artiq_kasli/software/runtime/runtime.elf: build/ARTIQ

build/artiq_kasli/gateware/top.v: build/ARTIQ

build/idle_kernel.elf: image-artiq-nix \
                  emulator/SoCBuilder/idle_kernel.py
	${ADRUN} /bin/sh -c \
	"/nix/var/nix/profiles/default/bin/nix-shell -I artiqSrc=/artiq \
	/nix-scripts/artiq-fast/shell-dev.nix --command \
	\"PYTHONPATH=/workdir/emulator/artiq:/workdir \
	  /workdir/emulator/artiq/artiq/frontend/artiq_compile.py \
		--device-db /workdir/emulator/SoCBuilder/device_db.py \
		/workdir/emulator/SoCBuilder/idle_kernel.py \
		-o /workdir/build/idle_kernel.elf  \""

.ONESHELL: build/startup_kernel.elf
build/startup_kernel.elf: image-artiq-nix \
                  emulator/SoCBuilder/startup_kernel.py
	${ADRUN} /bin/sh -c \
	"/nix/var/nix/profiles/default/bin/nix-shell -I artiqSrc=/artiq \
	/nix-scripts/artiq-fast/shell-dev.nix --command \
	\"PYTHONPATH=/workdir/emulator/artiq:/workdir \
	  /workdir/emulator/artiq/artiq/frontend/artiq_compile.py \
		--device-db /workdir/emulator/SoCBuilder/device_db.py \
		/workdir/emulator/SoCBuilder/startup_kernel.py \
		-o /workdir/build/startup_kernel.elf  \""
	${DEXEC} or1k-elf-objdump --disassemble-all -l build/startup_kernel.elf > build/startup_kernel.obj

build/flash_storage.img: image-artiq-nix \
                  build/idle_kernel.elf build/startup_kernel.elf 
	${ADRUN} /bin/sh -c \
	"/nix/var/nix/profiles/default/bin/nix-shell -I artiqSrc=/artiq \
	/nix-scripts/artiq-fast/shell-dev.nix --command \
	\"PYTHONPATH=/workdir/emulator/artiq:/workdir \
	  /workdir/emulator/artiq/artiq/frontend/artiq_mkfs.py /workdir/build/flash_storage.img \
	  -s ip 192.168.0.14 \
	  -f idle_kernel /workdir/build/idle_kernel.elf  \
	  -f startup_kernel /workdir/build/startup_kernel.elf  \""

build/verilated/Vtop.cpp: build/artiq_kasli/gateware/top.v container
	-${DEXEC} sed -i -E "s/readmemh\(\"/readmemh \(\"\/workdir\/build\/artiq_kasli\/gateware\//g" build/artiq_kasli/gateware/top.v
	-${DEXEC} verilator -CFLAGS "${CPPFLAGS}" --sc $< \
	                   --Mdir build/verilated/ --top-module $(basename $(notdir $<)) \
										 -I$(dir $<) -I./emulator/mor1kx/rtl/verilog \
										 -I./emulator -I./deltamodels/models/memories -I./deltamodels/models/basic_blocks/\
										 -Wno-lint -Wno-fatal -Wno-combdly -Wno-unoptflat \
										 --trace \
										 --pins-bv 1 --clk sys_clk_ps --clk sysclk --clk clk200 --clk sysclk4x --clk sys4x_dqs


.PHONY:kasli-or1k-binary
kasli-or1k-binary: build/artiq_kasli/software/bootloader/bootloader.elf

build/liteeth/liteeth.v: src/SoCBuilder/build_liteeth.py container
	${DEXEC} python3 src/SoCBuilder/build_liteeth.py

# build/verilated/V%.cpp can be built by the default rule for verilator
	-${DEXEC} verilator -CFLAGS "${CPPFLAGS}" --sc $< \
	                   --Mdir build/verilated/ \
										 --top-module $(basename $(notdir $<)) \
										 -I$(dir $<) \
										 -Wno-lint


.ONESHELL: build/textrst.bin
build/textrst.bin: emulator/jump.S container
	${DEXEC} or1k-linux-as emulator/jump.S -o build/jump.o
	${DEXEC} or1k-linux-objcopy build/jump.o --dump-section .text=build/textrst.bin


