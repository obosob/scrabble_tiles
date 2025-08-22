LANGFILES = $(wildcard languages/*.lang)
LANGS = $(basename $(notdir $(LANGFILES)))

SCAD=openscad -m make -q
SCAD_OPTS=--hardwarnings

all: | $(addprefix all_,$(LANGS))

include $(wildcard *.deps)

$(addprefix build/,$(LANGS)): | build
	mkdir $@

build:
	mkdir $@

build/%.scad: languages/%.lang | build
	@echo "$<: Generate $@"
	@grep -v '^#\|^\s*$$' $< | awk -F'	' 'BEGIN {printf "dict = ["} END {printf "];\nuse <../scrabble.scad>\nbuild(dict);\n"} {printf "\n[\"%s\", %d, %d],", $$1, $$2, $$3}' > $@

build/%/tiles.stl: build/%.scad | build/%
	@echo "$<: Build $@"
	@$(SCAD) $(SCAD_OPTS) -o $@ -D "all=true" -d $@.deps $<

build/%/blank.stl: build/%.scad | build/%
	@echo "$<: Build $@"
	@$(SCAD) $(SCAD_OPTS) -o $@ -D "letter=\"[blank]\"" -d $@.deps $<

define LANG_RULE
build/$(1)/%.stl: build/$(1).scad | build/$(1)
	@echo "$$<: Build $$@"
	@$$(SCAD) $$(SCAD_OPTS) -o $$@ -D "letter=\"$$*\"" -d $$@.deps $$<

.PHONY:: clean_$(1) all_$(1)

clean_$(1):
	rm -f build/$(1).scad $$(wildcard build/$(1)/*.stl) $$(wildcard build/$(1)/*.deps)

all_$(1): build/$(1)/blank.stl build/$(1)/tiles.stl $(shell grep -v '^#\|^\s*$$' languages/$(1).lang | awk -F'	' '$$1 != "[blank]" {printf "build/$(1)/%s.stl ", $$1}' )

endef

$(foreach LANG,$(LANGS),$(eval $(call LANG_RULE,$(LANG))))

.PHONY:: all clean

clean: | $(addprefix clean_,$(LANGS))
