#include <iostream>
#include "migrator.h"

using namespace std;
using namespace DBTool;

int main(int argc, const char *args[])
{
    Migrator migrator;

    try {

        migrator.ChangeDatabase("main");

        auto status = migrator.Status();

    }
    catch (runtime_error& e) {
        cerr << e.what() << std::endl;;
    }
    catch (string& e) {
        cerr << e;
    }

    return 0;
}
