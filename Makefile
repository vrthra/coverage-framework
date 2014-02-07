#$(if $(filter $(MAKE_VERSION), 3.82),, $(error Use fake current $(MAKE_VERSION)))

.PHONY: checkout all clobber clean $(checkout.all)
.SECONDARY: $(addprefix projects/,$(projects))

root:=$(CURDIR)

tag=x #$(shell gdate +%F,%R)
suite=$(shell $(root)/bin/cat $(root)/etc/suite.txt)
projects=$(shell $(root)/bin/projects $(tag))
coverages=$(shell $(root)/bin/cat $(root)/etc/coverage.txt)
coverage=emma #default.


maxtimeout=3600
coveragedirs=$(add-prefix,build/,$(coverages))

mydirs=projects build .tmp .data .home logs build/$(coverage)

all:
	@echo $(projects)
	@echo use 'make <suite>-<project>'
	@echo projects = $(projects)
	@echo suite = $(suite)

runtests: $(suite)
	@echo $@ done.

checkout: $(addprefix checkout-,$(projects))
	@echo $@ done.

checkout-%: | projects/%/._.checkedout
	@echo $@ done.

$(mydirs): ;  @mkdir -p $@

projects/%/._.checkedout: | $(mydirs)
	$(root)/bin/new $* >> logs/checkout.log 2>&1
	$(root)/bin/jncss-getfn.rb projects/$*/src/main > projects/$*/.info.functions
	$(root)/bin/jncss-getclass.rb projects/$*/src/main > projects/$*/.info.classes
	@touch $@

clean: $(addprefix clean-,$(projects)) logs
	truncate -s 0 logs/log.txt

clean-%:
	cd projects/$* && $(MAKE) root=$(root) clean || true

clobber-%: | projects/%/.git
	env root=$(root) $(root)/bin/clean $*
	@touch projects/$*/._.checkedout

clobber:
	@echo "# use '| bash' to actually do it."
	@echo truncate -s 0 logs/log.txt
	@echo rm -rf logs/*.log
	@echo rm -rf .backup
	@echo rm -rf projects/*

dirs: .tmp .data .home projects build/$(coverage)

#-----------------------------------------------------------------

define namegen =
all-$1 : $(addsuffix -$(1),$(suite))
	@echo $$(@) done.
endef

define testgen =
$1-all : $(addprefix $(1)-,$(projects))
	@echo timeout=$$(maxtimeout) \
				tag=$$(tag) \
				root=$$(root) \
				coverage=$$(coverage) \
				suite=$(1) \
				| sed -e "s/ \+/\n/g" > .env
	@echo $$(@) done.

$1-% : projects/%/.$(1).done
	@echo $$(@) done.

%/.$1.done : | %/._.checkedout dirs
	@echo `date +'%r'`
	$$(root)/bin/cleantmp
	@echo timeout=$$(maxtimeout) \
				tag=$$(tag) \
				root=$$(root) \
				coverage=$$(coverage) \
				suite=$(1) \
				| sed -e "s/ \+/\n/g" > $$(*)/.env
	- $$(root)/bin/timeit $$(maxtimeout)s $$(*) $$(MAKE) -C $$(*) -w `cat $$(*)/.env` runtests
	@echo ended at `date +'%r'`
	@echo =============================================
endef

$(foreach var,$(suite),$(eval $(call testgen,$(var))))
$(foreach var,$(projects),$(eval $(call namegen,$(var))))

#-----------------------------------------------------------------

