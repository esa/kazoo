#!/usr/bin/python
# -*- coding: utf-8 -*-

''' Edit this module at will to create custom widgets that can send TC or
    receive TM - and do anything you like with the data.
    (c) 2016-2019 European Space Agency
'''

__author__ = "Maxime Perrotin, Thanassis Tsiodras"
__license__ = "LGPL"
__url__ = "https://taste.tools"

import sys
import os
import importlib
from functools import partial

from PySide2.QtCore import *
from PySide2.QtGui import *
from PySide2.QtWidgets import *

from asn1_value_editor import UserWidgetsCommon
import DV

# ** IMPORTANT **
# you must list here the classes you want to expose to the GUI:
__all__ = ['Arrows_TC', 'Grid_TM']

class Arrows_TC(UserWidgetsCommon.TC):
    ''' Fill / mimick this class to create a custom TC widget '''
    name = "Show Controls"

    def __init__(self, asn1_typename, parent):
        ''' Initialise the widget '''
        super(Arrows_TC, self).__init__(asn1_typename, parent)
        self._asn1_typename = asn1_typename
        names = ['Rotate', 'Drop', 'Left', 'Right']

        # UserWidgetsCommonTC.TC is a QDockWidgets
        self.widget = QGroupBox (self) #MyGroupBox (self) #QGroupBox(self)
        layout = QVBoxLayout()
        self.widget.setFocusPolicy (Qt.ClickFocus)  # to allow key events

        self.buttons = {}
        for each in names:
            self.buttons[each] = QPushButton(each)
            self.buttons[each].clicked.connect(partial(self.clicked, each))
            layout.addWidget(self.buttons[each])
        layout.addStretch(1)
        self.widget.setLayout(layout)

        self.setWidget(self.widget)

        # parent is the ASN.1 value editor
        self.parent = parent
        self.setWindowTitle("Tetris Controls")
        self.show()

    @staticmethod
    def applicable():
        ''' Return True to activate this widget '''
        return True

    @staticmethod
    def editorIsApplicable(editor):
        ''' Return true if this particular editor is compatible with this
        widget'''
        return editor.messageName == 'Move'

    def clicked(self, name):
        ''' Called when user clicks on one of the buttons '''
        if name == "Rotate":
            self.parent.asn1Instance.Set(DV.rotate)
        elif name == "Drop":
            self.parent.asn1Instance.Set(DV.down)
        elif name == "Right":
            self.parent.asn1Instance.Set(DV.right)
        elif name == "Left":
            self.parent.asn1Instance.Set(DV.left)
        self.parent.updateVariable()
        self.parent.sendTC()

    def keyPressEvent (self, evt):
        key = evt.key()
        if key == Qt.Key_Up:
            self.clicked("Rotate")
        elif key == Qt.Key_Down:
            self.clicked("Drop")
        elif key == Qt.Key_Right:
            self.clicked("Right")
        elif key == Qt.Key_Left:
            self.clicked("Left")


class Grid_TM(UserWidgetsCommon.TM):
    ''' Display the Tetris playground '''
    name = 'Show Playground'

    def __init__(self, parent=None):
        ''' Initialise the widget '''
        super(Grid_TM, self).__init__(parent)
        self.widget = QGraphicsView()
        self.scene = QGraphicsScene()
        self.widget.setScene(self.scene)
        self.playground=[]
        for y in range(20):
            line = []
            for x in range (10):
                block = QGraphicsRectItem(x*20, y*20, 19, 19)
                brush = QBrush(Qt.white)
                block.setBrush(brush)
                pen = QPen(Qt.lightGray)
                pen.setWidthF (0.1)
                block.setPen(pen)
                self.scene.addItem(block)
                line.append(block)
            self.playground.append(line)

        self.parent = parent
        self.setWindowTitle("Tastris Playground")
        self.setWidget(self.widget)
        self.show()

    @Slot()
    def new_tm(self):
        ''' Slot called when a TM has been received in the editor '''
        # Nothing to do, the update() function does nothing thread-related
        # that would need to be done here
        pass #print('new_tm')

    def update(self, value):
        ''' Receive ASN.1 value '''
        colors = {DV.empty : Qt.white,
                  DV.red   : Qt.darkRed,
                  DV.blue  : Qt.darkBlue,
                  DV.green : Qt.darkGreen}
        for y in range(20):
            for x in range(10):
                color = value[y][x].Get()
                block = self.playground[y][x]
                brush = block.brush()
                brush.setColor(colors[color])
                block.setBrush(brush)

    @staticmethod
    def applicable():
        ''' Return True to enable this widget '''
        return True

    @staticmethod
    def editorIsApplicable(editor):
        ''' Return true if this particular editor is compatible with this
        widget'''
        return editor.messageName == "Update_Grid"


if __name__ == '__main__':
    print('This module can only be imported from the main TASTE guis')
    sys.exit(-1)
