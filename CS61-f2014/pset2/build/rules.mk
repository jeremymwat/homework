GCC ?= $(shell if gcc-mp-4.8 --version | grep gcc >/dev/null; then echo gcc-mp-4.8; \
	elif gcc-mp-4.7 --version | grep gcc >/dev/null; then echo gcc-mp-4.7; \
	else echo gcc; fi 2>/dev/null)

CFLAGS = -std=gnu99 -m32 -W -Wall -g
DEPCFLAGS = -MD -MF $(DEPSDIR)/$*.d -MP
LDFLAGS =
LIBS =

DEPSDIR := .deps
BUILDSTAMP := $(DEPSDIR)/rebuildstamp
DEPFILES := $(wildcard $(DEPSDIR)/*.d)
ifneq ($(DEPFILES),)
include $(DEPFILES)
endif

# choose a C compiler
ifeq ($(PREFER_GCC),)
PREFER_GCC := $(DEP_PREFER_GCC)
endif
ifeq ($(PREFER_GCC),1)
CC = $(shell if $(GCC) --version | grep gcc >/dev/null; then echo $(GCC); \
	else echo clang; fi 2>/dev/null)
else
CC = $(shell if clang --version | grep LLVM >/dev/null; then echo clang; \
	else echo $(GCC); fi 2>/dev/null)
endif
CLANG := $(shell if $(CC) --version | grep LLVM >/dev/null; then echo 1; else echo 0; fi)

ifneq ($(DEP_CC),$(CC) $(CPPFLAGS) $(CFLAGS) $(DEPCFLAGS) $(O))
DEP_CC := $(shell mkdir -p $(DEPSDIR); echo >$(BUILDSTAMP); echo "DEP_CC:=$(CC) $(CPPFLAGS) $(CFLAGS) $(DEPCFLAGS) $(O)" >$(DEPSDIR)/_cc.d; echo "DEP_PREFER_GCC:=$(PREFER_GCC)" >>$(DEPSDIR)/_cc.d)
endif

V = 0
ifeq ($(V),1)
run = $(1) $(3)
else
run = @$(if $(2),/bin/echo " " $(2) $(3) &&,) $(1) $(3)
endif
runquiet = @$(1) $(3)

# Quiet down make output for stdio versions.
# If the user runs 'make all' or 'make check', don't provide a separate
# link line for every stdio-% target; instead print 'LINK STDIO VERSIONS'.
ifneq ($(filter all check check-%,$(or $(MAKECMDGOALS),all)),)
DEP_MESSAGES := $(shell mkdir -p $(DEPSDIR); echo LINK STDIO VERSIONS >$(DEPSDIR)/stdio.txt)
STDIO_LINK_LINE = $(shell cat $(DEPSDIR)/stdio.txt)
else
STDIO_LINK_LINE = LINK $@
endif

$(DEPSDIR)/stamp $(BUILDSTAMP):
	$(call run,mkdir -p $(@D))
	$(call run,touch $@)

always:
	@:

.PHONY: always
