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

// 処理結果ステータスコード
#define _ERROR		-99	// 異常
#define _SUCCESS	0	// 正常



map<string, CommandType> commandMap{
    { "list" , list },
    { "create", create },
    { "detail", detail },
    { "edit", edit },
    { "finish", finish },
    { "delet", delet },
    { "clear", clear },
    { "observe", observe },
};

struct base_model {
    int id = 0;  //  1,
    virtual int save_or_update(sqlite::connection* conn) {
        if (id == 0) {
            save(conn);
        }
        else {
            update(conn);
        }
    }
    virtual int save(sqlite::connection* conn) = 0;
    virtual int update(sqlite::connection* conn) = 0;
};

struct reminder_element : base_model {
    string title ; //“xxxxxx”,
    string notify_datetime; // “2018 - 03 - 20T19:32 : 00 + 0900”
    string term; //“2018 - 03 - 20T19:32 : 00 + 0900”,  // ISO形式
    string memo; //“xxxxxxxxxxxxxxxxxxxxxxx”,
    string finished_at; // “2018-03-20T19:32:00+0900”,  // 完了日
    string created_at; // “2018-03-20T19:32:00+0900”  // 作成日

    template<class... A> static std::vector<reminder_element> select_all(sqlite::connection* conn, A... args) {
        // TODO: all | today | unfinished　の条件追加
        
        std::vector<string> v = { "1=1" };

        for (auto i : std::initializer_list<const char*>{ args... }) {
            string str(i);
            v.push_back(str);
        }

        // カンマ区切りの文字列にする
        const std::string s = boost::algorithm::join(v, " AND ");

        string sql = "SELECT * FROM reminder_element WHERE ";
        sql += s;
        sqlite::query q(*conn, sql);

        boost::shared_ptr<sqlite::result> result = q.get_result();

        std::vector<reminder_element> list;
        while (result->next_row()) {
            reminder_element e;
            e.load(result);
            list.push_back(e);
        }
        return list;
    }

    /*
    * @brief 詳細表示
    * @param (conn) DB Connection オブジェクト
    */
    static reminder_element select(sqlite::connection* conn, int id) {
        // INSERT SQL を作る
        string sql = "SELECT * FROM reminder_element WHERE id = ";
        sql += to_string(id);

        // データ詳細取得
        sqlite::query q(*conn, sql);
        boost::shared_ptr<sqlite::result> result = q.get_result();
        // データ展開
        while (result->next_row()) {
            reminder_element e;
            e.load(result);
            return e;
        }
    }

    void load(boost::shared_ptr<sqlite::result> result) {
        id = result->get_int(0);
        title = result->get_string(1);
        notify_datetime = result->get_string(2);
        term = result->get_string(3);
        memo = result->get_string(4);
        finished_at = result->get_string(5);
        created_at = result->get_string(6);
    }

	/*
	* @brief データ新規登録
	* @param (conn) DB Connection オブジェクト
	* @return 0:登録成功
	* @return 1:登録エラー
	*/
    int save(sqlite::connection* conn) {
		try {
			// INSERT SQL を作る
			auto sql = "INSERT INTO reminder_element VALUES (?, ?, ?, ?, ?, ?, ?)" ;
			// SQL を実行する
			sqlite::execute ins(*conn, sql);

			ins % sqlite::nil % title % notify_datetime % term % memo % finished_at % created_at;
			ins();
		}
		catch (std::exception const & e) {
			// TODO:エラーログ出力
			return 1;
		}
		return 0;
	}

	/*
	* @brief データ更新
	* @param (conn) DB Connection オブジェクト
	* @return 0:登録成功
	* @return 1:登録エラー
	*/
    int update(sqlite::connection* conn) {
        try {
            // INSERT SQL を作る
            auto sql = "UPDATE reminder_element SET title=?, notify_datetime=?, term=?, memo=?, finished_at=?, created_at=? WHERE id=?";
            // SQL を実行する
            sqlite::execute upd(*conn, sql);

            upd % title % notify_datetime % term % memo % finished_at % created_at % id;
            upd();
        }
        catch (std::exception const & e) {
            // TODO:エラーログ出力
            return 1;
        }
        return 0;
    }

    /*
    * @brief データ完了更新
    * @param (conn) DB Connection オブジェクト
    * @return 0:更新成功
    * @return 1:更新エラー
    */
    int finish(sqlite::connection* conn) {
        try {
            // INSERT SQL を作る
            auto sql = "UPDATE reminder_element SET finished_at=? WHERE id=?";
            // SQL を実行する
            sqlite::execute upd(*conn, sql);

            upd % finished_at % id;
            upd();
        }
        catch (std::exception const & e) {
            // TODO:エラーログ出力
            return 1;
        }
        return 0;
    }

