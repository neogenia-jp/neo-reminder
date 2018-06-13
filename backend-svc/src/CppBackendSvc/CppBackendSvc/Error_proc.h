#pragma once


//　TODO:main.hの以下コードを此方に移動するべし
// 処理結果ステータスコード
//#define _ERROR      0   // 異常
//#define _SUCCESS    1   // 正常

//
//{
//status: “error”,
//    message : “エラー内容（人間が読んで理解できる内容）”,
//    reason : “エラー内容（開発者が読んで理解できる内容。デバッグ用）”,
//    file : “エラー発生個所のファイル名やクラス名など”,
//    line : “行番号”
//}


//エラー内容（人間が読んで理解できる内容）
#define Error_Message_DB_Error "データベースのアクセスに失敗しました" 

//エラー内容（開発者が読んで理解できる内容。デバッグ用）
#define Error_Reason_DB_Error "DBアクセス異常" 



// エラー発生個所のファイル名やクラス名など
// 行番号
// 上記はエラー箇所にてエラー内容をthrowする
//
//// エラーメッセージ構造体
//struct Error_Message
//{
//    
//
//};