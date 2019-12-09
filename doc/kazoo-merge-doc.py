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

    newdoc = []

    #  Write the resulting file
    with open (result, "wb") as output:
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
