#include "main.h"

using namespace std;

int main()
{
	// テスト用のJSONデータ
	map < string, picojson::value> data;
	data["command"] = picojson::value("list");
	data["option"] = picojson::value("option");
	// TODO: OPTIONの追加 
	picojson::value picoValue(data);

	// ＜入力＞　標準入力より入力されたJSONをpicojson変数で受け取る
	// cin >> picoValue;

	// commandを取得
	picojson::object obj = picoValue.get<picojson::object>();
	string command = obj["command"].get<string>();
	cout << "command is " << command << endl;

	// 受け取ったコマンドによる処理
	switch (commandMap[command]) {
	case CommandType::list:
		// オプション取得
		f_GetList(obj);
		break;
	case CommandType::create:
		//f_Regist(picoValue);
		break;
	case CommandType::detail:
		//f_DspDetail(picoValue);
		break; 
	case CommandType::edit:
		//f_EditDetail();
		break;
	case CommandType::finish:
		//f_Finish();
		break;
	case CommandType::delet:
		//f_Delete();
		break;
	default:
		break;
	};


	// ＜出力＞
	//picoValue.serialize();

	return 0;
}

// 一覧取得
void f_GetList(
	picojson::object	obj
)
{
	string optionObj = obj["option"].get<string>();
	//string option = optionObj["condition"].get<string>();

}

// 登録
void f_Regist(
	picojson::value	value
) {}

// 詳細表示
void f_DspDetail(
	picojson::value	value
) {}

// 詳細編集
void f_EditDetail() {}

// 完了
void f_Finish() {}

// 削除
void f_Delete() {}
