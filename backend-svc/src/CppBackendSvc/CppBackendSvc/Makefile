# Makefile

# プログラム名とオブジェクトファイル名
PROGRAM = CppBackendSvc.out
OBJS = main.o functions.o

# 定義済みマクロの再定義
CC = gcc
#CFLAGS = -Wall -O2
CFLAGS = -Wall  -g -O0
#CXXFLAGS = -std=c++11
CXXFLAGS = -std=c++11
LIBS =  -lvsqlitepp

# サフィックスルール適用対象の拡張子の定義
.SUFFIXES: .cpp .o

# プライマリターゲット
$(PROGRAM): $(OBJS)
	$(CXX) $(CXXFLAGS) $(CFLAGS) -o $(PROGRAM) $^ $(LIBS)

# サフィックスルール
.cpp.o:
	$(CXX) $(CXXFLAGS) $(CFLAGS) -c $<

# ファイル削除用ターゲット
.PHONY: clean
clean:
	$(RM) $(PROGRAM) $(OBJS)
