#pragma once

#include <string>
#include <vector>
#include <map>
#include <sqlite/connection.hpp>
#include <sqlite/database_exception.hpp>

#define VERSION "2018-05-29"
#define AUTHOR  "w.maeda@neogenia.co.jp"

using namespace std;

namespace DBTool {

    struct MigrationEntry {
        string filepath;
        string version;
        string description;
        bool applied = false;

        MigrationEntry(string);
        MigrationEntry() {};

        string basename();
    };

    class Migrator
    {

    public:
        Migrator();
        ~Migrator();

    protected:
        sqlite::connection* conn = NULL;
        string database_name;
        map<string, MigrationEntry>* migrations = NULL;

        virtual void Open();

        virtual void Close();

    public:
        virtual void CreateDatabase(string name);

        virtual string GetCurrentDatabase();

        virtual void ChangeDatabase(string name);

        virtual void ReloadMigrations(string dir);

        virtual map<string, MigrationEntry> Status();

        virtual int Up();

        virtual void Reapply(string version);

        virtual int Down(int steps);

    };

}