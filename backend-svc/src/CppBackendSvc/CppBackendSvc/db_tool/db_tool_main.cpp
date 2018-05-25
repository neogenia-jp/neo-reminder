#include <iostream>
#include <cstdio>
#include <boost/algorithm/string/classification.hpp> // is_any_of
#include <boost/algorithm/string/split.hpp>
#include "migrator.h"

using namespace std;
using namespace DBTool;

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
        throw "不明なコマンド: " + name;
    }
    auto entry = _function_table.at(name);
    entry.func(m, args);
}

#define COMMAND(name, description_for_args, description_for_command) \
void _##name##_command(Migrator&, vector<string>&); \
static regist ___##name##_dmy( #name, &_##name##_command, description_for_args, description_for_command); \
void _##name##_command(Migrator& migrator, vector<string>& args)


COMMAND(help, "", "このヘルプメッセージを表示します") {
    for (auto entry : _function_table) {
        printf("  %s %-12s %s\n", entry.first.c_str(), entry.second.description_for_args, entry.second.description_for_command);
    }
}

COMMAND(exit, "", "プログラムを終了します") {
    throw ExitException("終了します");
}

COMMAND(change, "<dbname>", "DBを変更します。DBファイルが存在しなければ自動的に作成します。") {
    migrator.ChangeDatabase(args[1]);
}

COMMAND(status, "", "現在のマイグレーションの状態を表示します") {
    for (auto s : migrator.Status()) {
        printf("(%-4s) %-12s %s\n", s.second.applied ? "up" : "down", s.first.c_str(), s.second.description.c_str());
    }
}

COMMAND(up, "", "未適用のマイグレーションを全て適用します") {
    migrator.Up();
}

COMMAND(down, "[steps]", "steps で指定された数のマイグレーションを戻します。steps : default 1") {
    int steps = 1;
    if (args.size() > 2) {  
        steps = stoi(args[1].c_str());
    }
    if (steps <= 0) {
        throw runtime_error("steps の指定値が不正です。");
    }
    migrator.Down(steps);
}

COMMAND(reapply, "<version>", "version で指定されたマイグレーションを再適用します。未適用の場合はエラーとなります。") {
    if (args.size() <= 2) {
        throw runtime_error("version を指定してください。");
    }
    migrator.Reapply(args[1]);
}

int main(int argc, const char *args[])
{
    Migrator migrator;

    do {
        cout << migrator.GetCurrentDatabase() << "> ";
        string line;
        getline(cin, line);
        if (cin.eof()) break;  // 終了

        vector<string> words;
        boost::algorithm::split(words, line, boost::is_any_of(" "), boost::token_compress_on);

        if (words.size() == 0 || words[0].length() == 0) continue;

        auto cmd_name = words[0];
        transform(cmd_name.begin(), cmd_name.end(), cmd_name.begin(), ::tolower);  // 小文字化


        try {
            dispatch(words[0], migrator, words);
        }
        catch (ExitException e) {
            cerr << e.what() << endl;
            break;  // 終了
        }
        catch (runtime_error& e) {
            cerr << e.what() << endl;
        }
        catch (string& e) {
            cerr << e << endl;
        }
    } while (true);

    return 0;
}
