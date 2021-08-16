#!/usr/bin/env bash

scripts/generate-syntax.py > syntax/ecl.vim
scripts/generate-syntax.py --completions > completion/ecl.txt
