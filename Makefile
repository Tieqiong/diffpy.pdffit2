########################################################################
# User variables:
#
# PYTHON_VERSION	version of Python used for compilation, e.g. "2.3"
#
# PYTHON_LIB_PATH       install directory for pdffit2 python module, must
#                       be add to PYTHONPATH if changed from default value
#
# BINDIR		install directory for command-line pdffit2
########################################################################

ifndef PYTHON_VERSION
PYTHON_VERSION = $(shell python -c 'import sys; print sys.version[:3]')
endif
PYTHON_LIB_PATH = /usr/lib/python$(PYTHON_VERSION)/site-packages
BINDIR = /usr/local/bin

########################################################################

INCLUDE = \
	  -I/usr/include/python$(PYTHON_VERSION) \
	  -Ilibpdffit2             \
	  -Ipdffit2module          \
	  -Ibuild -I.

DEFINES := $(shell python -c 'import setup; setup.printDefines()')

GSLLIBS := $(shell gsl-config --libs)

OPTIMFLAGS = -O3 -Wall -funroll-loops -ffast-math
DEBUGFLAGS = -gstabs+ -Wall

ifdef DEBUG
CPPFLAGS = $(DEBUGFLAGS) $(INCLUDE) $(DEFINES)
else
CPPFLAGS = $(OPTIMFLAGS) $(INCLUDE) $(DEFINES)
endif
	
OBJS = \
    build/fit.o \
    build/gaussj.o \
    build/math.o \
    build/metric.o \
    build/nrutil.o \
    build/output.o \
    build/parser.o \
    build/pdf.o \
    build/pdffit.o \
    build/pdflsmin.o \
    build/scatlen.o \
    build/stru.o \
    build/PointsInSphere.o \
    build/PeriodicTable.o \
    build/StringUtils.o \
    build/Atom.o \
    build/bindings.o \
    build/exceptions.o \
    build/misc.o \
    build/pdffit2module.o

PYMODULES = \
    build/pdffit2/__init__.py \
    build/pdffit2/version.py  \
    build/pdffit2/PdfFit.py

all: build/pdffit2 build/pdffit2/pdffit2module.so $(PYMODULES)

clean:
	rm -rf -- build

build/pdffit2/pdffit2module.so: $(OBJS)
	g++ -o $@ -shared $(OBJS) $(GSLLIBS)

build/pdffit2:
	mkdir -p build/pdffit2

install:
	mkdir -p -m 755 $(PYTHON_LIB_PATH)/pdffit2
	install -m 755 build/pdffit2module.so $(PYTHON_LIB_PATH)/pdffit2
	install -m 644 pdffit2/*.py $(PYTHON_LIB_PATH)/pdffit2
	python$(PYTHON_VERSION) \
	    /usr/lib/python$(PYTHON_VERSION)/compileall.py \
	    $(PYTHON_LIB_PATH)/pdffit2
	install -D -m 755 applications/pdffit2 $(BINDIR)/pdffit2

build/fit.o: libpdffit2/fit.cc
build/gaussj.o: libpdffit2/gaussj.cc
build/math.o: libpdffit2/math.cc
build/metric.o: libpdffit2/metric.cc
build/nrutil.o: libpdffit2/nrutil.cc
build/output.o: libpdffit2/output.cc
build/parser.o: libpdffit2/parser.cc
build/pdf.o: libpdffit2/pdf.cc
build/pdffit.o: libpdffit2/pdffit.cc
build/pdflsmin.o: libpdffit2/pdflsmin.cc
build/scatlen.o: libpdffit2/scatlen.cc
build/stru.o: libpdffit2/stru.cc
build/PointsInSphere.o: libpdffit2/PointsInSphere.cc
build/bindings.o: pdffit2module/bindings.cc
build/exceptions.o: pdffit2module/exceptions.cc
build/misc.o: pdffit2module/misc.cc
build/pdffit2module.o: pdffit2module/pdffit2module.cc

build/%.o : libpdffit2/%.cc
	g++ -c $(CPPFLAGS) -o $@ $<

build/%.o : pdffit2module/%.cc
	g++ -c $(CPPFLAGS) -o $@ $<

build/pdffit2/%.py : pdffit2/%.py
	cp -pv -- $< $@
