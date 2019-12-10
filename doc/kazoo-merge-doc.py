#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
   This application merges freshly-generated template documentation
   with previous documentation containing tag description/

   It is part of kazoo - TASTE Project

   Copyright (c) 2019 Maxime Perrotin
             (c) 2019 European Space Agency

   Contact : maxime.perrotin@esa.int
"""
__version__ = "1.0.0"

import os
import signal
import argparse
import traceback
import logging
from typing import List, Dict, Tuple

LOG = logging.getLogger(__name__)

def init_logging(options):
    ''' Initialize logging '''
    terminal_formatter = logging.Formatter(fmt="[%(levelname)s] %(message)s")
    handler_console = logging.StreamHandler()
    handler_console.setFormatter(terminal_formatter)
    LOG.addHandler(handler_console)
    level = logging.DEBUG if options.debug else logging.INFO
    LOG.setLevel(level)

def parse_args():
    ''' Parse command line arguments '''
    parser = argparse.ArgumentParser()
    parser.add_argument(
            '-v',
            '--version',
            action='version',
            version=__version__)
    parser.add_argument(
            '-g',
            '--debug',
            action='store_true',
            default=False,
            help='Display debug information')
    parser.add_argument(
            '-o',
            '--outputfolder',
            type=str,
            metavar='out_folder',
            default='templates',
            help='Output file name')
    parser.add_argument(
            '-i',
            '--oldfolder',
            type=str,
            default='./preprocess/output',
            metavar='old',
            help='Previous file containing tags description')
    parser.add_argument(
            '-n',
            '--newfolder',
            type=str,
            default='./new-templates',
            metavar='new',
            help='Freshly generated tag list')
    parser.add_argument(
            '-k',
            '--orderlist',
            type=str,
            default='./order.txt',
            metavar='order',
            help='List of ordered template files to be processed')

    return parser.parse_args()


def process_one_file (tmplt: str, old: str, new: str, res_folder: str) -> None:
    #  Read the input files
    try:
        old_content = open(old, "r").readlines()
    except FileNotFoundError:
        LOG.info("Skipping template " + old + " (file not found)")
        return
    try:
        new_content = open(new, "r").readlines()
    except FileNotFoundError:
        LOG.info("Skipping template " + new + " (file not found)")
        return

    # Build dictionnaries from the content of the two files
    assert len(old_content) > 4 and len(new_content) > 5

    # The dict has to be ordered: this can work only with Python 3.6+
    old_dict = {}
    current_tag = ""
    for line in old_content[3:-1]:
        if line.startswith ("|-"):
            if current_tag != "":
                old_dict[current_tag] = descr
            next_line = "tagname"
            descr = []
            current_tag = ""
        elif next_line == "tagname":
            current_tag = line
            next_line = "description"
        elif next_line == "description":
            # there can be several description lines
            descr.append(line.strip())
    # Don't forget the last line...
    if current_tag != "":
        old_dict[current_tag] = descr

    # In the new file, we ignore description, we only care about tag names
    new_tags = set()
    next_line = ""
    for line in new_content[3:-1]:
        if line.startswith ("|-"):
            next_line = "tagname"
            tagname = ""
        elif next_line == "tagname":
            new_tags.add(line)
            next_line = "description"
        elif next_line == "description":
            # ignore description
            pass

    #  Keep the wikimedia header
    newdoc = [line.strip() for line in old_content[0:3]]

    for name in old_dict.keys():
        if name not in new_tags:
            LOG.info ("Tag " + name.strip() + " has been removed")
        else:
            LOG.info ("Tag " + name.strip() + " has been kept")
            new_tags.remove(name)
            newdoc.append("|-")
            newdoc.append(name.strip())
            newdoc.extend(old_dict[name])   # Add the description lines

    # If there are still some items in new_tags, they must be added
    for name in new_tags:
        LOG.info ("Tag " + name.strip() + " had been added")
        newdoc.append("|-")
        newdoc.append(name.strip())
        newdoc.append("|DOCUMENTATION MISSING")

    newdoc.append("|}")

    with open (res_folder+"/"+tmplt, "w") as output:
        output.write("\n".join (newdoc))


def run(options):
    old_folder    = options.oldfolder
    new_folder    = options.newfolder
    result_folder = options.outputfolder
    os.makedirs(result_folder, exist_ok=True)
    if not os.path.exists(old_folder):
        LOG.error ("Input folder(s) missing, check --help - " + old_folder)
        return
    if not os.path.exists(new_folder):
        LOG.error ("Input folder(s) missing, check --help - " + new_folder )
        return

    if not os.path.exists(options.orderlist):
        LOG.error ("Missing order specification file " + options.orderlist)
        return

    orderlist = open(options.orderlist, "r").readlines()

    for each in orderlist:
        name=each.strip()
        process_one_file (tmplt=name,
                         old=old_folder+"/"+name,
                         new=new_folder+"/"+name,
                         res_folder=result_folder)

def main():
    ''' Tool entry point '''
    # Catch Ctrl-C to stop the app from the console
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    options = parse_args()
    init_logging(options)
    LOG.info('Kazoo Documentation Merger - version ' + __version__)
    run(options)

if __name__ == '__main__':
    ''' Run main application '''
    main()
