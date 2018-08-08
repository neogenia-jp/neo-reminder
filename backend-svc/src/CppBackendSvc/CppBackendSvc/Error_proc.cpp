#include "Error_proc.h"
#include <boost/algorithm/string/join.hpp>

using namespace std;


// TODO:エラーメッセージ構造体を返す関数

// TODO:エラー発生時はメッセを返すと共にログを出力する


// エラーの表現方法案
// ①各関数において処理ステータスを返す（従来通り）
// ②ステータスコードによるエラーメッセージの構成(f_関数内でError_procを用いる)
// ③エラーメッセ構成物をJSONへ再編、フロントへ渡す

struct Error_obj {
    string message;     // エラー内容（人間が読んで理解できる内容）
    string reason;      // エラー内容（開発者が読んで理解できる内容。デバッグ用）
    string file;        // エラー発生個所のファイル名やクラス名など
    string line;        // 行番号
};

//エラーコードに応じた
void Get_ErrorObj(int err_code){
    



}
