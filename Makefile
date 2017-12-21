UNAME := $(shell uname)
ARCH := $(shell getconf LONG_BIT)

CC=gcc
exec = aadl_parser

all: build

build:
ifeq ($(UNAME), Linux)
	@echo "package Parser_Version is" > src/parser_version.ads.new
	@echo "   Parser_Release : constant String :=" >> src/parser_version.ads.new
	@echo -n '      "' >> src/parser_version.ads.new
	@git log --oneline | head -1 | cut -f1 -d' ' | tr -d '\012' >> src/parser_version.ads.new
	@echo " ; Commit " | tr -d '\r\n' >> src/parser_version.ads.new
	@git log | head -3 | tail -1 | cut -f1 -d"+" | tr -d '\r\n' >>  src/parser_version.ads.new
	@echo "\";" >> src/parser_version.ads.new
	@echo "   Ocarina_Version : constant String :=" >> src/parser_version.ads.new
	@echo -n '      "' >> src/parser_version.ads.new
	@ocarina --version | head -1 | tr -d '\012' >> src/parser_version.ads.new
	@echo "\";" >> src/parser_version.ads.new
	@echo -n "end Parser_Version;" >> src/parser_version.ads.new
	@if [ ! -f "src/parser_version.ads" ] ; then                \
		mv src/parser_version.ads.new src/parser_version.ads;          \
	else                                            \
		MD1=`cat src/parser_version.ads | md5sum` ;         \
		MD2=`cat src/parser_version.ads.new | md5sum` ;     \
		if [ "$$MD1" != "$$MD2" ] ; then        \
			mv src/parser_version.ads.new src/parser_version.ads ;  \
		else                                    \
			rm src/parser_version.ads.new ;             \
		fi ;                                    \
	fi
endif
	#[ $(ARCH) == 64 ] && EXTRAFLAG="--target=x86_64-linux" ; \

	OCARINA_PATH=`ocarina-config --prefix` \
            $(gnatpath)gprbuild -j0 -x -g $(exec) -p -P aadl_parser.gpr -XBUILD="debug" $$EXTRAFLAG

install:
	$(MAKE)
	mv aadl_parser taste-aadl-parser
	cp taste-aadl-parser `ocarina-config --prefix`/bin/

edit:
	OCARINA_PATH=`ocarina-config --prefix` gps

test:
	@$(MAKE) -C test

clean:
	rm -rf obj $(exec) *~

.PHONY: install clean build edit test