    /*
    * @brief データ削除
    * @param (conn) DB Connection オブジェクト
    * @return 0:削除成功
    * @return 1:削除エラー
    */
    int dataDelete(sqlite::connection* conn) {
        try {
            // INSERT SQL を作る
            auto sql = "DELETE FROM reminder_element WHERE id=?";
            // SQL を実行する
            sqlite::execute del(*conn, sql);

            del % id;
            del();
        }
        catch (std::exception const & e) {
            // TODO:エラーログ出力
            return 1;
        }
        return 0;
    }

    /*
    * @brief DBからの結果を格納する構造体
    */
    struct DataStruct {
        short                       status;     // 処理結果ステータス
        short                       message;    // 処理結果メッセージ
        vector<reminder_element>    data;       // 出力データ
    };

    /*
    * @brief データ一括削除
    * @param (conn) DB Connection オブジェクト
    * @return 0:削除成功
    * @return 1:削除エラー
    */
    vector<int> clear(sqlite::connection* conn, string option) {
        // DELETE SQL を作る
        string deleteSql = "DELETE FROM reminder_element WHERE 1 = 1";
        vector<int> clearTaget;
        int status = 0;

        if (option == "finished") {
            // 削除対象のIDを取得
            Get_ClearTarget(conn, clearTaget);
            // DELETE SQL文に条件を追加
            deleteSql.append(" AND finished_at IS NOT NULL");
        }

        try {
            // SQL を実行する
            sqlite::execute del(*conn, deleteSql);
            del();
        }
        catch (std::exception const & e) {
            // TODO:エラーログ出力
            status = -99;
        }
        // 先頭にステータスを追加
        clearTaget.insert(clearTaget.begin(), status);

        return clearTaget;
    }

    /*
    * @brief 削除対象ＩＤ取得
    * @param (conn) DB Connection オブジェクト
    * @param (&clearTaget) 削除対象ＩＤ格納変数
    */
    void Get_ClearTarget(sqlite::connection * conn, std::vector<int> &clearTaget)
    {
        // 削除対象となるレコードを調べ,格納する
        string selectSql = "SELECT id FROM reminder_element WHERE 1 = 1 AND finished_at IS NOT NULL";
        sqlite::query q(*conn, selectSql);
        boost::shared_ptr<sqlite::result> result = q.get_result();
        while (result->next_row()) {
            clearTaget.push_back(result->get_int(0));
        }
    }

