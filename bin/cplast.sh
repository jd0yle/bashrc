#!/usr/bin/env bash

# Echoes the last command
echo "foo"
cmd=$(fc -nl -1)
echo "# $cmd"
fc -nl -1 | sed 's/^\s*//g' | xc
