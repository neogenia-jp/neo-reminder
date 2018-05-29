# DB Management Tool

### 機能

現状では以下の１つだけ。

- DBマイグレーションの管理


### 使い方

```
# コンテナにアタッチ
docker exec -ti backend_svc bash

# C++版ソースコードの置き場所に移動
/mnt/CppBackendSvc/CppBackendSvc

# ショートカットシェルを叩く
./run_db_tool.sh
************************************************************
* Database management tool for SQLite3
*             2018-05-29  written by w.maeda@neogenia.co.jp
************************************************************
ディレクトリを設定しました: "/mnt/CppBackendSvc/CppBackendSvc/db_tool/migrations"
データベースを 'main' に変更しました。
main> help
コマンド一覧：
  change   <dbname>     DBを変更します。DBファイルが存在しなければ自動的に作成します
  dir      [dir]        マイグレーションファイルの置き場所を表示または設定します
  down     [steps]      steps で指定された数のマイグレーションを戻します。steps: default 1
  exit                  プログラムを終了します
  help                  このヘルプメッセージを表示します
  reapply  <version>    version で指定されたマイグレーションを再適用します。未適用の場合はエラーとなります。
  status                現在のマイグレーションの状態を表示します
  up                    未適用のマイグレーションを全て適用します
main>
```

ビルド＆実行すると、対話型ユーザインタフェースが起動します。
`help` と打つと、利用可能なコマンドが表示されます。

#### DBの変更
デフォルトでは、`main.db` ファイルに対してマイグレーション管理を行います。
`change`  コマンドで対象のDBファイルを変更することが出来ます。
例:  `test.db` に変更したい場合
```
main> change test
データベースを 'test' に変更しました。
test>
```
DBを変更するとプロンプトがそのDB名に変化します。

#### 現在の状態確認（ステータス）
`status` コマンドで現在のマイグレーションファイルの適用状況を確認できます。
```
test> status
-down- 20180425-01  create reminder element
-down- 20180529-01  create notification history
test>
```

`-DOWN-` となっている行は、マイグレーションが適用されていないことを表しています。
`* UP *` となっている行は、マイグレーションが適用済みであることを表しています。

#### マイグレーションの適用
`up` コマンドで未適用のマイグレーションを全て適用することができます。
```
test> up
... 省略 ...
2件のマイグレーションを適用しました
test>
```
上手くいったら、`status` コマンドで状況を確認してください。
また、 `sqlite3` コマンドでDBファイルを開いて、テーブルが作成されているかを確認するには、バックエンドコンテナで以下の手順を実行してください。
```
$ sqlite3 test.db
sqlite> .tables
SCHEMA_VERSIONS   reminder_element   notification_history
sqlite>
```

マイグレーションを管理するためのテーブル `SCHEMA_VERSIONS` が自動的に作成されます。
このテーブルは削除しないでください。アプリケーションからも使用しないでください。

#### マイグレーションの戻し（ロールバック）
ロールバックは `down` コマンドで実行できます。
```
main> down
... 省略 ...
1件のマイグレーションを戻しました
```
デフォルトでは１つのマイグレーションだけを戻します。複数のマイグレーションを一括して戻したい場合は、`down` コマンドに引数を与えることができます。
```
main> down 2
... 省略 ...
2件のマイグレーションを戻しました
```

こんな感じです。

#### マイグレーションファイル
マイグレーションファイルは、以下の場所に置いてください。
```
db_tool/migrations/
```
ファイル名は、以下の命名規則に則ってください。
```
yyyyMMdd-nn_description.sql
```
- `yyyyMMdd`: 日付8桁。ファイルを作成した日付。
- `nn`: 連番2桁。`01` から順に、同じ日に作成したら `02` `03` という風にカウントアップしていってください。
- `description`: マイグレーション内容の説明。日本語禁止。スネークケースで。

ファイルの内容は、UPセクションとDOWNセクションを含むSQLスクリプトです。
サンプル:
```
-- [UP]
up時に実行したいSQL（create table や alter table add column など）
;

-- [DOWN]
down時に実行したいSQL（drop table や alter table remove column など）
;
```
DBツールで `up` コマンドを実行したときにUPセクションが実行され、`down` コマンドを実行したときにDOWNセクションが実行されます。
それぞれのセクションの区切りは、`-- [UP]` と `-- [DOWN]` です。この2つのセクション区切り文字列だけが特別な意味を持っており、それ以外の記述内容は全てSQLとみなされて実行されます。
