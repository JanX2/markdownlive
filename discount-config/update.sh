#!/bin/bash

status_msg () {
	echo -e "\033[1m$1\033[0m"
}

error_msg () {
	echo -e "\033[31m$1\033[0m" >&2
	tput sgr0
}


if ! git diff --no-ext-diff --quiet --exit-code; then
	error_msg "The git working copy is dirty. Commit any uncommited changes before running this script"
	exit 1
fi

status_msg "Running configure.sh..."

cd `dirname $0`/../External/discount/
./configure.sh

status_msg "Copying important files..."

DISCOUNT_CONFIG_DIR="../../discount-config"

if head -n 1 config.h | grep -q "^/\*$"; then
	# remove generated comments in config.h
	sed '1,/^ *\*\/ *$/ { d; }' < config.h >"$DISCOUNT_CONFIG_DIR/config.h" && echo 'config.h'
else
	cp config.h "$DISCOUNT_CONFIG_DIR/config.h" && echo 'config.h'
	error_msg "Can't locate config.h comments!"
	error_msg "Check the diff before committing (and fix this script if you can)"
fi
cp mkdio.h "$DISCOUNT_CONFIG_DIR/mkdio.h" && echo 'mkdio.h'
rm ../../blocktags # Will be recreated by mktags (Run blocktags Script build phase)

status_msg "Clean files from working copy..."

# Removing untracked files from git working copy
git clean -f

status_msg "Done!"
