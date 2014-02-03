#$(if $(filter $(MAKE_VERSION), 3.82),, $(error Use fake current $(MAKE_VERSION)))

.PHONY: checkout all clobber clean $(checkout.all)
.SECONDARY: $(addprefix projects/,$(names))

root:=$(CURDIR)

myprojects=$(root)/etc/projects.txt

types=$(shell $(root)/bin/cat $(root)/etc/types.txt)
names=$(shell $(root)/bin/cat $(shell $(root)/bin/greadlink -f $(myprojects)))
tag=x #$(shell gdate +%F,%R)
maxtimeout=3600

mydirs=projects build .tmp .home logs logs/files build/emma build/mockit build/pit build/cobertura build/codecover db/files db/cloc

all:
	echo $(names)
	@echo use 'make <type>-<project>'
	@echo projects = $(names)
	@echo types = $(types)

runtests: $(types)
	@echo $@ done.

checkout: $(addprefix checkout-,$(names))
	@echo $@ done.

checkout-%: | projects/%/.checkedout
	@echo $@ done.

$(mydirs): ;  mkdir -p $@

projects/%/.checkedout: | $(mydirs)
	env root=$(root) $(root)/bin/checkout $*
	env root=$(root) $(root)/bin/initupdate $*
	touch projects/$*/.checkedout

clean: $(addprefix clean-,$(names)) logs
	truncate -s 0 logs/log.txt

clean-%:
	cd projects/$* && $(MAKE) clean

clobber-%: | projects/%/.git
	env root=$(root) $(root)/bin/clean $*
	touch projects/$*/.checkedout

clobber:
	echo > logs/log.txt
	rm -rf logs/*.log
	rm -rf .tmp .home build/emma build/pit build/mockit build/codecover build/cobertura
	mkdir -p $(mydirs)

dirs: .tmp .home logs/files projects build/emma build/pit build/mockit build/codecover build/cobertura

#-----------------------------------------------------------------

define namegen =
all-$1 : $(addsuffix -$(1),$(types))
	@echo $$(@) done.
endef

define testgen =
$1-all : $(addprefix $(1)-,$(names))
	@echo $$(@) done.

$1-% : projects/%/.$(1).done
	@echo $$(@) done.

%/.$1.done : | %/.git dirs
	$$(root)/bin/cleantmp
	@echo "`date +'%r'` to `date --date '1 hour' +'%r'`"
	@echo timeout=$$(maxtimeout) \
				tag=$$(tag) \
				root=$$(root) \
				score=$$(score) \
				type=$(1) \
				| sed -e "s/ \+/\n/g" > $$(*)/.env
	- $$(MAKE) -C $$(*) -w `cat $$(*)/.env` runtests 2>&1 | \
		sed -e '/^[ ]*$$$$/d' -e "s#^#$$(*F)-$(1): #g" | \
			tr -dc '[:print:][:space:]' | \
			tee logs/$(1).$$(shell basename $$(*)).$$(tag).log; echo $$$$SECONDS \
	@echo ended at `date +'%r'`
	@echo =============================================
endef

$(foreach var,$(types),$(eval $(call testgen,$(var))))
$(foreach var,$(names),$(eval $(call namegen,$(var))))

#-----------------------------------------------------------------

