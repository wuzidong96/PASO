SNAPROOT = /data/grad/dl013/software/Snap-2.4
GEOROOT = /data/grad/dl013/software/GeographicLib-1.45/install

CGEO = $(GEOROOT)/include
GEOLIB = $(GEOROOT)/lib

GLIB = glib-core
SNAP = snap-core
GLIBADV = glib-adv
SNAPADV = snap-adv
SNAPEXP = snap-exp

CGLIB = $(SNAPROOT)/$(GLIB)
CSNAP = $(SNAPROOT)/$(SNAP)

#copied from SNAP Makefile.config
CC = g++
CXXFLAGS += -std=c++98 -Wall
CXXFLAGS += -O3 -DNDEBUG
# turn on for crash debugging, get symbols with <prog> 2>&1 | c++filt
#CXXFLAGS += -g -rdynamic
CXXOPENMP = -fopenmp
LDFLAGS +=
LIBS += -lrt

#for  geographic
LIBS += -lGeographic

INC += -I$(CSNAP)
INC += -I$(CGLIB)
INC += -I$(CGEO)
LIBINC += -L$(GEOLIB)

SRCS = \
PASONodeData.cpp\
PASOEdgeData.cpp\
PASOSolution.cpp\
PASOUtil.cpp\
OBJS = $(SRCS:.cpp=.o)

SRCS_MAIN = $(SRCS) + main.cpp
OBJS_MAIN = $(OBJS) + main.o
SRCS_MAIN_22 = $(SRCS) + main_22_node.cpp
OBJS_MAIN_22 = $(OBJS) + main_22_node.o
	
## Main application file
TAR = \
	../main\
    ../main_22_node

all: $(TAR)

# COMPILE
#$(TAR): $(OBJS)
#	$(CC) $(CXXFLAGS) $(INC) $(LIBINC) $(LDFLAGS) $(CSNAP)/Snap.o $(OBJS) $(LIBS) -o $@ 
../main: $(OBJS_MAIN)
	$(CC) $(CXXFLAGS) $(INC) $(LIBINC) $(LDFLAGS) $(CSNAP)/Snap.o $(OBJS_MAIN) $(LIBS) -o $@     
../main_22_node: $(OBJS_MAIN_22)
	$(CC) $(CXXFLAGS) $(INC) $(LIBINC) $(LDFLAGS) $(CSNAP)/Snap.o $(OBJS_MAIN_22) $(LIBS) -o $@    

%.o: %.cpp
	$(CC) $(CXXFLAGS) $(INC) $(LIBINC) $(LDFLAGS) $(LIBS) -o $@ -c $<

clean:
	rm -f *.o $(TAR)

