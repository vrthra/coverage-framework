#$(if $(filter $(MAKE_VERSION), 3.82),, $(error Use fake current $(MAKE_VERSION)))

.PHONY: checkout all clobber clean $(checkout.all)
.SECONDARY: $(addprefix projects/,$(projects))

root:=$(CURDIR)

myprojects=$(root)/.projects

suite=$(shell $(root)/bin/cat $(root)/etc/suite.txt)
projects=$(shell $(root)/bin/projects)
coverages=$(shell $(root)/bin/cat $(root)/etc/coverage.txt)
coverage=emma #default.


tag=x #$(shell gdate +%F,%R)
maxtimeout=3600
coveragedirs=$(add-prefix,build/,$(coverages))

mydirs=projects build .tmp .home logs build/$(coverage)

all:
	@echo $(projects)
	@echo use 'make <suite>-<project>'
	@echo projects = $(projects)
	@echo suite = $(suite)

runtests: $(suite)
	@echo $@ done.

checkout: $(addprefix checkout-,$(projects))
	@echo $@ done.

checkout-%: | projects/%/.checkedout
	@echo $@ done.

$(mydirs): ;  mkdir -p $@

projects/%/.checkedout: | $(mydirs)
	$(root)/bin/new $*
	touch projects/$*/.checkedout

clean: $(addprefix clean-,$(projects)) logs
	truncate -s 0 logs/log.txt

clean-%:
	cd projects/$* && $(MAKE) root=$(root) clean

clobber-%: | projects/%/.git
	env root=$(root) $(root)/bin/clean $*
	touch projects/$*/.checkedout

clobber:
	echo > logs/log.txt
	rm -rf logs/*.log
	echo rm -rf .tmp .home $(coveragedirs)

dirs: .tmp .home projects build/$(coverage)

#-----------------------------------------------------------------

define namegen =
all-$1 : $(addsuffix -$(1),$(suite))
	@echo $$(@) done.
endef

define testgen =
$1-all : $(addprefix $(1)-,$(projects))
	@echo $$(@) done.

$1-% : projects/%/.$(1).done
	@echo $$(@) done.

%/.$1.done : | %/.checkedout dirs
	$$(root)/bin/cleantmp
	@echo "`date +'%r'` to `date --date '1 hour' +'%r'`"
	@echo timeout=$$(maxtimeout) \
				tag=$$(tag) \
				root=$$(root) \
				coverage=$$(coverage) \
				suite=$(1) \
				| sed -e "s/ \+/\n/g" > $$(*)/.env
	- /usr/bin/timeout -s 9 $$$$((3600*12))s stdbuf -oL $$(MAKE) -C $$(*) -w `cat $$(*)/.env` runtests
	@echo ended at `date +'%r'`
	@echo =============================================
endef

#		$$(root)/bin/cleanout $$(*F)-$(1) | \
#			tee logs/$(1).$$(shell basename $$(*)).$$(tag).log; echo $$$$SECONDS \
# 2>&1 | \

$(foreach var,$(suite),$(eval $(call testgen,$(var))))
$(foreach var,$(projects),$(eval $(call namegen,$(var))))

#-----------------------------------------------------------------

