#!/bin/bash
if [ "$JAVA_HOME" = "" ] ; then
  JAVA_HOME=`which java 2>/dev/null || whence java`
  JAVA_HOME=`dirname "$JAVA_HOME"`/..
fi

if [ "$JAVANCSS_HOME" = "" ] ; then
  # try to find JAVANCSS

  ## resolve links - $0 may be a link to jacob's home
  PRG=$0
  progname=`basename $0`

  while [ -h "$PRG" ] ; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '/.*' > /dev/null; then
	PRG="$link"
    else
	PRG="`dirname $PRG`/$link"
    fi
  done

  JAVANCSS_HOME=`dirname "$PRG"`
fi

ORIG_CLASSPATH=${CLASSPATH}
CLASSPATH=${JAVANCSS_HOME}/classes
CLASSPATH=${CLASSPATH}:${JAVANCSS_HOME}/lib/javancss.jar
CLASSPATH=${CLASSPATH}:${JAVANCSS_HOME}/lib/ccl.jar
CLASSPATH=${CLASSPATH}:${JAVANCSS_HOME}/lib/jhbasic.jar

# in case jdk 1.1 is used these archives are needed
# otherwise they don't do any harm
CLASSPATH=${CLASSPATH}:${JAVA_HOME}/lib/classes.zip
CLASSPATH=${CLASSPATH}:${SWING_HOME}/swingall.jar

CLASSPATH=${CLASSPATH}:${ORIG_CLASSPATH}

$JAVA_HOME/bin/java -classpath $CLASSPATH javancss.Main -recursive -function $@ | grep '^ ' | awk '{print $5,$2}'
