require 'ruby_coincheck_client'
require 'bigdecimal'
require "thor"
require "pry"
require 'chronic'
require './technical_analysis_services/bollinger_band_service'

USER_KEY = "ddfdfddd"
USER_SECRET_KEY = "eeeeeeeee"

INTERVAL_TIME = 10
running_back_test = false
ARGV.each do |argv|
  # コマンド引数に"test"とあったらバックテスト運用
  running_back_test = true if argv == "test"
end

if running_back_test
  BASE_URL = "http://localhost:3000/"
  SSL = false
  HEADER = {
      "Content-Type" => "application/json",
      "ACCESS-KEY" => USER_KEY
  }
else
  BASE_URL = "https://coincheck.jp/"
  SSL = true
end

def http_request(uri, request)
  https = Net::HTTP.new(uri.host, uri.port)
  if SSL
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  response = https.start do |h|
    h.request(request)
  end
end

def request_for_get(uri, headers = {}, body = nil)
  request = Net::HTTP::Get.new(uri.request_uri, initheader = headers)
  request.body = body.to_json if body
  http_request(uri, request)
end

def request_for_put(uri, headers = {}, body = nil)
  request = Net::HTTP::Put.new(uri.request_uri, initheader = headers)
  request.body = body.to_json if body
  http_request(uri, request)
end

if running_back_test
  # 登録済みヒストリカルデータより開始時間を設定
  uri = URI.parse(BASE_URL + "api/set_test_trade_time")
  request_for_put(uri, HEADER)

  # 検証用の証拠金を設定
  uri = URI.parse(BASE_URL + "api/set_user_leverage_balance?margin=200000")
  request_for_put(uri, HEADER)

  # public APIに相当するgemのメソッドはパラメータを渡せないから過去データ検証ができない。
  # 代替案ができるまでAPIを直接呼ぶようにします。
  # 過去データの検証のためには引数を渡すか、呼び出された先でuserの判別ができれば良いが、
  # 前者は引数を渡す、ということでgemのメソッドの形を変えてしまうので、今回は後者で対応
  # gemのメソッドをオーバーライドします
  class CoincheckClient
    def read_ticker
      uri = URI.parse(BASE_URL + "api/ticker")
      request_for_get(uri, HEADER)
    end

    def read_trades
      uri = URI.parse(BASE_URL + "api/trades")
      request_for_get(uri, HEADER)
    end

    def read_order_books
      uri = URI.parse(BASE_URL + "api/order_books")
      request_for_get(uri, HEADER)
    end
  end
end

cc = CoincheckClient.new(USER_KEY,
                         USER_SECRET_KEY,
                         {base_url: BASE_URL,
                         ssl: SSL})

bollinger_band_service = BollingerBandService.new()

count = 0
loop do
  count += 1
  # 現在のレート確認
  puts "count:#{count}"
  rate_res = cc.read_ticker
  btc_jpy_bid_rate =  BigDecimal(JSON.parse(rate_res.body)['bid']) # 現在の買い注文の最高価格
  btc_jpy_ask_rate =  BigDecimal(JSON.parse(rate_res.body)['ask']) # 現在の売り注文の最安価格
  btc_jpy_rate = (btc_jpy_bid_rate + btc_jpy_ask_rate)/2
  bollinger_band_service.set_rate(rate: btc_jpy_rate)

  # ポジションの確認
  response = cc.read_positions(status: "open")
  positions = JSON.parse(response.body)["data"]

  # 証拠金の確認
  response = cc.read_leverage_balance
  margin_available = JSON.parse(response.body)['margin_available']['jpy']
  if positions.empty?
    # ポジション無し
    result = bollinger_band_service.check_signal_exec(btc_jpy_rate)

    # TODO 暫定 (これだとダメ)
    if result == BollingerBandService::PLUS_SIGNAL_LV_3
      # +2σを超えたため逆張りとしてショートポジション
      order_amount = (margin_available / btc_jpy_bid_rate * 5).to_f.round(2)
      response = cc.create_orders(order_type: "leverage_sell",
                                  rate: btc_jpy_bid_rate.to_i,
                                  amount: order_amount,
                                  market_buy_amount: nil,
                                  position_id: nil,
                                  pair: "btc_jpy")

    elsif result == BollingerBandService::MINUS_SIGNAL_LV_3
      # -2σを超えたため逆張りとしてロングポジション
      order_amount = (margin_available / btc_jpy_bid_rate * 5).to_f.round(2)
      response = cc.create_orders(order_type: "leverage_buy",
                                  rate: btc_jpy_ask_rate.to_i,
                                  amount: order_amount,
                                  market_buy_amount: nil,
                                  position_id: nil,
                                  pair: "btc_jpy")
    end


  else
    open_rate = positions[0]["open_rate"]
    # 1.5%以上の利益で利確
    # -2.0%以下のロス発生で損切り
    if positions[0]["side"] == "buy"
      gain_rate = (open_rate * 1.015).to_i
      loss_cut_rate = (open_rate * 0.98).to_i
      if gain_rate <= btc_jpy_ask_rate || loss_cut_rate >= btc_jpy_ask_rate
        # 現在の売り注文が利確金額以上なら利確
        # 現在の売り注文が損切り金額以下なら損切り
        response = cc.create_orders(order_type: "close_long",
                                    rate: btc_jpy_ask_rate.to_i,
                                    amount: positions.first["amount"],
                                    market_buy_amount: nil,
                                    position_id: positions.first["id"],
                                    pair: "btc_jpy")
      end

    elsif positions[0]["side"] == "sell"
      gain_rate = (open_rate * 0.985).to_i
      loss_cut_rate = (open_rate * 1.02).to_i
      if gain_rate >= btc_jpy_bid_rate || loss_cut_rate <= btc_jpy_bid_rate
        # 現在の買い注文が利確金額以下なら利確
        # 現在の買い注文が損切り金額以上なら損切り
        response = cc.create_orders(order_type: "close_short",
                                    rate: btc_jpy_bid_rate.to_i,
                                    amount: positions.first["amount"],
                                    market_buy_amount: nil,
                                    position_id: positions.first["id"],
                                    pair: "btc_jpy")
      end
    end
  end

  # 10秒待機
  # sleep INTERVAL_TIME

  if running_back_test
    # 待機時間分、User.start_trade_timeを加算する
    uri = URI.parse(BASE_URL + "api/update_start_trade_time?interval_time=#{INTERVAL_TIME}")
    request_for_put(uri, HEADER)

    # 登録済みテストデータ分の処理を実行したかを確認
    uri = URI.parse(BASE_URL + "api/check_test_trade_is_over")
    response = request_for_get(uri, HEADER)

    if JSON.parse(response.body)["test_trade_is_over?"]
      break
    end
  end
end