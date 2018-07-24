# Makefile
# copyright 2013, Stefan Beller
# This file is also public domain.

#OBJS = MaxRectsBinPackTest/BinPack.o  MaxRectsBinPack.o  Rect.o
OBJS = src/scheduler.o  src/MaxRectsBinPack.o  src/Rect.o
CXX = g++
# If you want to compile it faster try these options (gcc only)
CPPFLAGS = -march=native -mtune=native -Ofast -g -flto -Wall -Wextra -std=c++11
LDFLAGS = -march=native -mtune=native -Ofast -g -flto -fwhole-program

all: $(OBJS)
	$(CXX) $(CPPFLAGS) $(LDFLAGS) $(OBJS) -o bin/scheduler
