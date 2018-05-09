#include <cstdio>
#include <fstream>
#include <sqlite/connection.hpp>
#include <sqlite/execute.hpp>
#include <sqlite/query.hpp>
#include <stdarg.h>
#include <boost/algorithm/string/join.hpp>
#include <boost/date_time/gregorian/gregorian.hpp>
#include "main.h"

using namespace std;


map<string, CommandType> commandMap{
	{ "list" , list },
{ "create", create },
{ "detail", detail },
{ "edit",edit },
{ "finish", finish },
{ "delet", delet },
{ "clear", clear }
};


sqlite::connection* init_db() {
    try {
        auto con = new sqlite::connection("/mnt/CppBackendSvc/main.db");
        return con;
    }
    catch (std::exception const & e) {
        std::cerr << "An error occurred: " << e.what() << std::endl;
    }
    return NULL;
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

int main(int argc, const char *args[])
{
    auto conn = init_db();

    auto filepath = "/dev/stdin";

    if (argc >= 2) {
        filepath = args[1];
    }

    std::ifstream fs;
  
    // ファイルを読み込む
    fs.open(filepath, std::ios::binary);

	picojson::value picoValue;

	// ＜入力＞　標準入力より入力されたJSONをpicojson変数で受け取る
    fs >> picoValue;

    if (argc >= 2) {
        fs.close();  // TODO: デストラクタでやる！
    }

	// commandを取得
	picojson::object obj = picoValue.get<picojson::object>();
	string command = obj["command"].get<string>();
    if (command == "delete") command = "delet";     // 予約語なので変換
    // TODO:取得コマンドログ出力

    picojson::object result;

	// 受け取ったコマンドによる処理
	switch (commandMap[command]) {
	case CommandType::list:
		f_GetList(conn, obj, result);
		break;
	case CommandType::create:
		f_Regist(conn, obj, result);
		break;
	case CommandType::detail:
		f_DspDetail(conn, obj, result);
		break; 
	case CommandType::edit:
		f_EditDetail(conn, obj, result);
		break;
	case CommandType::finish:
		f_Finish(conn, obj, result);
		break;
	case CommandType::delet:
		f_Delete(conn, obj, result);
		break;
	default:
		break;
	};

    // 文字列にするためにvalueを使用
    picojson::value val(result);

    cout << val.serialize();

    close_db(conn);  // TODO デストラクタでやる
    return 0;
}
