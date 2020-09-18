# SDL
#Taste::coordinates 1889 199 2582 928
OPENGEODE?=opengeode

all: compile-linux

clean:
	rm -rf obj

edit:
	cd src && $(OPENGEODE) system_structure.pr orchestrator.pr

# Ada
generate-code:
	mkdir -p code && cd code && \
	   $(OPENGEODE) --taste --toAda ../src/orchestrator.pr ../src/system_structure.pr && \
	   mv *.gpr ..

compile-linux: generate-code
	   CODE_PATH=code ADA_INCLUDE_PATH=../../../dataview/Ada gprbuild -p -P orchestrator_ada.gpr

