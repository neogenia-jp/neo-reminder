#pragma once

#include <iostream>
#include <sqlite/connection.hpp>
#include <sqlite/execute.hpp>
#include <sqlite/query.hpp>
#include <stdarg.h>
#include <boost/algorithm/string/join.hpp>
#include <boost/date_time/gregorian/gregorian.hpp>
#include "picojson.h"
#include "Error_proc.h"

using namespace std;


// 処理結果ステータスコード
#define _ERROR      0   // 異常
#define _SUCCESS    1   // 正常


enum CommandType {
	list = 1,	// 一覧表示
	create,		// 新規作成
	detail,		// 詳細表示
	edit,		// 編集
	finish,		// 完了
	delet,		// 削除
    clear,      // クリア
    observe,    // observe

	command_maxnum // 最大コマンド数
};
//
//enum DataType {
//	id,					// ID番号
//	title,				// タイトル
//	term,				// 日付 (ISO形式)
//	status,				// ステータス　(OK/Error)
//	message,			// メッセージ
//	notify_datetime,	// 日付
//	memo,				// メモ
//	finished_at,		// 完了日
//	created_at,			// 作成日
//};

sqlite::connection* init_db(string);
sqlite::connection* init_db();

void close_db(sqlite::connection* conn);


// 結果データ
struct status_data {
    int status;     // ステータスコード
    string message; // メッセージ（人間が読んで理解できる内容）
};

// 一覧表示データ(単体)
struct LIST_DATA {
    short		id;				// ID番号
    string		title;			// タイトル
    time_t		term;			// 日付 (ISO形式)
};

// 一覧表示データ
struct LIST_ST : status_data {
    vector<LIST_DATA> list_st;
};

// 新規作成データ
struct CREATE_ST : status_data {};

// 詳細表示データ
struct DETAIL_ST : status_data {
	short		id;					// ID番号
	string		title;				// タイトル
	time_t		notify_datetime;	// 日付
	time_t		term;				// 日付 (ISO形式)
	string		memo;				// メモ
	time_t		finished_at;		// 完了日
	time_t		created_at;			// 作成日
};

// 編集データ
struct EDIT_ST : status_data {
	time_t		created_at;		// 作成日
};

// 完了データ
struct FINISH_ST : status_data {
	time_t		finished_at;	// 完了日
};

// 削除データ
struct DELETE_ST : status_data {};

// observeデータ（単体）
struct OBSERVE_DATA {
    string subject;             // 通知のタイトル等
    string body;                // 通知内容の本文
    string svc_data;            // サービスごとの自由なデータ
};

// observeデータ
struct OBSERVE_ST : status_data {
    vector<OBSERVE_DATA> observe_st;
};

// スヌーズデータ
struct SNOOZE_ST : status_data {
    time_t      current_time;       // システムの現在時刻（ISO形式）
    time_t      next_notify_time;   // 次の通知予定時刻（ISO形式）
};

// timer_element
struct timer_element {
    time_t snooze_time;         // スヌーズ時間（単位は分）
    time_t current_time_ori;    // 元データの通知設定時刻（notify_datetime）を保存する
};

// 裏口設定
extern string uraguchi;

struct base_model {
    int id = 0;  //  1,
    virtual inline int save_or_update(sqlite::connection* conn) {
        if (id == 0) {
            return save(conn);
        }
        else {
            return update(conn);
        }
    }
    virtual int save(sqlite::connection* conn) = 0;
    virtual int update(sqlite::connection* conn) = 0;
};

struct reminder_element : base_model {
    string title ; //“xxxxxx”,
    string notify_datetime; // “2018 - 03 - 20T19:32 : 00 + 0900”通知時間
    string term; //“2018 - 03 - 20T19:32 : 00 + 0900”,  // ISO形式　期限
    string memo; //“xxxxxxxxxxxxxxxxxxxxxxx”,
    string finished_at; // “2018-03-20T19:32:00+0900”,  // 完了日
    string created_at; // “2018-03-20T19:32:00+0900”  // 作成日
    double latitude;  //  34.663601,   // 緯度
    double longitude; // 135.496921,  // 経度
    int    radius;    // 50,         // 半径（単位はメートル）
    string direction; // “out”,  // in:範囲に入ったとき  out:範囲から出たとき
    string current_time;
    timer_element* timer_elem = NULL;   // 時間関連の保存オブジェクト

    void init_timer_element()
    {
        if (timer_elem != NULL) {
            return;
        }
        timer_elem = new timer_element;
    }

    ~reminder_element() {
        if (timer_elem == NULL) {
            return;
        }
        delete timer_elem;
    }

