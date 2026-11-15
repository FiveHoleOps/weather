#!/usr/bin/env bash
# Script to print "hello world" in red text

# ANSI color codes
RED='\033[0;31m'
NC='\033[0m' # No Color (reset)

# Print the message in red and reset the terminal color
printf "${RED}%s${NC}\n" 'hello world'
