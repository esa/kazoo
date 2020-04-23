This is a project used to validate support in pohic of RI called during the call to the startup procedures

WARNING 
to compile this project requires opengeode v3 
to install opengeode v3 you need to be in a version of debian >= 10 (buster) or an equivalent in ubuntu
you need to have Python3 3.6 at least and PySide2 (apt install python-pyside2)
In tool-src/opengeode do:
git checkout python3-pyside2
git pull
pip3 install --user --upgrade .

If this fails it means you probably also need antlr3 for Python3
ask for support if needed

