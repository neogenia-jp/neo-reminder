#pragma once

#include <string>
#include <vector>
#include <map>
#include <sqlite/connection.hpp>
#include <sqlite/database_exception.hpp>

using namespace std;

namespace DBTool {

    struct MigrationEntry {
        string file_name;
        string version;
        string description;
        bool applied = false;

        MigrationEntry(string file_name);
        MigrationEntry() {};
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

        virtual void ReloadMigrations(string dir);

    public:
        virtual void CreateDatabase(string name);

        virtual string GetCurrentDatabase();

        virtual void ChangeDatabase(string name);

        virtual map<string, MigrationEntry> Status();

        virtual void Up();

        virtual void Reapply(string version);

        virtual void Down(int steps);

    };

}