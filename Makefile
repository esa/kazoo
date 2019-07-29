UNAME := $(shell uname)
ARCH := $(shell getconf LONG_BIT)

CC=gcc
exec = kazoo

all: build

build:
	#if [ -d "templates-parser" ]; then cd templates-parser && git pull; else git clone https://github.com/AdaCore/templates-parser; fi
	--  make -C templates-parser -j
ifeq ($(UNAME), Linux)
	@echo "package TASTE.Parser_Version is" > src/taste-parser_version.ads.new
	@echo "   Parser_Release : constant String :=" >> src/taste-parser_version.ads.new
	@echo -n '      "' >> src/taste-parser_version.ads.new
	@git log --oneline | head -1 | cut -f1 -d' ' | tr -d '\012' >> src/taste-parser_version.ads.new
	@echo " ; Commit " | tr -d '\r\n' >> src/taste-parser_version.ads.new
	@git log | head -3 | tail -1 | cut -f1 -d"+" | tr -d '\r\n' >>  src/taste-parser_version.ads.new
	@echo "\";" >> src/taste-parser_version.ads.new
	@echo "   Ocarina_Version : constant String :=" >> src/taste-parser_version.ads.new
	@echo -n '      "' >> src/taste-parser_version.ads.new
	@ocarina --version | head -1 | tr -d '\012' >> src/taste-parser_version.ads.new
	@echo "\";" >> src/taste-parser_version.ads.new
	@echo -n "end TASTE.Parser_Version;" >> src/taste-parser_version.ads.new
	@if [ ! -f "src/taste-parser_version.ads" ] ; then                \
		mv src/taste-parser_version.ads.new src/taste-parser_version.ads;          \
	else                                            \
		MD1=`cat src/taste-parser_version.ads | md5sum` ;         \
		MD2=`cat src/taste-parser_version.ads.new | md5sum` ;     \
		if [ "$$MD1" != "$$MD2" ] ; then        \
			mv src/taste-parser_version.ads.new src/taste-parser_version.ads ;  \
		else                                    \
			rm src/taste-parser_version.ads.new ;             \
		fi ;                                    \
	fi
endif
	@#[ $(ARCH) == 64 ] && EXTRAFLAG="--target=x86_64-linux" ;
	OCARINA_PATH=`ocarina-config --prefix` \
            $(gnatpath)gprbuild -j0 -x -g $(exec) -p -P kazoo.gpr -XBUILD="debug" $$EXTRAFLAG

install:
	$(MAKE)
	cp kazoo `ocarina-config --prefix`/bin/

edit:
	OCARINA_PATH=`ocarina-config --prefix` gps

test:
	@$(MAKE) -C test

clean:
	rm -rf obj templates-parser $(exec) *~

.PHONY: install clean build edit test
