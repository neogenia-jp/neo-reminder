# neo-reminder
2018勉強会のためのリマインダーアプリ

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

