#include <boost/test/unit_test.hpp>
#include "../main.h"


struct Fixture {
	Fixture() {
		auto conn = init_db("test");
		reminder_element elem;
		elem.clear(conn, "");
		BOOST_TEST_MESSAGE("---data cleared");
	}
	~Fixture() {
	}
};

BOOST_FIXTURE_TEST_SUITE(functions, Fixture)

// 詳細表示
// 登録
// 削除
// 更新
// 一括削除

/*
* @brief テストデータ投入(先にDBデータクリアされます)
* @param (conn) DB Connection オブジェクト
* @param (elem) reminder_element　オブジェクト
* @param (targetId) 操作対象ID
* @param (finished) 完了フラグ
* @return なし
*/
void InsertTestData(
	sqlite::connection*	conn,
	reminder_element&	elem,
	short				targetId,
	bool				finished
) {
	// 投入データ作成（完了）
	elem.id					= targetId;
	elem.title				= "テストデータ１";
	elem.notify_datetime	= "2018-05-05T05:05:05+09:00";
	elem.term				= "2018-05-05T05:05:05+09:00";
	elem.memo				= "テストメモ１";
    elem.latitude           = 34.663601;
    elem.longitude          = 135.496921;
    elem.radius             = 50;
    elem.direction          = "long";
	// finished(完了)フラグ = TRUEで完了データとする
	if (finished) {
		elem.finished_at = "2018-05-05T05:05:05+09:00";
	}
	else{
		elem.finished_at = "";
	}

	// データ投入
	elem.save(conn);
}

/*
* @brief 詳細表示テスト
*/
BOOST_AUTO_TEST_CASE(select) 
{
	auto conn = init_db("test");
	reminder_element elem;

	// テストデータ登録
	InsertTestData(conn, elem, 1, true);

	// 詳細表示実行
	auto result = elem.select(conn, 1, elem);
	// 結果
	BOOST_CHECK_EQUAL(_SUCCESS, result);
	BOOST_CHECK_EQUAL(1, elem.id);
	BOOST_CHECK_EQUAL("テストデータ１", elem.title);
	BOOST_CHECK_EQUAL("2018-05-05T05:05:05+09:00", elem.notify_datetime);
	BOOST_CHECK_EQUAL("2018-05-05T05:05:05+09:00", elem.term);
	BOOST_CHECK_EQUAL("テストメモ１", elem.memo);
    BOOST_CHECK_EQUAL(34.663601, elem.latitude);
    BOOST_CHECK_EQUAL(135.496921, elem.longitude);
    BOOST_CHECK_EQUAL(50, elem.radius);
    BOOST_CHECK_EQUAL("out", elem.direction);
	BOOST_CHECK_EQUAL("2018-05-05T05:05:05+09:00", elem.finished_at);
	// BOOST_CHECK_EQUAL("", result[0].created_at);		// TODO:時刻
}

/*
* @brief 登録テスト
*/
BOOST_AUTO_TEST_CASE(save)
{
	auto conn = init_db("test");
	reminder_element elem;

	elem.clear(conn, "");

	elem.id = 1;
	elem.title = "test";

	elem.save(conn);

	auto result = reminder_element::select_all(conn);
	BOOST_CHECK_EQUAL(1, result.size());
	BOOST_CHECK_EQUAL(1, result[0].id);
	BOOST_CHECK_EQUAL("test", result[0].title);
	//BOOST_CHECK(result[0].created_at.length > 0);  // TODO やりかた調べる
}

/*
* @brief 削除(1件分)テスト
*/
BOOST_AUTO_TEST_CASE(delet)
{
	auto conn = init_db("test");
	reminder_element elem;
	
	// テストデータ登録
	InsertTestData(conn, elem, 1, true);

	// 削除実行
	auto result = elem.dataDelete(conn);
	// 結果
	BOOST_CHECK_EQUAL(_SUCCESS, result);
}

/*
* @brief 一括削除テスト
* 全件削除　& 完了分のみ削除
*/
BOOST_AUTO_TEST_CASE(clear)
{
	auto conn = init_db("test");
	reminder_element elem;

	// テストデータ登録
	InsertTestData(conn, elem, 1, true);

	// 全件削除実行
	auto result = elem.clear(conn,"");
	// 結果
	BOOST_CHECK_EQUAL(2, result.size());
	BOOST_CHECK_EQUAL(_SUCCESS, result[0]); // 結果ステータス
	BOOST_CHECK_EQUAL(1, result[1]);	// 削除したID

	// テストデータ登録(ID=1:未完了,ID=2:完了)
	InsertTestData(conn, elem, 1, false);
	InsertTestData(conn, elem, 2, true);

	// 完了分のみ削除実行
	auto result2 = elem.clear(conn, "finished");
	// 結果
	BOOST_CHECK_EQUAL(2, result2.size());
	BOOST_CHECK_EQUAL(_SUCCESS, result2[0]); // 結果ステータス
	BOOST_CHECK_EQUAL(2, result2[1]);	// 削除したID
}

/*
* @brief 更新テスト
*/
BOOST_AUTO_TEST_CASE(update)
{
	auto conn = init_db("test");
	reminder_element elem;

	// テストデータ登録
	InsertTestData(conn, elem, 1, true);
	
	// 更新データ作成
	elem.id					= 1;
	elem.title				= "更新テスト";
	elem.notify_datetime	= "2018-05-05T05:05:05+09:00";
	elem.term				= "2018-05-05T05:05:05+09:00";
	elem.memo				= "テストメモ";
	elem.finished_at		= "2018-05-05T05:05:05+09:00";
	
	// 更新実行
	auto status = elem.update(conn);
	BOOST_CHECK_EQUAL(_SUCCESS, status);
	auto result = elem.select_all(conn);
	BOOST_CHECK_EQUAL(1, result.size());
	BOOST_CHECK_EQUAL(1, result[0].id);
	BOOST_CHECK_EQUAL("更新テスト", result[0].title);
	BOOST_CHECK_EQUAL("2018-05-05T05:05:05+09:00", result[0].notify_datetime);
	BOOST_CHECK_EQUAL("2018-05-05T05:05:05+09:00", result[0].term);
	BOOST_CHECK_EQUAL("テストメモ", result[0].memo);
	BOOST_CHECK_EQUAL("2018-05-05T05:05:05+09:00", result[0].finished_at);
}

/*
* @brief 完了テスト
*/
BOOST_AUTO_TEST_CASE(finish)
{
	auto conn = init_db("test");
	reminder_element elem;

	// （未完了）テストデータ登録
	InsertTestData(conn, elem, 1, false);

	// 完了実行
	elem.id = 1;

	elem.finished_at = "2018-05-05T05:05:05+09:00";
	auto status = elem.finish(conn);
	auto result = elem.select_all(conn);
	// 結果
	BOOST_CHECK_EQUAL(_SUCCESS, status);

	BOOST_CHECK_EQUAL(1, result[0].id);
	BOOST_CHECK_EQUAL("テストデータ１", result[0].title);
	BOOST_CHECK_EQUAL("2018-05-05T05:05:05+09:00", result[0].notify_datetime);
	BOOST_CHECK_EQUAL("2018-05-05T05:05:05+09:00", result[0].term);
	BOOST_CHECK_EQUAL("テストメモ１", result[0].memo);
	BOOST_CHECK_EQUAL("2018-05-05T05:05:05+09:00", result[0].finished_at);
	// BOOST_CHECK_EQUAL("", result[0].created_at);		// TODO:時刻
}

BOOST_AUTO_TEST_SUITE_END()
