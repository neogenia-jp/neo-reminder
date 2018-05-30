#include <iostream>
#include <cstdio>
#include <boost/algorithm/string/classification.hpp> // is_any_of
#include <boost/algorithm/string/split.hpp>
#include <boost/filesystem.hpp>
#include "migrator.h"

using namespace std;
using namespace DBTool;

namespace fs = boost::filesystem;

struct ExitException : runtime_error { 
    ExitException(const char* msg) : runtime_error(msg) { }
};

struct FuncTableEntry
{
    void(*func)(Migrator& m, vector<string>&);
    const char* description_for_args;
    const char* description_for_command;
};
static map<string, FuncTableEntry> _function_table;
	
struct regist {
    regist(const char* name, void(*f)(Migrator& m, vector<string>&), const char* description_for_args, const char* description_for_command) {
        FuncTableEntry entry = { f, description_for_args, description_for_command };
        string name_str(name);
        _function_table.insert(make_pair(name_str, entry));
    }
};

static void dispatch(string& name, Migrator& m, vector<string>& args) {
    if (_function_table.count(name) == 0) {
        throw "不明なコマンド: '" + name + "' (helpコマンドで有効なコマンド一覧が表示されます)";
    }
    auto entry = _function_table.at(name);
    entry.func(m, args);
}

static fs::path migration_files_dir_path;

#define COMMAND(name, description_for_args, description_for_command) \
void _##name##_command(Migrator&, vector<string>&); \
static regist ___##name##_dmy( #name, &_##name##_command, description_for_args, description_for_command); \
void _##name##_command(Migrator& migrator, vector<string>& args)


COMMAND(help, "", "このヘルプメッセージを表示します") {
    printf("コマンド一覧：\n");
    for (auto entry : _function_table) {
        printf("  %-8s %-12s %s\n", entry.first.c_str(), entry.second.description_for_args, entry.second.description_for_command);
    }
}

COMMAND(exit, "", "プログラムを終了します") {
    throw ExitException("終了します");
}

COMMAND(change, "<dbname>", "DBを変更します。DBファイルが存在しなければ自動的に作成します") {
    if (args.size() < 2 || args[1].empty()) {
        throw runtime_error("DBを指定してください");
    }
    migrator.ChangeDatabase(args[1]);
    cout << "データベースを '" << args[1] << "' に変更しました。" << endl;
}

COMMAND(dir, "[dir]", "マイグレーションファイルの置き場所を表示または設定します") {
    if (args.size() >= 2) {
        fs::path new_dir = args[1];
        // 絶対パスでなければカレントディレクトリを先頭に付与する
        if (!new_dir.has_root_directory()) new_dir = fs::current_path() / args[1];
        if (!fs::exists(new_dir)) throw runtime_error("指定されたパスが見つかりません '" + new_dir.string() + "'");
        if (!fs::is_directory(new_dir)) throw runtime_error("指定されたパスはディレクトリではありません '" + new_dir.string() + "'");
        migration_files_dir_path = new_dir;
        cout << "ディレクトリを設定しました: " << migration_files_dir_path << endl;
        migrator.ReloadMigrations(migration_files_dir_path.string());
    }
    else {
        cout << "現在のディレクトリ: " << migration_files_dir_path << endl;
    }
}

COMMAND(status, "", "現在のマイグレーションの状態を表示します") {
    for (auto s : migrator.Status()) {
        printf(" %s  %-12s %s\n", s.second.applied ? "* UP *" : "-DOWN-", s.first.c_str(), s.second.description.c_str());
    }
}

COMMAND(up, "", "未適用のマイグレーションを全て適用します") {
    auto count = migrator.Up();
    cout << count << "件のマイグレーションを適用しました" << endl;
}

COMMAND(down, "[steps]", "steps で指定された数のマイグレーションを戻します。steps: default 1") {
    int steps = 1;
    if (args.size() > 2) {  
        steps = stoi(args[1].c_str());
    }
    if (steps <= 0) {
        throw runtime_error("steps の指定値が不正です。");
    }
    auto count = migrator.Down(steps);
    cout << count << "件のマイグレーションを戻しました" << endl;
}

COMMAND(reapply, "<version>", "version で指定されたマイグレーションを再適用します。未適用の場合はエラーとなります。") {
    if (args.size() <= 2) {
        throw runtime_error("version を指定してください。");
    }
    migrator.Reapply(args[1]);
}

/**
 * @brief コマンドライン1行ごとの処理
 * @param migrator マイグレーターインスタンス
 * @param line     コマンドラインで入力された1行
 * @return  0  何もディスパッチしなかった
 * @return  1  コマンドをディスパッチした
 * @return -1  終了指示が入力された
 */
int ProcessCmdLine(DBTool::Migrator &migrator, const char* line)
{
    vector<string> words;
    boost::algorithm::split(words, line, boost::is_any_of(" "), boost::token_compress_on);

    if (words.size() == 0 || words[0].length() == 0) return 0;

    auto cmd_name = words[0];
    transform(cmd_name.begin(), cmd_name.end(), cmd_name.begin(), ::tolower);  // 小文字化

    try {
        dispatch(words[0], migrator, words);
    }
    catch (ExitException e) {
        cerr << e.what() << endl;
        return -1;  // 終了
    }
    catch (runtime_error& e) {
        cerr << e.what() << endl;
    }
    catch (string& e) {
        cerr << e << endl;
    }
    return 1;
}

/**
 * @bried メイン関数
 */
int main(int argc, const char *argv[])
{
	cout
		<< "************************************************************" << endl
		<< "* Database management tool for SQLite3" << endl
		<< "*             " VERSION "  written by " AUTHOR  << endl
		<< "************************************************************" << endl;
    Migrator migrator;
    string line;

    if (argc >= 2) {
        // ディレクトリを初期設定
        string cmd = "dir ";
        cmd += argv[1];
        ProcessCmdLine(migrator, cmd.c_str());
    }

    if (argc >= 3) {
        // DBを初期設定
        string cmd = "change ";
        cmd += argv[2];
        ProcessCmdLine(migrator, cmd.c_str());
    }

    // CUIループ
    do {
        cout << migrator.GetCurrentDatabase() << "> ";
        cout.flush();
        getline(cin, line);
        if (cin.eof()) break;  // 終了
    }while(ProcessCmdLine(migrator, line.c_str()) >= 0);

    return 0;
}
