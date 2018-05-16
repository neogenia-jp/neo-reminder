# Makefile

# プログラム名とオブジェクトファイル名
PROGRAM = CppBackendSvc.out
MAIN_OBJ = main.o
OBJS = connection.o functions.o
TEST_OBJS = tests/test_main.o tests/test_functions.o tests/test_sample.o

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
$(PROGRAM): $(OBJS) $(MAIN_OBJ)
	$(CXX) $(CXXFLAGS) $(CFLAGS) -o $(PROGRAM) $^ $(LIBS)

# サフィックスルール
.cpp.o:
	$(CXX) $(CXXFLAGS) $(CFLAGS) -o $@ -c $<

# ファイル削除用ターゲット
.PHONY: clean
clean:
	$(RM) $(PROGRAM) $(MAIN_OBJ) $(OBJS) $(TEST_OBJS)

test: $(OBJS) $(TEST_OBJS)
	$(CXX) $(CXXFLAGS) $(CFLAGS) -o test_main $^ $(LIBS) -lboost_unit_test_framework

autotest: test
	test_main