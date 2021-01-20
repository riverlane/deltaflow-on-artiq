# ----------------------------------------------------------------------------#
# --------------- MAKEFILE FOR DELTAFLOW-ON-ARTIQ ----------------------------#
# ----------------------------------------------------------------------------#

VERSION="0.3.3"

# --------------- DECLARATIONS -----------------------------------------------#

.DEFAULT_GOAL := help
.PHONY: help
help: ## List of main goals
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / \
	{printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

ifeq ($(OS),Windows_NT)
  # Windows is not supported!
else
  # Some commands are different in Linux and Mac
  UNAME_S := $(shell uname -s)

  # User's credential will be passed to the image and container
  USERNAME=$(shell whoami)
  USER_UID=$(shell id -u)
  USER_GID=$(shell id -g)
endif

PWD=$(shell pwd)

IMAGENAME=deltaflow-on-artiq
CONTAINERNAME=deltaflow-on-artiq

ENV_HASH=$(shell cat enviroment/Dockerfile-env enviroment/apt-list | shasum -a 1 | tr " " "\n" | head -n 1)

DEXEC = docker exec $(shell cat container)

BUILD_THREADS := $(shell cat /proc/cpuinfo | grep processor | wc -l)

ifeq ($(shell uname -s),Darwin)
  HOST=OSX
else
ifneq (,$(findstring NT,$(shell uname -s)))
  HOST=windows
else
  HOST=linuxX11
endif
endif


.PHONY: external-deps
external-deps:
	git submodule init
	git submodule update


# Passing arguments to documentation builder in docs/Makefile
# i.e. `make docs command` in ./ --> `make command` in ./docs/
# 
# For HTML documentation run `make docs html`, then
# open docs/_build/html/index.html in your favourite browser.
# 
# Ref https://stackoverflow.com/a/14061796
# Ref https://stackoverflow.com/a/9802777/3454146
FORDOCS=$(firstword $(MAKECMDGOALS))
ifeq ($(FORDOCS), $(filter $(FORDOCS), docs dev-docs))
  DOCS_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(DOCS_ARGS):;@:)
endif

# --------------- DOCKER IMAGES -----------------------------------------------#

.PHONY: image
image: environment/Dockerfile
	docker build . \
	--tag ${IMAGENAME} \
	--build-arg USERNAME=${USERNAME} \
	--build-arg USER_UID=${USER_UID} \
	--build-arg USER_GID=${USER_GID} \
	--build-arg VERSION=${VERSION} \
	--file $<

.PHONY: image-artiq-nix
image-artiq-nix: environment/Dockerfile-artiq-nix
	docker build . \
	--tag image-artiq-nix \
	--build-arg USERNAME=${USERNAME} \
	--build-arg USER_UID=${USER_UID} \
	--build-arg USER_GID=${USER_GID} \
	--build-arg VERSION=${VERSION} \
	--file $<

container:
	make image
	docker run \
	--rm -dt \
	-v `pwd`:/workdir \
	-w /workdir \
	--name=${CONTAINERNAME} \
	--privileged \
	--cidfile=container \
	${IMAGENAME} /bin/bash
	mkdir -p build

.PHONY: shell
shell: container
	docker exec -it $(shell cat container) /bin/bash

ADRUN=docker run --rm -v `pwd`:/workdir -w /workdir image-artiq-nix

.PHONY: ashell
ashell: image-artiq-nix
	${ADRUN}

# ----------- Environment Configuration ------------------------------------------#

CPPFLAGS=-std=c++17 \
	-DSC_CPLUSPLUS=201703L \
	-D_FORTIFY_SOURCE=2 \
	-faligned-new \
	-fstack-protector \
	-Wno-maybe-uninitialized \
	-Wall \
	-g \
	-grecord-gcc-switches \
	-O2 \
	-pipe \
	-fPIE \
	-Wno-error=sign-compare
SYSC_INC = -I$(shell ${DEXEC} printenv SYSTEMC_INCLUDE)
TBB_INC = -I$(shell ${DEXEC} printenv TBB_INCLUDE)
PYINCLUDES = $(shell ${DEXEC} python3.8-config --cflags)
VERILATOR_BASE =/usr/local/share/verilator
VERILATOR_INC = -I${VERILATOR_BASE}/include/ -I${VERILATOR_BASE}/include/vltstd/

