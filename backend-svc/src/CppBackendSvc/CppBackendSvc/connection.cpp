#include <cstdio>
#include <fstream>
#include "main.h"

using namespace std;

sqlite::connection* init_db(string name) {
    try {
        auto con = new sqlite::connection("/mnt/CppBackendSvc/"+name+".db");
        return con;
    }
    catch (std::exception const & e) {
        std::cerr << "An error occurred: " << e.what() << std::endl;
    }
    return NULL;
}

sqlite::connection* init_db() {
	return init_db("main");
}

void close_db(sqlite::connection* conn) {
    delete conn;
}
void test(sqlite::connection* conn) {
    reminder_element elem;
    elem.title = "aaa";
    elem.memo = "memo";

    elem.save_or_update(conn);
}
