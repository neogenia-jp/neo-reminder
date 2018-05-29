#include "migrator.h"
#include <sqlite/execute.hpp>
#include <sqlite/query.hpp>
#include <algorithm>
#include <map>
#include <iostream>
#include <fstream>
#include <boost/filesystem.hpp>
#include <boost/range/iterator_range.hpp>

#define DEFAULT_DB_FILE_EXT ".db"
#define TABLE_NAME_FOR_MANAGEMENT "SCHEMA_VERSIONS"

#define SECTION_SEPARATER_UP   "-- [UP]"
#define SECTION_SEPARATER_DOWN "-- [DOWN]"


namespace fs = boost::filesystem;

using namespace DBTool;

static string _GetDatabaseFilePath(string name) {
    auto pos = name.find_first_of(':');
    if (pos == string::npos) {
        pos = name.find_last_of('.');
        if (pos == string::npos) {
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

MigrationEntry::MigrationEntry(string path) {
    this->filepath = path;
    auto file_name = basename();
    auto pos = file_name.find_first_of('_');
    this->version = file_name.substr(0, pos);
    this->description = file_name.substr(pos + 1);
    replace(this->description.begin(), this->description.end(), '_', ' ');
}

string MigrationEntry::basename() {
    fs::path p = this->filepath;
    return p.stem().c_str();
}

static vector<fs::path> _EnumerateFiles(string dir) {
    vector<fs::path> result;
    const fs::path path(dir);

    for (const auto& e : boost::make_iterator_range(fs::directory_iterator(path), { })) {
        if (!fs::is_directory(e)) {
            result.push_back(e.path());
        }
    }
    return result;
}

static void _EnumerateMigrationEntries(string dir, map<string, MigrationEntry>& list) {
    for (auto& path : _EnumerateFiles(dir)) {
        MigrationEntry entry(path.string());
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
    fs::path filepath;
    char* buff = NULL;
    char* pos_up;
    char* pos_down;
public:
    MigrationFile(fs::path filepath) { this->filepath = filepath; }
    ~MigrationFile() { Free(); }

    string filename() { return filepath.filename().string(); }
    void Load();

    const char* UpSection() { return pos_up; }
    const char* DownSection() { return pos_down; }

protected:
    void Check();
    void Free();
};

void MigrationFile::Load() {
    Free();
    std::ifstream ifs(filepath.c_str(), std::ios::in | std::ios::binary);
    auto size = ifs.seekg(0, std::ios::end).tellg();
    buff = new char[size];
    ifs.seekg(0, std::ios::beg).read(buff, size);
    Check();
}

void MigrationFile::Check() {
    pos_up = strstr(buff, SECTION_SEPARATER_UP);
    pos_down = strstr(buff, SECTION_SEPARATER_DOWN);

    if (!pos_up) throw runtime_error("[UP]セクションが見つかりません。file=" + filename());
    if (!pos_down) throw runtime_error("[DOWN]セクションが見つかりません。file=" + filename());

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
    if (!fs::exists(entry.filepath)) throw runtime_error("対応するファイルがありません。 " + entry.filepath);

    MigrationFile file(entry.filepath);
    file.Load();

    auto sql = file.UpSection();

    cout << "********** UP " << entry.version.c_str() << " **********" << endl
         << sql << endl;

    try {
        sqlite::execute(*conn, sql, true);
    }
    catch (std::exception ex) {
        cerr << "########## SQL ERROR ##########" << endl
            << ex.what() << endl;
        throw;
    }

    sqlite::execute ins(*conn, "INSERT INTO " TABLE_NAME_FOR_MANAGEMENT " VALUES(?);");
    ins % entry.version;
    ins();
}

static void _UnapplyMigration(sqlite::connection* conn, MigrationEntry& entry) {
    if (!fs::exists(entry.filepath)) throw runtime_error("対応するファイルがありません。 " + entry.filepath);

    MigrationFile file(entry.filepath);
    file.Load();

    auto sql = file.DownSection();

    cout << "********** DOWN " << entry.version.c_str() << " **********" << endl
         << sql << endl;

    try {
        sqlite::execute(*conn, sql, true);
    }
    catch (std::exception ex) {
        cerr << "########## SQL ERROR ##########" << endl
            << ex.what() << endl;
        throw;
    }
 
    sqlite::execute del(*conn, "DELETE FROM " TABLE_NAME_FOR_MANAGEMENT " WHERE ID=?;");
    del % entry.version;
    del();
}

Migrator::Migrator()
{
    database_name = "";
}

Migrator::~Migrator()
{
}

void Migrator::Open() {
    Close();
    if (database_name.empty()) throw runtime_error("データベースが指定されていません。");
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
    if (!migrations) throw runtime_error("マイグレーションファイルがロードされていません");
    auto dup = *migrations;
    _CheckAppliedVersionsFromDB(conn, dup);
    return dup;
}

int Migrator::Up() {
    auto count = 0;
    auto status = Status();
    for (auto& pair : status) {
        if (pair.second.applied == false) {
            _ApplyMigration(conn, pair.second);
            count++;
        }
    }
    return count;
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

int Migrator::Down(int steps) {
    auto count = 0;
    auto status = Status();
    for (auto i = status.rbegin(); i != status.rend(); i++) {
        auto& entry = i->second;
        if (entry.applied) {
            _UnapplyMigration(conn, entry);
            count++;
            if (count >= steps) break;
        }
    }
    return count;
}
