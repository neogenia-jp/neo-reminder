#pragma once

#include <iostream>
#include "picojson.h"

using namespace std;

enum CommandType {
	list = 1,	// 一覧表示
	create,		// 新規作成
	detail,		// 詳細表示
	edit,		// 編集
	finish,		// 完了
	delet,		// 削除

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


// 一覧表示データ
struct LIST_ST {
	short		id;				// ID番号
	string		title;			// タイトル
	time_t		term;			// 日付 (ISO形式)
};

// 新規作成データ
struct CREATE_ST {
	string		status;		// ステータス　(OK/Error)
	string		message;	// メッセージ
};

// 詳細表示データ
struct DETAIL_ST {
	short		id;					// ID番号
	string		title;				// タイトル
	time_t		notify_datetime;	// 日付
	time_t		term;				// 日付 (ISO形式)
	string		memo;				// メモ
	time_t		finished_at;		// 完了日
	time_t		created_at;			// 作成日
};

// 編集データ
struct EDIT_ST {
	string		status;			// ステータス　(OK/Error)
	string		message;		// メッセージ
	time_t		created_at;		// 作成日
};

// 完了データ
struct FINISH_ST {
	string		status;			// ステータス　(OK/Error)
	string		message;		// メッセージ
	time_t		finished_at;	// 完了日
};

// 削除データ
struct DELETE_ST {
	string		status;			// ステータス　(OK/Error)
	string		message;		// メッセージ
};

map<string, CommandType> commandMap{
	{ "list" , list },
{ "create", create },
{ "detail", detail },
{ "edit",edit },
{ "finish", finish },
{ "delet", delet }
};
