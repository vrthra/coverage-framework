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



## Adding a new project other than what is listed

* Ensure that it is reachable by bin/checkout
* Ensure that its dependencies are met by running mvn package and mvn test
  because we run maven offline
* Make sure that it is a green suite (or else the pit wont run)

## Adding a new coverage technique.

* Add the coverage to etc/coverage.txt
* Add the processing logic to bin/<technique>.do-report
* Add the report parsing to bin/<technique>.lastcov

```
make tag=myprojects coverage=<technique> suite=original
```

## Adding new test suites

* Generate your test suites and store the test suites in .backup/tests/<suite>/
* Be careful to store a copy of this some where else also. The clobber target wipes
  this directory
* Add the suite name to etc/suite.txt
* Run it with

```
make tag=myprojects coverage=<technique> suite=<suite>
```

## Parallel building

The suite is written in such a way that there is no interaction between different
projects so multiple projects can proceed in parallel. However, many coverage tools
assume exclusive use of project directory. Hence running different suites at the same
time on same projects, or running different coverage techniques on the same projects
at the same time is not advisable, especially for those that insert probes into classes.

For the same reason is also advised to 'make clean' before switching between coverage
techniques, or test suites. But this is not necessary for switching between projects.
