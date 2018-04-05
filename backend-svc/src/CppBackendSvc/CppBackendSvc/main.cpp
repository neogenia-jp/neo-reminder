#include <cstdio>
#include <fstream>
#include <sqlite/connection.hpp>
#include <sqlite/execute.hpp>
#include <sqlite/query.hpp>
#include "main.h"

using namespace std;

// 一覧取得
void f_GetList(
	picojson::object&	req,
	picojson::object&	result
)
{
    picojson::object obj1;

    // データの追加
    obj1.insert(std::make_pair("id", picojson::value(1.0)));
    obj1.insert(std::make_pair("title", picojson::value("xxxxxx")));
    obj1.insert(std::make_pair("term", picojson::value("2018-03-20T19:32:00+0900")));

    picojson::array arr;
    arr.push_back(picojson::value(obj1));

    picojson::object obj2;

    // データの追加
    obj2.insert(std::make_pair("id", picojson::value(2.0)));
    obj2.insert(std::make_pair("title", picojson::value("日本語　　\"あいうえお\"")));
    obj2.insert(std::make_pair("term", picojson::value("2028-03-20T29:32:00+0900")));

    arr.push_back(picojson::value(obj2));

    result.insert(std::make_pair("list", picojson::value(arr)));
}

// 登録
void f_Regist(
	picojson::object&	req,
	picojson::object&	result
) {}

// 詳細表示
void f_DspDetail(
	picojson::object&	req,
	picojson::object&	result
) {}

// 詳細編集
void f_EditDetail(
	picojson::object&	req,
	picojson::object&	result
) {}

// 完了
void f_Finish(
	picojson::object&	req,
	picojson::object&	result
) {}

// 削除
void f_Delete(
	picojson::object&	req,
	picojson::object&	result
) {}

int main(int argc, const char *args[])
{
    sqlite::connection con("test.db");


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
	//cout << "command is " << command << endl;

    picojson::object result;

	// 受け取ったコマンドによる処理
	switch (commandMap[command]) {
	case CommandType::list:
		// オプション取得
		f_GetList(obj, result);
		break;
	case CommandType::create:
		f_Regist(obj, result);
		break;
	case CommandType::detail:
		f_DspDetail(obj, result);
		break; 
	case CommandType::edit:
		f_EditDetail(obj, result);
		break;
	case CommandType::finish:
		f_Finish(obj, result);
		break;
	case CommandType::delet:
		f_Delete(obj, result);
		break;
	default:
		break;
	};

    // 文字列にするためにvalueを使用
    picojson::value val(result);

    cout << val.serialize();
    return 0;
}
