UNAME := $(shell uname)

CC=gcc
exec = aadl_parser

all: build

build:
ifeq ($(UNAME), Linux)
	@echo "package Parser_Version is" > src/parser_version.ads.new
	@echo -n "   Parser_Release : constant String :=\n      \"" >> src/parser_version.ads.new
	@git log --oneline | head -1 | cut -f1 -d' ' | tr -d '\012' >> src/parser_version.ads.new
	@echo " ; Commit " | tr -d '\r\n' >> src/parser_version.ads.new
	@git log | head -3 | tail -1 | cut -f1 -d"+" | tr -d '\r\n' >>  src/parser_version.ads.new
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
	ADA_PROJECT_PATH=`ocarina-config --prefix`/lib/gnat:$$ADA_PROJECT_PATH \
            $(gnatpath)gprbuild -x -g $(exec) -p -P aadl_parser.gpr -XBUILD="debug"

install:
	$(MAKE)
	mv aadl_parser taste-aadl-parser
	cp taste-aadl-parser `ocarina-config --prefix`/bin/

clean:
	rm -rf tmpBuild $(exec) *~

.PHONY: install clean build
