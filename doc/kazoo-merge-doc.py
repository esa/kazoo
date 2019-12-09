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
            '--output',
            type=str,
            metavar='out_file',
            default='updated.mediawiki',
            help='Output file name')
    parser.add_argument(
            '-i',
            '--old',
            type=str,
            default='old.mediawiki',
            metavar='old',
            help='Previous file containing tags description')
    parser.add_argument(
            '-n',
            '--new',
            type=str,
            default='new.mediawiki',
            metavar='new',
            help='Freshly generated tag list')
    return parser.parse_args()

def run(options):
    old    = options.old
    new    = options.new
    result = options.output
    out_folder = options.output if options.output else '.'
    #os.makedirs(out_folder, exist_ok=True)
    if not os.path.exists(old) or not os.path.exists(new):
        LOG.error ("Input file(s) missing, check --help.")
        return

    #  Read the input files
    old_content = open (old, "r").readlines()
    new_content = open (new, "r").readlines()

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

    with open (result, "w") as output:
        output.write("\n".join (newdoc))

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
