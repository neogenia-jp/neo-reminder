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

vector<FUNC_ENTRY> FUNC_TABLE;

//-----------------------------------------------------------------------------
// reminder_elelment functions
//-----------------------------------------------------------------------------

 //template<class... A> static std::vector<reminder_element> reminder_element::select_all(sqlite::connection* conn, A... args) {
 //    std::vector<string> v = { "1=1" };

 //    for (auto i : std::initializer_list<const char*>{ args... }) {
 //        string str(i);
 //        v.push_back(str);
 //    }

 //    // カンマ区切りの文字列にする
 //    const std::string s = boost::algorithm::join(v, " AND ");

 //    string sql = "SELECT * FROM reminder_element WHERE ";
 //    sql += s;
 //    sqlite::query q(*conn, sql);

 //    boost::shared_ptr<sqlite::result> result = q.get_result();

 //    std::vector<reminder_element> list;
 //    while (result->next_row()) {
 //        reminder_element e;
 //        e.load(result);
 //        list.push_back(e);
 //    }
 //    return list;
 //}

 /*
 * @brief 詳細表示
 * @param (conn) DB Connection オブジェクト
 */
int reminder_element::select(sqlite::connection* conn, int id, reminder_element &e) {
     // SELECT SQL を作る
     string sql = "SELECT * FROM reminder_element WHERE id = ";
     sql += to_string(id);

     // データ詳細取得
     sqlite::query q(*conn, sql);
     boost::shared_ptr<sqlite::result> result = q.get_result();
     
     // データ展開
     while (result->next_row()) {
         e.load(result);
         return _SUCCESS;
     }
     return _ERROR;
 }

 void reminder_element::load(boost::shared_ptr<sqlite::result> result) {
     id = result->get_int(0);                   // ID
     title = result->get_string(1);             // title
     notify_datetime = result->get_string(2);   // notify_datetime
     term = result->get_string(3);              // term
     memo = result->get_string(4);              // memo
     finished_at = result->get_string(5);       // finished_at
     created_at = result->get_string(6);        // created_at
     latitude = result->get_double(7);          // lat
     longitude = result->get_double(8);         // long
     radius = result->get_int(9);               // radius
     direction = result->get_string(10);        // direction
     current_time = result->get_string(11);     // current_time
}

 /*
 * @brief データ新規登録
 * @param (conn) DB Connection オブジェクト
 * @return 0:登録成功
 * @return 1:登録エラー
 */
 int reminder_element::save(sqlite::connection* conn) {
 	try {
 		// INSERT SQL を作る
 		auto sql = "INSERT INTO reminder_element VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" ;
 		// SQL を実行する
 		sqlite::execute ins(*conn, sql);

 		ins % sqlite::nil % title % notify_datetime % term % memo % latitude % longitude % radius % direction % finished_at % created_at;
 		ins();
 	}
 	catch (std::exception const & e) {
 		// TODO:エラーログ出力
        return _ERROR;
    }
    return _SUCCESS;
 }

 /*
 * @brief データ更新
 * @param (conn) DB Connection オブジェクト
 * @return 0:登録成功
 * @return 1:登録エラー
 */
 int reminder_element::update(sqlite::connection* conn) {
     try {
         // INSERT SQL を作る
         auto sql = "UPDATE reminder_element SET title=?, notify_datetime=?, term=?, memo=?, lat=?, long=?, radius=?, direction=?, finished_at=?, created_at=? WHERE id=?";
         // SQL を実行する
         sqlite::execute upd(*conn, sql);

         upd % title % notify_datetime % term % memo %latitude % longitude % radius % direction % finished_at % created_at % id;
         upd();
     }
     catch (std::exception const & e) {
         // TODO:エラーログ出力
         return _ERROR;
     }
     return _SUCCESS;
 }

 /*
 * @brief データ完了更新
 * @param (conn) DB Connection オブジェクト
 * @return 0:更新成功
 * @return 1:更新エラー
 */
 int reminder_element::finish(sqlite::connection* conn) {
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
         return _ERROR;
     }
     return _SUCCESS;
 }

 /*
 * @brief データ削除
 * @param (conn) DB Connection オブジェクト
 * @return 0:削除成功
 * @return 1:削除エラー
 */
 int reminder_element::dataDelete(sqlite::connection* conn) {
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
         return _ERROR;
     }
     return _SUCCESS;
 }

 /*
 * @brief 削除対象ＩＤ取得
 * @param (conn) DB Connection オブジェクト
 * @param (&clearTaget) 削除対象ＩＤ格納変数
 */
 static void Get_ClearTarget(sqlite::connection * conn, std::vector<int> &ClearedID, string selectSql)
 {
     sqlite::query q(*conn, selectSql);
     boost::shared_ptr<sqlite::result> result = q.get_result();
     while (result->next_row()) {
         ClearedID.push_back(result->get_int(0));
     }
 }

 /*
 * @brief データ一括削除
 * @param (conn) DB Connection オブジェクト
 * @return 0:削除成功
 * @return 1:削除エラー
 */
 vector<int> reminder_element::clear(sqlite::connection* conn, string option) {
     
     vector<int> ClearedID;                 // 削除対象ID
     int status = 1;                        // 処理結果ステータス
     string selectSql = "SELECT ID ";       // SQL文頭　SELECT 
     string deleteSql = "DELETE ";          // SQL文頭　DELETE
     string sql = "FROM reminder_element WHERE 1 = 1";    // SQL文

     // 削除対象条件からSQL文を追加する
     if (option == "finished") {
         sql.append(" AND finished_at IS NOT NULL AND finished_at <> '' ");
     }

     // SQL文を結合
     selectSql.append(sql);
     deleteSql.append(sql);

     // 削除対象のIDを取得する
     Get_ClearTarget(conn, ClearedID, selectSql);

     try {
         // SQL(一括削除) を実行する
         sqlite::execute del(*conn, deleteSql);
         del();
     }
     catch (std::exception const & e) {
         // TODO:エラーログ出力
         status = _ERROR;
     }
     // 先頭にステータスを追加
     ClearedID.insert(ClearedID.begin(), status);

     return ClearedID;
 }


