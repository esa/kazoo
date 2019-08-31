RTDS_GEN_DIR=/home/assert/extra-space/tool-src/testSuites/Regression_AADLv2/Demo_ABB/controller/controller
RTDS_CLASSES_DIR=/home/assert/extra-space/tool-src/testSuites/Regression_AADLv2/Demo_ABB/controller/controller
RTDS_TEMPLATES_DIR=/home/assert/extra-space/tool-src/testSuites/Regression_AADLv2/Demo_ABB/controller/profile

RTDS_CC=gcc
RTDS_LNK=$(RTDS_CC)
RTDS_CC_INCLUDES=-I"." -I"${RTDS_TEMPLATES_DIR}" -I"${RTDS_HOME}/share/ccg/cscheduler" -I"${RTDS_HOME}/share/ccg/common" -I"$(RTDS_CLASSES_DIR)" -I"../../../common"
RTDS_CC_OPTIONS=-I"." -I"${RTDS_TEMPLATES_DIR}" -I"${RTDS_HOME}/share/ccg/cscheduler" -I"${RTDS_HOME}/share/ccg/common" -I"$(RTDS_CLASSES_DIR)" -DRTDS_SOCKET_IP_ADDRESS=127.0.1.1 -DRTDS_SOCKET_PORT=49250 -IRTDS-RTOS-adaptation -I ../../../common/
RTDS_LNK_OPTIONS=

RTDS_RM=rm -f

RTDS_OBJECTS = \
	controller_p.o \
	RTDS_controller_project_comp_functions.o \
	RTDS_String.o \
	RTDS_Proc.o \
	RTDS_Scheduler.o


RTDS_ADDL_OBJECTS =

RTDS_EXT_OBJECTS =

RTDS_TARGET_BASE_NAME=controller
RTDS_TARGET_EXTENSION=.exe

all: $(RTDS_TARGET_BASE_NAME)$(RTDS_TARGET_EXTENSION)

$(RTDS_TARGET_BASE_NAME)$(RTDS_TARGET_EXTENSION): $(RTDS_OBJECTS) $(RTDS_ADDL_OBJECTS) $(RTDS_EXT_OBJECTS)
	$(RTDS_LNK) $(RTDS_LNK_OPTIONS) -o "$@" $(RTDS_OBJECTS) $(RTDS_ADDL_OBJECTS) $(RTDS_EXT_OBJECTS)

controller_p.o: $(RTDS_GEN_DIR)/controller_p.c $(RTDS_GEN_DIR)/controller_p.h $(RTDS_GEN_DIR)/RTDS_controller_project_messages.h $(RTDS_GEN_DIR)/RTDS_gen.h $(RTDS_GEN_DIR)/controller_p_decl.h $(RTDS_GEN_DIR)/controller.h $(RTDS_GEN_DIR)/RTDS-RTOS-adaptation/RTDS_CommonTypes.h $(RTDS_GEN_DIR)/RTDS-RTOS-adaptation/RTDS_String.h $(RTDS_GEN_DIR)/RTDS-RTOS-adaptation/RTDS_Set.h $(RTDS_GEN_DIR)/RTDSdataView.h Makefile
	$(RTDS_CC) $(RTDS_CC_OPTIONS) -c -o "$@" "$<"

RTDS_controller_project_comp_functions.o: $(RTDS_GEN_DIR)/RTDS_controller_project_comp_functions.c Makefile
	$(RTDS_CC) $(RTDS_CC_OPTIONS) -c -o "$@" "$<"

RTDS_String.o: $(RTDS_GEN_DIR)/RTDS-RTOS-adaptation/RTDS_String.c Makefile
	$(RTDS_CC) $(RTDS_CC_OPTIONS) -c -o "$@" "$<"

RTDS_Proc.o: $(RTDS_HOME)/share/ccg/cscheduler/RTDS_Proc.c Makefile
	$(RTDS_CC) $(RTDS_CC_OPTIONS) -c -o "$@" "$<"

RTDS_Scheduler.o: $(RTDS_HOME)/share/ccg/cscheduler/RTDS_Scheduler.c Makefile
	$(RTDS_CC) $(RTDS_CC_OPTIONS) -c -o "$@" "$<"

RTDS_clean:
	$(RTDS_RM) $(RTDS_TARGET_BASE_NAME)$(RTDS_TARGET_EXTENSION)
	$(RTDS_RM) "controller_p.o"
	$(RTDS_RM) "RTDS_controller_project_comp_functions.o"
	$(RTDS_RM) "RTDS_String.o"
	$(RTDS_RM) "RTDS_Proc.o"
	$(RTDS_RM) "RTDS_Scheduler.o"

RTDS_mrproper: RTDS_clean
	$(RTDS_RM) "controller_p_decl.h"
	$(RTDS_RM) "RTDSdataView.h"
	$(RTDS_RM) "controller_p.c"
	$(RTDS_RM) "RTDS_controller_project_messages.h"
	$(RTDS_RM) "controller_p.h"
	$(RTDS_RM) "RTDS_gen.h"
	$(RTDS_RM) "controller.h"
	$(RTDS_RM) "RTDS_controller_project_comp_functions.c"
	$(RTDS_RM) RTDS_gen.ini
	$(RTDS_RM) Makefile
