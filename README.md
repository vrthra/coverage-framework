# USAGE


## Pre-requisites

### Required

  GNU Make >= 4
  Maven >= 3.0
  JDK >= 7.0

### Optional

  The R 3.0 environment, optionally RStudio.
  Android environment. (sdk, platform-tools)

## Basic Use

## To start, place

fake clean-<project>
/usr/bin/timeout -s 9 $((3600*12))s stdbuf -oL fake <suite>-<project> 

fake original-all coverage=pit
fake original-bank coverage=pit
