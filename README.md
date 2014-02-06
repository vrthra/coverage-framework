# USAGE


## Pre-requisites

### Required

```
  GNU Make >= 4
  Maven >= 3.0
  JDK >= 7.0
```

### Optional

* The R 3.0 environment, optionally RStudio.
* Android environment. (sdk, platform-tools)

### Environment

This has been developed and tested under the following environments

* Redhat 6.5
* Ubuntu 10 through 13

While other systems should work, it might take a little bit of tweaking
command lines used.

### Really Basic usage

You are supposed to have atleast the following things ready.

#### Required stuff

* All the java projects we distribute under a directory,
  say <coverage-root>/db
* The maven dependencies m2.tar.gz that we distribute.

#### Procedure

* Extract the m2 to your maven dependency directory (usually at your
$HOME directory, but you can move it to any place by meddling with
the <settings<localRepository>> tag in ~/.m2/settings.xml)

```
cd ~; zcat <path>/m2.tar.gz | tar -xvpf -
```

#### Prepare the projects
Here we assume that coverage-root is the base directory for your
experiment

```
mkdir -p ~/coverage-root/db
cd coverage-root/db
rsync -avz <path-to-projects>/ ./db/
```

#### Checkout this repository

```
cd ~/coverage-root;
git clone git@bitbucket.org:rgopinath/coverage-framework.git
```


#### Run Analysis
Ensure that you have a list of projects you want to measure coverage of.
From here on, we assume that you are in ~/coverage-root/coverage-framework
directory

```
cd ~/covrage-root/coverage-framework
(cd ../db; ls -1 ) > myprojects.txt
```

Run Emma

```
make tag=myprojects coverage=emma suite=original
```

Once it completes, check the results

```
./bin/show-coverage emma
```


## Basic Use

keep a list of projects, one per line under myprojects.txt in the root
directory. Make sure that your repository is accessible by checking
bin/checkout . If it is not, then modify bin/checkout as you see fit
so that it will dump the project contents under projects/ directory.
The projects are expected to contain one pom.xml file in their root
directory, and an src directory, which contains test and main.

You can run a basic coverage using emma by

```
fake original-all coverage=emma tag=myprojects
```

Note that tag is the filename (without the .txt) that you previously
used for projects.