INCLUDE = ${SYSC_INC} ${TBB_INC} ${PYINCLUDES} ${VERILATOR_INC} -I./
SYSC_LNK = -L$(shell ${DEXEC} printenv SYSTEMC_HOME)/lib-linux64/
VERILATOR_LNK=-L${VERILATOR_BASE}/include/
TBB_LNK = -L$(shell ${DEXEC} printenv TBB_LIBRARY_RELEASE)
PYLINK=/usr/local/lib/python3.8/config-3.8-x86_64-linux-gnu/libpython3.8.a \
	$(shell ${DEXEC} python3.8-config --ldflags)

VERILATOR_TRACE_FILES=${VERILATOR_BASE}/include/verilated.cpp \
	${VERILATOR_BASE}/include/verilated_vcd_c.cpp \
	${VERILATOR_BASE}/include/verilated_vcd_sc.cpp


# ----------- Runtime targets  ------------------------------------------#

# add sub-makefiles to keep the build logic or examples and tests somewhat confined
include emulator/or-tlm/Makefile
include emulator/Makefile
include demos/deltalanguage/Makefile
include demos/deltasimulator/Makefile
include demos/deltaflow_on_artiq/Makefile


###########################
# Start of the real targets - the basic idea for the build process is to
# map everything into SystemC and build testbenches there, and go via verilog
# so we can get to real hardware if needed.
###########################

# same trick for explicitly present verilog.
# this only works for verilog present before a make invocation, this is deliberate.
VERILOG_SOURCES := $(shell find . -name '*.v')
vpath %.v $(dir ${VERILOG_SOURCES})
build/verilated/V%.cpp: %.v container
	-${DEXEC} verilator \
	-CFLAGS "${CPPFLAGS}" \
	--sc $< \
	--Mdir build/verilated/ \
	--top-module $(basename $(notdir $<)) \
	-I$(dir $<) \
	-Wno-lint

# some prereqs may be generated as part of the build process - pick those
# up seperatly.
build/verilated/V%.cpp: build/%.v container
	-${DEXEC} verilator \
	-CFLAGS "${CPPFLAGS}" \
	--sc $< \
	--Mdir build/verilated/ \
	--top-module $(basename $(notdir $<)) \
	-I$(dir $<) \
	-Wno-lint

build/verilated/V%.h: build/verilated/V%.cpp
	-echo

build/verilated/V%__ALL.a: build/verilated/V%.cpp
	${DEXEC} make -C build/verilated/ -j \
	-f $(addsuffix .mk, $(basename $(notdir $^))) $(notdir $@)

# can use ANY V*.mk file to build this object.
# pipe ignores up-to-dateness of prereq, as long as it exists.
build/verilated.o: build/verilated/VAXILiteTarget.cpp
	${DEXEC} make -C build/verilated/ -j -f VAXILiteTarget.mk verilated.o
	cp build/verilated/verilated.o build/ | true

CPP_SOURCES := $(shell find . -name '*.cpp')
vpath %.cpp $(dir ${CPP_SOURCES})
## default cpp rule for nodeps objects
build/%.o: %.cpp container
	${DEXEC} g++ ${CPPFLAGS} ${INCLUDE} -o $@ -c $<

# --------------- DEVELOPERS ----------------------------------------------#

.PHONY: dev-image
dev-image: environment/dev.Dockerfile-image
	docker build --no-cache . \
	--tag ${IMAGENAME} \
	--build-arg USERNAME=${USERNAME} \
	--build-arg USER_UID=${USER_UID} \
	--build-arg USER_GID=${USER_GID} \
	--file $<

.PHONY: dev-image-nix
dev-image-nix: environment/dev.Dockerfile-image-nix
	docker build --no-cache . \
	--tag ${IMAGENAME} \
	--build-arg USERNAME=${USERNAME} \
	--build-arg USER_UID=${USER_UID} \
	--build-arg USER_GID=${USER_GID} \
	--file $<

# --------------- DOCUMENTATION ----------------------------------------------#

.PHONY: docs
docs: container ## Generate docs
	${DEXEC} make -C docs $(DOCS_ARGS)

# --------------- CLEANING ---------------------------------------------------#

.PHONY: clean
clean: clean-build clean-data clean-docs clean-logs clean-container

.PHONY: clean-build
clean-build:
	-rm -f vivado*.jou vivado*.log
	-rm -rf build/
	-find . -type f -name "*.o" -exec rm -f {} \;

.PHONY: clean-container
clean-container: ## Stop and remove the container
	docker ps -q --filter "name=${CONTAINERNAME}" | grep -q . && \
	docker stop ${CONTAINERNAME}
	rm -f container

.PHONY: clean-data
clean-data:
	rm -f *.vcd *.png

.PHONY: clean-docs
clean-docs:
	make -C docs clean

.PHONY: clean-logs
clean-logs: ## Clean logs
	rm -f docs/sphinx-build-*.log
