#!/bin/bash

#
# A shell script for creating a new c/c++ project 
#

PRJ_NAME=''
PRJ_ROOT=''
PRJ_TOPDIR=
PRJ_SUBDIRS="bin doc include lib src spike test" 

for option
do
	case $option in

	--help | -help | -h)
		want_help=yes;;
	
	--name=* | -name=*)
		PRJ_NAME=`expr "x$option" : "x-*name=\(.*\)"`
		;;

	--directory=* | -directory=*)
		PRJ_ROOT=`expr "x$option" : "x-*directory=\(.*\)"`
		;;

	-*)
      { echo "error: unrecognized option: $option
Try \`$0 --help' for more information." >&2
      { (exit 1); exit 1; }; }
      ;; 

	esac

done


if test "x$want_help" = xyes; then
  cat <<EOF
\`./create_project.sh' creates a new C/C++ project.

Usage: $0 [OPTION]... 

Defaults for the options are specified in brackets.

Configuration:
  -h, --help             display this help and exit
  --name=NAME	         use existing Boost.Jam executable (bjam)

  --directory=DIR        
 
EOF

fi

test -n "$want_help" && exit 0

if test "x$PRJ_ROOT" = x; then
	PRJ_ROOT=$PWD
fi

#Determine the project name 
if test "x$PRJ_NAME" = x; then
	count=0
	while [ -e "$PRJ_ROOT/new_prj$count" ]; do 
		let count=count+1
	done  
	PRJ_NAME="new_prj$count"
fi

PRJ_TOPDIR="$PRJ_ROOT/$PRJ_NAME"

#echo $PRJ_TOPDIR
#echo $PRJ_NAME

#create project directories 
mkdir -p $PRJ_TOPDIR
for subdir in $PRJ_SUBDIRS
do
#	echo $PRJ_TOPDIR/$subdir
	mkdir -p $PRJ_TOPDIR/$subdir
done


#add the .gitignore file
cat > $PRJ_TOPDIR/.gitignore <<EOF
# Ignore the build and lib dirs
build
lib/*

# Ingore any executables
bin/*
EOF

#Ok, now we need a Makefile 

cat > $PRJ_TOPDIR/Makefile <<EOF
CC := g++  #This is the main compiler
RM := rm
SRCDIR := src
BUILDDIR := build
TARGET := bin/runner

SRCEXT := cpp
SOURCES := \$(shell find \$(SRCDIR) -type f -name *.\$(SRCEXT))
OBJECTS := \$(patsubst \$(SRCDIR)/%, \$(BUILDDIR)/%, \$(SOURCES:.\$(SRCEXT)=.o))
CFLAGS := -g # -Wall
LIB := 
INC := -Iinclude 

\$(TARGET): \$(OBJECTS)
	@echo " Linking ..."
	@echo " \$(CC) \$^ -o \$(TARGET) \$(LIB)"; \$(CC) \$^ -o \$(TARGET) \$(LIB)

\$(BUILDDIR)/%.o: \$(SRCDIR)/%.\$(SRCEXT)
	@mkdir -p \$(BUILDDIR)
	@echo " \$(CC) \$(CFLAGS) \$(INC) -c -o \$@ \$<"; \$(CC) \$(CF	) \$(IN	) -c -o \$@ \$< 

clean:
	@echo " Cleaning ..."
	@echo " \$(RM) -r \$(BUILDDIR) \$(TARGET)"; \$(RM) -r \$(BUILDDIR) \$(TARGET)

test:

.PHONY: clean
EOF

#Use git for code control 
git init $PRJ_TOPDIR >> /dev/null
cd $PRJ_TOPDIR
git add -A >> /dev/null
git commit -m "$PRJ_NAME created" >> /dev/null
cd -

exit 0
