#include "migrator.h"
#include <sqlite/execute.hpp>
#include <sqlite/query.hpp>
#include <algorithm>
#include <map>
#include <fstream>
#include <boost/filesystem.hpp>
#include <boost/range/iterator_range.hpp>

#define DEFAULT_DB_FILE_EXT ".db"
#define TABLE_NAME_FOR_MANAGEMENT "SCHEMA_VERSIONS"

namespace fs = boost::filesystem;

using namespace DBTool;

static string _GetDatabaseFilePath(string name) {
    auto pos = name.find_first_of(':');
    if (pos < 0) {
        auto pos = name.find_last_of('.');
        if (pos < 0) {
            return name + DEFAULT_DB_FILE_EXT;
        }
    }
    return name;
}

static void _InitDB(sqlite::connection* conn) {
    try {
        sqlite::execute(*conn, "CREATE TABLE " TABLE_NAME_FOR_MANAGEMENT "(id TEXT PRIMARY KEY);", true);
    }
    catch (exception& e) {
        string message = e.what();
        if (message != "table " TABLE_NAME_FOR_MANAGEMENT " already exists") throw;
    }
}

MigrationEntry::MigrationEntry(string file_name) {
    this->file_name = file_name;
    auto pos = file_name.find_first_of('_');
    this->version = file_name.substr(0, pos);
    this->description = file_name.substr(pos + 1);
    replace(this->description.begin(), this->description.end(), '_', ' ');
}

static vector<string> _EnumerateFiles(string dir) {
    vector<string> result;
    const fs::path path(dir);

    for (const auto& e : boost::make_iterator_range(fs::directory_iterator(path), { })) {
        if (!fs::is_directory(e)) {
            result.push_back(e.path().filename().string());
        }
    }
    return result;
}

static void _EnumerateMigrationEntries(string dir, map<string, MigrationEntry>& list) {
    for (auto file : _EnumerateFiles(dir)) {
        MigrationEntry entry(file);
        list.insert(make_pair(entry.version, entry));
    }
}


static void _CheckAppliedVersionsFromDB(sqlite::connection* conn, map<string, MigrationEntry>& migrations) {
    sqlite::query q(*conn, "SELECT id FROM " TABLE_NAME_FOR_MANAGEMENT " ORDER BY id");

    auto result = q.get_result();
    while (result->next_row()) {
        auto version = result->get_string(0);
        if (migrations.count(version) > 0)
        {
            // 適用済みとしてマーク
            auto& entry = migrations.at(version);
            entry.applied = true;
        }
        else {
            // 対応するファイルがないようなのでエントリーを１つ作って追加しておく
            MigrationEntry entry;
            entry.version = version;
            entry.description = "??? NOT FOUND ???";
            migrations.insert(make_pair(version, entry));
        }
    }
}

class MigrationFile {
    string filename;
    char* buff = NULL;
    char* pos_up;
    char* pos_down;
public:
    MigrationFile(string filename) { this->filename = filename; }
    ~MigrationFile() { Free(); }

    void Load();

    const char* UpSection() { return pos_up; }
    const char* DownSection() { return pos_down; }

protected:
    void Check();
    void Free();
};

void MigrationFile::Load() {
    Free();
    std::ifstream Input(filename, std::ios::in | std::ios::binary);
    auto size = Input.seekg(0, std::ios::end).tellg();
    buff = new char[size];
    Input.seekg(0, std::ios::beg).read(buff, size);
    Check();
}

void MigrationFile::Check() {
    pos_up = strstr(buff, "-- [UP]");
    pos_down = strstr(buff, "-- [DOWN]");

    if (!pos_up) throw runtime_error("[UP]セクションが見つかりません。file=" + filename);
    if (!pos_down) throw runtime_error("[DOWN]セクションが見つかりません。file=" + filename);

    if (pos_up > pos_down) {
        *(pos_up - 1) = '\0';
    }
    if (pos_up < pos_down) {
        *(pos_down - 1) = '\0';
    }
}

void MigrationFile::Free() {
    if (buff) {
        delete[] buff;
        pos_up = pos_down = buff = NULL;
    }
}

static void _ApplyMigration(sqlite::connection* conn, MigrationEntry& entry) {
    if (entry.file_name.empty()) throw runtime_error("対応するファイルがありません。");

    MigrationFile file(entry.file_name);
    file.Load();

    auto sql = file.UpSection();

    printf("********** UP %s **********n", entry.version.c_str());
    printf("%s\n", sql);
    sqlite::execute(*conn, sql);
 
    sqlite::execute ins(*conn, "INSERT INTO " TABLE_NAME_FOR_MANAGEMENT " VALUES(?);");
    ins % entry.version;
    ins();
}

static void _UnapplyMigration(sqlite::connection* conn, MigrationEntry& entry) {
   if (entry.file_name.empty()) throw runtime_error("対応するファイルがありません。");

    MigrationFile file(entry.file_name);
    file.Load();

    auto sql = file.DownSection();

    printf("********** DOWN %s **********n", entry.version.c_str());
    printf("%s\n", sql);
    sqlite::execute(*conn, sql);
 
    sqlite::execute del(*conn, "DELETE FROM " TABLE_NAME_FOR_MANAGEMENT " WHERE ID=?;");
    del % entry.version;
    del();
}

Migrator::Migrator()
{
    database_name = "main";
}

Migrator::~Migrator()
{
}

void Migrator::Open() {
    Close();
    auto filepath = _GetDatabaseFilePath(database_name);
    conn = new sqlite::connection(filepath);
    _InitDB(conn);
}

void Migrator::Close() {
    if (conn) {
        delete conn;
        conn = NULL;
    }
}

void Migrator::ReloadMigrations(string dir) {
    if (migrations == NULL) {
        migrations = new map<string, MigrationEntry>();
    }
    else {
        migrations->clear();
    }
    _EnumerateMigrationEntries(dir, *migrations);
}

void Migrator::CreateDatabase(string name) {
    ChangeDatabase(name);
}

string Migrator::GetCurrentDatabase() {
    return database_name;
}

void Migrator::ChangeDatabase(string name) {
    Close();
    database_name = name;
    Open();
}

map<string, MigrationEntry> Migrator::Status() {
    auto dup = *migrations;
    _CheckAppliedVersionsFromDB(conn, dup);
    return dup;
}

void Migrator::Up() {
    auto status = Status();
    for (auto& pair : status) {
        if (pair.second.applied == false) {
            _ApplyMigration(conn, pair.second);
        }
    }
}

void Migrator::Reapply(string version) {
    auto status = Status();
    if (status.count(version) == 0) {
        throw runtime_error("指定されたマイグレーションは存在しません。version=" + version);
    }
    auto& entry = status.at(version);
    if (entry.applied) {
        _UnapplyMigration(conn, entry);
    }
    _ApplyMigration(conn, entry);
}

void Migrator::Down(int steps) {
    auto status = Status();
    for (auto i = status.rbegin(); i != status.rend(); i++) {
        auto& entry = i->second;
        if (entry.applied) {
            _UnapplyMigration(conn, entry);
        }
    }
}