    /*
    * @brief 各種データ取得
    * @param (conn) DB Connection オブジェクト
    * @return 0:正常
    * @return 1:異常
    */
    int getObserveData(sqlite::connection* conn) {
        return 0;
    }

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

// 一覧取得
void f_GetList(
    sqlite::connection* conn,
	picojson::object&	req,
	picojson::object&	result
)
{
    auto list = reminder_element::select_all(conn, "1=1");

    picojson::array arr;
    for (auto i = list.begin(); i != list.end(); i++) {
        picojson::object obj1;

        // データの追加
        obj1.insert(std::make_pair("id", picojson::value((double)i->id)));
        obj1.insert(std::make_pair("title", picojson::value(i->title)));
        obj1.insert(std::make_pair("term", picojson::value(i->term)));
        obj1.insert(std::make_pair("memo", picojson::value(i->memo)));
        obj1.insert(std::make_pair("notify_datetime", picojson::value(i->notify_datetime)));
        obj1.insert(std::make_pair("created_at", picojson::value(i->created_at)));
        obj1.insert(std::make_pair("finished_at", picojson::value(i->finished_at)));

        arr.push_back(picojson::value(obj1));
    }

    result.insert(std::make_pair("list", picojson::value(arr)));
}

/*
* @brief 現在日時取得
* @return (buf) string 現在日時
*/
string f_GetTime()
{
    time_t now = std::time(nullptr);
    const tm* lt = localtime(&now);
    char buf[128];
    strftime(buf, sizeof(buf), "%FT%T+09:00", lt);
    return buf;
}

// 登録
void f_Regist(
    sqlite::connection* conn,
	picojson::object&	req,	
	picojson::object&	result
) {
    reminder_element elem;

	// 登録データ取得 
	elem.title = req["options"].get<picojson::object>()["title"].get<string>();
    elem.created_at = f_GetTime();
		
	// DB登録
	int resultDB = elem.save_or_update(conn);

	// 結果送信
	picojson::object obj1;
	string status, message;
	if (resultDB == _SUCCESS) {
		status = "ok";
		message = "登録完了";
	}
	else {
		status = "error";
		message = "登録失敗";
	}
	obj1.insert(std::make_pair("status", picojson::value(status)));
	obj1.insert(std::make_pair("message", picojson::value(message)));
    obj1.insert(std::make_pair("created_at", picojson::value(elem.created_at)));
	result = obj1;
}



// 詳細表示
void f_DspDetail(
    sqlite::connection* conn,
    picojson::object&	req,
    picojson::object&	result
) {
    int id = (int)req["options"].get<picojson::object>()["id"].get<double>();

    // 詳細データ取得
    auto resultDB = reminder_element::select(conn, id);

    picojson::object obj1;
    // データをJSONへ格納
    obj1.insert(std::make_pair("id", picojson::value((double)resultDB.id)));
    obj1.insert(std::make_pair("title", picojson::value(resultDB.title)));
    obj1.insert(std::make_pair("term", picojson::value(resultDB.term)));
    obj1.insert(std::make_pair("memo", picojson::value(resultDB.memo)));
    obj1.insert(std::make_pair("notify_datetime", picojson::value(resultDB.notify_datetime)));
    obj1.insert(std::make_pair("created_at", picojson::value(resultDB.created_at)));
    obj1.insert(std::make_pair("finished_at", picojson::value(resultDB.finished_at)));

    result = obj1;
}

// 詳細編集
void f_EditDetail(
	sqlite::connection* conn,
	picojson::object&	req,
	picojson::object&	result
) {
    reminder_element elem;

    // 編集データ取得 
    elem.id                 = (int)req["options"].get<picojson::object>()["id"].get<double>();
    elem.title              = req["options"].get<picojson::object>()["title"].get<string>();
    elem.notify_datetime    = req["options"].get<picojson::object>()["notify_datetime"].get<string>();
    elem.term			    = req["options"].get<picojson::object>()["term"].get<string>();
    elem.memo               = req["options"].get<picojson::object>()["memo"].get<string>();
    elem.created_at         = f_GetTime();

    // DB登録
    int resultDB = elem.save_or_update(conn);

    // 結果送信
    picojson::object obj1;
    string status, message;
    if (resultDB == _SUCCESS) {
        status = "ok";
        message = "更新完了";
    }
    else {
        status = "error";
        message = "更新失敗";
    }
    obj1.insert(std::make_pair("status", picojson::value(status)));
    obj1.insert(std::make_pair("message", picojson::value(message)));
    obj1.insert(std::make_pair("updated_at", picojson::value(elem.created_at)));
    
    result = obj1;
}

// 完了
void f_Finish(
	sqlite::connection* conn,
	picojson::object&	req,
	picojson::object&	result
) {
    reminder_element elem;

    // 完了データ取得
    elem.id = (int)req["options"].get<picojson::object>()["id"].get<double>();
    elem.finished_at = f_GetTime();

    // DB登録
    int resultDB = elem.finish(conn);

    // 結果送信
    picojson::object obj1;
    string status, message;
    if (resultDB == _SUCCESS) {
        status = "ok";
        message = "更新完了";
    }
    else {
        status = "error";
        message = "更新失敗";
    }
    obj1.insert(std::make_pair("status", picojson::value(status)));
    obj1.insert(std::make_pair("message", picojson::value(message)));
    // TODO:とりあえず失敗でも完了日出力
    obj1.insert(std::make_pair("finished_at", picojson::value(elem.finished_at)));

    result = obj1;
}

// 削除
void f_Delete(
	sqlite::connection* conn,
	picojson::object&	req,
	picojson::object&	result
) {
    reminder_element elem;

    // 完了データ取得
    elem.id = (int)req["options"].get<picojson::object>()["id"].get<double>();
    
    // DB登録
    int resultDB = elem.dataDelete(conn);

    // 結果送信
    picojson::object obj1;
    string status, message;
    if (resultDB == _SUCCESS) {
        status = "ok";
        message = "削除完了";
    }
    else {
        status = "error";
        message = "削除失敗";
    }
    obj1.insert(std::make_pair("status", picojson::value(status)));
    obj1.insert(std::make_pair("message", picojson::value(message)));
    
    result = obj1;
}

// 一括削除
void f_Clear(
    sqlite::connection* conn,
    picojson::object&	req,
    picojson::object&	result
){
    reminder_element elem;
    // option取得
    string option = req["options"].get<picojson::object>()["target"].get<string>();
    //target: “all | finished”   // finished を指定すると、完了したリマインダーだけを削除する

    auto resultDB = elem.clear(conn, option);

    // 結果送信
    picojson::object obj1;
    string status;
    string message;
    if (resultDB[0] == _SUCCESS) {
        status = "ok";
        message = "削除完了";
    }
    else {
        status = "error";
        message = "削除失敗";
    }
    obj1.insert(std::make_pair("status", picojson::value(status)));
    obj1.insert(std::make_pair("message", picojson::value(message)));

    // 削除されたIDのリストを登録する
    string list = "[";

    for (auto i = resultDB.begin() + 1; i != resultDB.end(); i++) {
        list += to_string(resultDB[i]);
        if (i != resultDB.end()) {
            list.push_back(',');
        }
    }
    list += "]";

    obj1.insert(std::make_pair("affected_id_list", picojson::value(list)));

    // TODO:削除されたIDの列挙
    // obj1.insert(std::make_pair("affected_id_list", picojson::value(message)));
    // affected_id_list : [1, 2, …]   // 削除されたIDのリスト

    result = obj1;
}

void f_GetObserveData(
    sqlite::connection* conn,
    picojson::object&	req,
    picojson::object&	result
) {

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
    case CommandType::clear:
        f_Clear(conn, obj, result);
        break;
    case CommandType::observe:
        f_GetObserveData(conn, obj, result);
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
