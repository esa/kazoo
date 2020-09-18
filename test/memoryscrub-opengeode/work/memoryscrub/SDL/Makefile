# SDL
#Taste::coordinates 359 1221 1344 1883
OPENGEODE?=opengeode

all: compile-linux

clean:
	rm -rf obj

edit:
	cd src && $(OPENGEODE) system_structure.pr memoryscrub.pr

# Ada
generate-code:
	mkdir -p code && cd code && \
	   $(OPENGEODE) --taste --toAda ../src/memoryscrub.pr ../src/system_structure.pr && \
	   mv *.gpr ..

compile-linux: generate-code
	   CODE_PATH=code ADA_INCLUDE_PATH=../../../dataview/Ada gprbuild -p -P memoryscrub_ada.gpr