#define earth_r 6378.137                // 地球の半径（km）
#define PI 3.141592653589793            // 円周率
#define deg2rad(a) ((a)/180.0 * M_PI)   // 角度をラジアン変換するマクロ

 /*
 * @brief ２地点間の距離を計測する
 * @param (lat1) 緯度1
 * @param (lng1) 経度1
 * @param (lat2) 緯度2
 * @param (lng2) 経度2
 * @return (double) ２地点間の距離
 */
  double MeasureDist(double lat1, double lng1, double lat2, double lng2) {
      double lat = deg2rad(lat2 - lat1);
      double lng = deg2rad(lng2 - lng1);
      double NSD = earth_r * lat;
      double EWD = cos(deg2rad(lat1))*earth_r*lng;
      double distance = sqrt(pow(NSD, 2) + pow(EWD, 2));
      
      // マイナスの場合、符号反転
      if (distance < 0) distance = -distance;

      return distance;
 }

  /*
  * @brief 現在値が設定値圏内かどうか調べる
  * @param (locLat) 緯度（現在地）
  * @param (locLng) 経度（現在地）
  * @param (setLat) 緯度（設定値）
  * @param (setLng) 経度（設定値）
  * @param (radius) 通知範囲（設定値）
  * @return 
  */
  bool IsInRange(double locLat, double locLng, double setLat, double setLng, int radius) {
      double distance = MeasureDist(locLat, locLng, setLat, setLng);
      // 範囲内だったらtrue
      if (distance <= radius) return true;

      return false;
  }

 /*
 * @brief observe
 * @param (conn) DB Connection オブジェクト
 * @return 0:削除成功
 * @return 1:削除エラー
 */
 OBSERVE_ST reminder_element::observe(sqlite::connection* conn) {
     
     OBSERVE_ST list;           // 結果リスト
     list.status = _SUCCESS;    // 処理結果ステータス
     
     try {
         // 緯度・経度がNULLもしくは空でないデータの取得
         string sql = "SELECT * FROM reminder_element WHERE 1 = 1 AND lat IS NOT NULL AND lat <> '' AND long IS NOT NULL AND long <> ''";

         sqlite::query q(*conn, sql);
         boost::shared_ptr<sqlite::result> result = q.get_result();

         // HITしたデータの情報を格納する

         while (result->next_row()) {
             double setLat = result->get_double(7);
             double setLng = result->get_double(8);
             int radius = result->get_int(9);

             if (IsInRange(latitude, longitude, setLat, setLng, radius))
             {
                 // 設定圏内で有ればデータ格納
                 OBSERVE_DATA OBSERVE_ST;
                 OBSERVE_ST.subject = "設定圏内に入りました";
                 OBSERVE_ST.body = "通知 ID:" + result->get_int(0);
                 OBSERVE_ST.svc_data = "なんじゃのかんじゃの";

                 list.observe_st.push_back(OBSERVE_ST);
             }
         }

     }
     catch (std::exception const & e) {
         list.status = _ERROR;
     }

     return list;
 }
 