    static std::vector<reminder_element> select_all(sqlite::connection* conn, std::vector<string> condition) {
		std::vector<string> v = { "1=1" };

		for (auto i : condition) {
			v.push_back(i);
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
	static std::vector<reminder_element> select_all(sqlite::connection* conn) {
		std::vector<string> list;
		return reminder_element::select_all(conn, list);
	}

    /*
    * @brief 詳細表示
    * @param (conn) DB Connection オブジェクト
    */
    static int select(sqlite::connection* conn, int id, reminder_element &e);

	void load(boost::shared_ptr<sqlite::result> result);

	/*
	* @brief データ新規登録
	* @param (conn) DB Connection オブジェクト
	* @return 0:登録成功
	* @return 1:登録エラー
	*/
	int save(sqlite::connection* conn);

	/*
	* @brief データ更新
	* @param (conn) DB Connection オブジェクト
	* @return 0:登録成功
	* @return 1:登録エラー
	*/
	int update(sqlite::connection* conn);

    /*
    * @brief データ完了更新
    * @param (conn) DB Connection オブジェクト
    * @return 0:更新成功
    * @return 1:更新エラー
    */
	int finish(sqlite::connection* conn);

    /*
    * @brief データ削除
    * @param (conn) DB Connection オブジェクト
    * @return 0:削除成功
    * @return 1:削除エラー
    */
	int dataDelete(sqlite::connection* conn);

    /*
    * @brief データ一括削除
    * @param (conn) DB Connection オブジェクト
    * @return 0:削除成功
    * @return 1:削除エラー
    */
    vector<int> clear(sqlite::connection* conn, string option);

    /*
    * @brief observe
    * @param (conn) DB Connection オブジェクト
    * @return (OBSERVE_ST) 処理結果
    */
    OBSERVE_ST observe(sqlite::connection* conn);

    /*
    * @brief snooze
    * @param (conn) DB Connection オブジェクト
    * @return (SNOOZE_ST) 処理結果
    */
    SNOOZE_ST snooze(sqlite::connection* conn);
};


struct FUNC_ENTRY {
	string name;
	void (*f_Api)(
		sqlite::connection*,
		picojson::object&,
		picojson::object&
		);
};

extern vector<FUNC_ENTRY> FUNC_TABLE;

//enum
//{
//	delet = 1,
//	save = 1,
//
//
//
//};

class FuncRegestorer
{
public:
	FuncRegestorer(string name, void(*f_Api)(
		sqlite::connection*,
		picojson::object&,
		picojson::object&
		)) {
		FUNC_ENTRY entry;
		entry.name = name;
		entry.f_Api = f_Api;
		FUNC_TABLE.push_back(entry);
	}
};
	//
//void func()
//{
//	// メモリの初期化
//
//	func[delet] = &deletFunc;
//	func[save]	= &saveFunc;
//
//
//}
//
//void deletFunc() {};
//void saveFunc() {};

#define DEF_API(name, function_name) \
void function_name( \
	sqlite::connection* conn, \
	picojson::object&	req, \
	picojson::object&	result \
); \
static FuncRegestorer ___##function_name(name, function_name); 

DEF_API("list", f_GetList);
DEF_API("create", f_Regist);
DEF_API("detail", f_DspDetail);
DEF_API("edit", f_EditDetail);
DEF_API("finish", f_Finish);
DEF_API("delete", f_Delete);
DEF_API("clear", f_Clear);
DEF_API("observe", f_Observe);
DEF_API("snooze", f_Snooze);


// 一覧取得
//void f_GetList(
//	sqlite::connection* conn,
//	picojson::object&	req,
//	picojson::object&	result
//);
//static FuncRegestorer dmy1("list", f_GetList);

//
//// 登録
//void f_Regist(
//	sqlite::connection* conn,
//	picojson::object&	req,
//	picojson::object&	result
//);
//
//
//// 詳細表示
//void f_DspDetail(
//	sqlite::connection* conn,
//	picojson::object&	req,
//	picojson::object&	result
//);
//
//
//// 詳細編集
//void f_EditDetail(
//	sqlite::connection* conn,
//	picojson::object&	req,
//	picojson::object&	result
//);
//
//// 完了
//void f_Finish(
//	sqlite::connection* conn,
//	picojson::object&	req,
//	picojson::object&	result
//);
//
//// 削除
//void f_Delete(
//	sqlite::connection* conn,
//	picojson::object&	req,
//	picojson::object&	result
//);
//
//// 一括削除
//void f_Clear(
//    sqlite::connection* conn,
//    picojson::object&	req,
//    picojson::object&	result
//);
//
//

