#!/bin/bash

mpg123 --quiet --wav - "$1" 2>>/dev/null | oggenc --quiet --quality -1 --output="$2" -
