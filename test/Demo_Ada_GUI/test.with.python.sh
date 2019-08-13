#!/bin/bash
if [ ! -d output.pohic/binaries/ ] ; then
	echo Build first - invoke make
	exit 1
fi
echo Run 
echo "    " export ASSERT_IGNORE_GUI_ERRORS=1
echo from another shell, and hit ENTER - Stop the test with Ctrl-C
read ANS
cp Test_TM_TC_Demo_Ada_GUI_2.py output.pohic/binaries/mygui_GUI/
# Test C version
cd output.pohic/binaries/mygui_GUI/
../mypartition &
python Test_TM_TC_Demo_Ada_GUI_2.py
pkill mypartition
cd -
