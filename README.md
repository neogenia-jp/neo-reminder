# neo-reminder
2018勉強会のためのリマインダーアプリ

## Docker 構成の基本的な使い方

```
# コンテナの起動（ビルドがまだの場合は自動的にビルド）
bin/run-docker-compose-fullset.sh up

# 終了するには Ctrl+C で停止して、
bin/run-docker-compose-fullset.sh down

# コンテナのビルドだけ行う場合は
bin/run-docker-compose-fullset.sh build

# コンテナのパラメータを確認する場合は
bin/run-docker-compose-fullset.sh config
```

## Docker for Windows での使い方

Git for windows をインストールすると付いてくる git bash などの bash 環境が必要です（git bash で動作確認しています）。

bash 環境で以下を実行してください。

```
cd {repo_root_dir}            # リポジトリのディレクトリに移動
bin/run-docker-compose-fullset.sh up --build
```

Dockerコンテナが自動的にリビルドされて起動します。front_app backend_svc というコンテナが起動してくれば成功です。
コンソールに表示されるログが落ち着いたら起動が完了していますので、ブラウザで http://localhost/ にアクセスしてみて下さい
（PCスペックによってはRailsの起動にもう少し時間がかかるかもしれません）。
※この状態でC++ 開発環境からも接続可能です。

### C++ 開発環境の使い方

Docker 起動

```
bin/run-docker-compose-backend.sh up
```

Visual Studio 2017 にて、Linux リモートデバッグの設定を行う。

| 設定項目   | 値 |
|:----------|:--------|
| hostname | localhost |
| port     | 10022 |
| user     | neo |
| password | neo |

### Ruby 開発環境でのデバッグ方法（pry）

1. `require 'pry'` を記述
2. `binding.pry` をブレークしたい行に記述
2. backendコンテナが起動していない場合は起動する
`bin/run-docker-compose-backend.sh up`
3. バックエンドコンテナ内で以下のコマンドでテストを起動（ROUTEの部分は自分の名前を使う）
`ROUTE=yamamoto ruby blackbox_test/test_v1.rb`

## テスト

### ブラックボックステスト

全サービスルートに対して共通のブラックボックステストを実行できるようにしました。

テスト内容の詳細は、 `backend-svc/src/blackbox_testtest_v1.rb` を参照してください。

使い方
`bin/run-docker-compose-blackbox-test.sh` にルート名を引数で指定して下さい。

例
```
# 山本さんのサービスをテストする場合
bin/run-docker-compose-blackbox-test.sh yamamoto

# 米岡さんのサービスをテストする場合
bin/run-docker-compose-blackbox-test.sh yoneoka

# 鎌田さんのサービスをテストする場合
bin/run-docker-compose-blackbox-test.sh kamada

# 森口さんのサービスをテストする場合
bin/run-docker-compose-blackbox-test.sh moriguchi

# 全ルートを一括テストする場合
bin/run-docker-compose-blackbox-test.sh all
```

### 通知APIのテスト

`front_app` コンテナにて、`observe` タスクを実行することで通知APIを叩くことが出来ます。

```
# front_app コンテナに入る
docker exec -ti front_app bash

# 例: yamamotoサービス を起動する場合
bin/rails batch:observe:execute[yamamoto]
```

サービスから通知を行うようレスポンスが返された場合は、メールで通知が飛びます。
開発環境では、 `mock_smtp` コンテナにて仮想的なメールサーバが起動しており、
配信されたメールはここに蓄積されるようになっています。

蓄積されているメールを参照するには、ブラウザで以下のアドレスにアクセスして下さい。
```
http://localhost:1080
```


#### cron設定（本番サーバ用）

```
* * * * *  docker exec -ti front_app bin/rails batch:observe:execute[yamamoto]
* * * * *  docker exec -ti front_app bin/rails batch:observe:execute[yoneoka]
* * * * *  docker exec -ti front_app bin/rails batch:observe:execute[kamada]
* * * * *  docker exec -ti front_app bin/rails batch:observe:execute[moriguchi]
* * * * *  docker exec -ti front_app bin/rails batch:observe:execute[maeda]
```

