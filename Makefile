stls = tiles.stl A.stl B.stl C.stl D.stl E.stl F.stl G.stl H.stl I.stl J.stl K.stl L.stl M.stl N.stl O.stl P.stl R.stl S.stl T.stl U.stl V.stl W.stl Y.stl Z.stl

SCAD=openscad
SCAD_OPTS=--hardwarnings

all: ${stls}

include $(wildcard *.deps)

tiles.stl: scrabble.scad
	$(SCAD) $(SCAD_OPTS) -m make -o $@ -D "all=true" -d $@.deps $<

blank.stl: scrabble.scad
	$(SCAD) $(SCAD_OPTS) -m make -o $@ -D "letter=undef" -d $@.deps $<

%.stl: scrabble.scad
	$(SCAD) $(SCAD_OPTS) -m make -o $@ -D "letter=\"$*\"" -d $@.deps $<

.PHONY: all clean

clean:
	rm -f $(wildcard *.stl) $(wildcard *.deps)
