#include <cstdio>
#include <fstream>
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

	for (auto entry : FUNC_TABLE) {
		if (entry.name == command)
		{
			entry.f_Api(conn, obj, result);
			break;
		}
	}

	//// 受け取ったコマンドによる処理
	//switch (commandMap[command]) {
	//case CommandType::list:
	//	f_GetList(conn, obj, result);
	//	break;
	//case CommandType::create:
	//	f_Regist(conn, obj, result);
	//	break;
	//case CommandType::detail:
	//	f_DspDetail(conn, obj, result);
	//	break; 
	//case CommandType::edit:
	//	f_EditDetail(conn, obj, result);
	//	break;
	//case CommandType::finish:
	//	f_Finish(conn, obj, result);
	//	break;
	//case CommandType::delet:
	//	f_Delete(conn, obj, result);
	//	break;
 //   case CommandType::clear:
 //       f_Clear(conn, obj, result);
 //       break;
	//default:
	//	break;
	//};

    // 文字列にするためにvalueを使用
    picojson::value val(result);

    cout << val.serialize();

    close_db(conn);  // TODO デストラクタでやる
    return 0;
}
