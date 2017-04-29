# ダミーcoincheck API(非公式)
coincheck APIを使った自動売買を行うため、ざっと作りました。
実際の取引システムの中身を知っているわけではないので、約定部分とか結構甘いと思うけど、、、おいおい直していきます。

## 対応したAPI
仕様は[本家](https://coincheck.com/ja/documents/exchange/api)に準じているつもり

### Public API

#### ティッカー
GET /api/ticker

#### 全取引履歴
GET /api/trades

#### 板情報
GET /api/order_books

#### 販売レート取得
GET /api/rate/[pair]

※対応しているのは[pair] = btc_jpyのみ

### Private API

#### 新規注文
POST /api/exchange/orders

※「レバレッジ取引新規」と「決済」しか対応していません。


#### ポジション一覧
GET /api/exchange/leverage/positions

#### レバレッジアカウントの残高
GET /api/accounts/leverage_balance


-----------
### 上記のダミーAPIとは別にテストの為のデータ設定用APIがあります。

#### トレードデータのセーブ
GET /api/save_seed

パラメータ<br>
stop_time 終了時間 <br>未記入の場合は現在から1分間

interval_time 取得間隔(秒)<br>未記入の場合は10秒

```
例：http://localhost:3000/api/save_seed?stop_time=2017/05/09/00:45
```

本APIの実行により、ticker、trades、order_books、btc_jpy_rateのseedファイルが生成させるので、終了後、
`rails db:seed`を実行してseedデータを作ってください。
ここ、多分coincheckのシステムに負荷かかってるから、オフィシャルのバックテスト環境が欲しいところ。。。

#### セーブ状態確認
GET /api/check_saving_status


#### セーブ済みトレードデータの開始終了の確認
GET /api/check_saved_seed_time_range


#### テスト用レバレッジアカウントの残高の設定
PUT /api/set_user_leverage_balance

パラメータ<br>
margin テスト用の証拠金(jpy)

```
例：http://localhost:3000/api/set_user_leverage_balance? margin=100000
```

#### テスト開始終了データをUserに設定
PUT /api/set_test_trade_time


#### テストの終了判定
GET /api/check_test_trade_is_over


#### テストデータ読み込み時間の更新
PUT /api/update_start_trade_time

パラメータ<br>
interval_time 経過時間(秒)

※本APIを実行することでテスト用のpublic APIを実行した時、次のデータを取得できるようになります。

```
例：http://localhost:3000/api/update_start_trade_time? interval_time=5

これを実行することで、
http://localhost:3000/api/ticker
の取得結果が5秒後のデータになる。
```