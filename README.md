# Invocation
   
set ANDROID_HOME=/scratch/ext_src/android-sdk-linux
set PATH=$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$PATH

fake clean-<project>
/usr/bin/timeout -s 9 $((3600*12))s stdbuf -oL fake <tsttype>-<project> 

env tsttype=original score=emma ./bin/run.sh