// 一覧取得
void f_GetList(
    sqlite::connection* conn,
	picojson::object&	req,
	picojson::object&	result
)
{
    // 条件の取得
    string condition = req["options"].get<picojson::object>()["condition"].get<string>();
    // 追加SQL文の作成
    std::vector<string> addSql;

    // 条件によるSQL文の追加
    if (condition == "today") {
        addSql.push_back("strftime('%Y-%m-%d', created_at) = CURRENT_DATE");
    }
    else if (condition == "unfinished") {
        addSql.push_back("finished_at IS NULL");
    }

    // 一覧取得 実行
    auto list = reminder_element::select_all(conn, addSql);

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
string _f_GetTime()
{
	time_t now = std::time(nullptr);
	const tm* lt = localtime(&now);
	char buf[128];
	strftime(buf, sizeof(buf), "%FT%T+09:00", lt);
	return buf;
}

/*
* @brief 現在日時の裏口取得
*/
string uraguchi;

string f_GetTime()
{
	if (uraguchi != "")
	{
		// uraguchiを一回限り有効とする
		string kari = uraguchi;
		uraguchi = "";
		return kari;
	}
	return _f_GetTime();
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
	result = obj1;
}

// 詳細表示
void f_DspDetail(
    sqlite::connection* conn,
    picojson::object&	req,
    picojson::object&	result
) {
    int id = (int)req["options"].get<picojson::object>()["id"].get<double>();   

    reminder_element e;
    // 詳細データ取得
    int resultDB = reminder_element::select(conn, id, e);

    picojson::object obj1;

    if (resultDB != _SUCCESS) {
        auto status = "error";
        auto message = "idに対するデータは存在しませんでした";
        obj1.insert(std::make_pair("status", picojson::value(status)));
        obj1.insert(std::make_pair("message", picojson::value(message)));
    }
    else {
        // データをJSONへ格納
        obj1.insert(std::make_pair("id", picojson::value((double)e.id)));
        obj1.insert(std::make_pair("title", picojson::value(e.title)));
        obj1.insert(std::make_pair("term", picojson::value(e.term)));
        obj1.insert(std::make_pair("memo", picojson::value(e.memo)));
        obj1.insert(std::make_pair("notify_datetime", picojson::value(e.notify_datetime)));
        obj1.insert(std::make_pair("created_at", picojson::value(e.created_at)));
        obj1.insert(std::make_pair("finished_at", picojson::value(e.finished_at)));
    }
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
    elem.latitude           = req["options"].get<picojson::object>()["lat"].get<double>();
    elem.longitude          = req["options"].get<picojson::object>()["long"].get<double>();
    elem.radius             = (int)req["options"].get<picojson::object>()["radius"].get<double>();
    elem.direction          = req["options"].get<picojson::object>()["direction"].get<string>();
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
    // TODO:とりあえず失敗でも作成日出力
    obj1.insert(std::make_pair("created_at", picojson::value(elem.created_at)));
    
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
) {
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

    // 先頭に在るステータスの要素を削除
    resultDB.erase(resultDB.begin());

    // picojsonの配列に削除対象IDを格納 
    picojson::array picoArray;

    for (int x : resultDB) {
        picoArray.push_back(picojson::value((double)x));
    }
    
    obj1.insert(std::make_pair("affected_id_list", picojson::value(picoArray)));
    obj1.insert(std::make_pair("message", picojson::value(message)));
    obj1.insert(std::make_pair("status", picojson::value(status)));

    result = obj1;
}



// observe
void f_Observe(
    sqlite::connection* conn,
    picojson::object&	req,
    picojson::object&	result
){
    reminder_element elem;
    
    // option取得
    elem.current_time = req["options"].get<picojson::object>()["current_time"].get<string>();
    // 2018-03-20T19:32:00+0900
    // string current_time = time.erase(20);
    elem.latitude = req["options"].get<picojson::object>()["lat"].get<double>();
    elem.longitude = req["options"].get<picojson::object>()["long"].get<double>();
    
    // データ処理
    auto resultData = elem.observe(conn);
    



    if ((double)resultData.status == _ERROR){
        // 共通エラー処理
       // return error_proc(observe, result);
    }

    // picojsonオブジェクト
    picojson::object obj;
    obj.insert(std::make_pair("message", picojson::value(resultData.message)));
    obj.insert(std::make_pair("status", picojson::value((double)resultData.status)));

    result = obj;
}