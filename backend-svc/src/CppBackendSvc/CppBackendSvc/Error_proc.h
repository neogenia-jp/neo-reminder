#pragma once
#include "main.h"


//処理結果ステータスコード
#define _ERROR      0   // 異常
#define _SUCCESS    1   // 正常



//エラー内容（人間が読んで理解できる内容）
#define Error_Message_DB_Error "データベースのアクセスに失敗しました" 

//エラー内容（開発者が読んで理解できる内容。デバッグ用）
#define Error_Reason_DB_Error "DBアクセス異常" 

// エラー一覧
enum ErrorType {




};

//struct errorInfo{
//    string status;  // ステータスコード
//    string message; // エラー内容（人間が読んで理解できる内容）
//    string reason;  // エラー内容（開発者が読んで理解できる内容。デバッグ用）
//    string file;    // エラー発生個所のファイル名やクラス名など
//    string line;    // 行番号
//};

//
///*
//* @brief エラー処理
//* @param (commandName) 処理中コマンド名
//* @return 共通エラーオブジェクト
//*/
//void error_proc(CommandType commandName, picojson::object obj) {
//
//    // ステータスコード
//    obj.insert(std::make_pair("status", picojson::value("error")));
//
//    // エラー内容（人間が読んで理解できる内容）
//    string message = "";
//    obj.insert(std::make_pair("message", picojson::value(message)));
//
//    // エラー内容（開発者が読んで理解できる内容。デバッグ用
//    string reason = "";
//
//    obj.insert(std::make_pair("reason", picojson::value(reason)));
//
//    // エラー発生個所のファイル名やクラス名など
//    obj.insert(std::make_pair("message", picojson::value(message)));
//
//
//}
