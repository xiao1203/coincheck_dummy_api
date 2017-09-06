class ApiController < CommonController
  before_action :set_user, only: [:exchange_leverage_positions,
                                 :exchange_orders,
                                 :set_user_leverage_balance,
                                 :set_test_trade_time,
                                 :check_test_trade_is_over,
                                 :update_start_trade_time,
                                 :ticker,
                                 :trades,
                                 :order_books,
                                 :rate_pair,
                                 :accounts_leverage_balance,
                                 :delete_all_positions]

  def ticker
    render json: JSON.parse(ticker_json)
  end

  def trades
    target = if @user.start_trade_time
               Trade.find_by_sql("SELECT *
                                   FROM trades
                                   WHERE 1 = 1
                                   ORDER BY abs(CAST(trade_time_int AS SIGNED) - #{@user.start_trade_time})
                                   Limit 1
                                  ").first.json_body

             else
               Trade.last.json_body
             end

    render json: JSON.parse(target)
  end

  def order_books
    target = if @user.start_trade_time
               OrderBook.find_by_sql("SELECT *
                                      FROM order_books
                                      WHERE 1 = 1
                                      ORDER BY abs(CAST(trade_time_int AS SIGNED) - #{@user.start_trade_time})
                                      Limit 1
                                     ").first.json_body

             else
               OrderBook.last.json_body
             end

    render json: JSON.parse(target)
  end

  def exchange_orders_rate
    render json: "使えない"
  end

  # gemからは呼ばれない
  def rate_pair
    pair = if params[:pair]
             params[:pair]
           else
             "btc_jpy"
           end

    target = if @user.start_trade_time
               Rate.find_by_sql("SELECT *
                                 FROM rates
                                 WHERE 1 = 1
                                 AND pair = '#{pair}'
                                 ORDER BY abs(CAST(trade_time_int AS SIGNED) - #{@user.start_trade_time})
                                 Limit 1
                                 ").first.json_body

             else
               Rate.last.json_body
             end

    render json: JSON.parse(target)
  end

  # レバレッジ取引のポジション一覧を表示します。
  def exchange_leverage_positions
    leverage_positions = @user.leverage_positions.where(status: params["status"])

    res = if leverage_positions.empty?
            # ポジション無し
            {
                success: true,
                pagination: {
                    limit: 10,
                    order: "desc",
                    starting_after: nil,
                    ending_before: nil
                },
                data: []
            }
          else
            # ポジションあり
            {
                success: true,
                pagination: {
                    limit: 10,
                    order: "desc",
                    starting_after: nil,
                    ending_before: nil
                },
                data: leverage_positions
            }
          end
    render json: res
  end

  # 新規注文
  def exchange_orders
    # ポジション作成
    # TODO 現在のTickerを参考に
    # ポジ建てでは、longの時はask以上、shortの時はbid以下でないと約定しない。
    # 決済注文では、long決済の時はbid以下、shortの時はask以上でないと約定しない。
    # 検証環境では確認が難しいのでこの条件に合わなかったら約定失敗としてエラーにする
    # rateは成行注文の場合、tickerレートより2%ほどレートを不利にする。指し注文はそのまま
    side = if %w(buy market_buy leverage_buy).include?(params[:order_type])
             "buy"
           elsif %w(sell market_sell leverage_sell).include?(params[:order_type])
             "sell"
           end
    ticker_hs = JSON.parse(ticker_json)
    if side.present? && %(buy sell).include?(side)
      if side == "buy" && ticker_hs["ask"] > params[:rate]
        # 買い注文（Long）時、askより安値での注文は約定失敗
        render json: "error", status: 500 and return
      elsif side == "sell" && ticker_hs["bid"] < params[:rate]
        # 売り注文（Short）時、bidより高値での注文は約定失敗
        render json: "error", status: 500 and return
      end

      # 最新のレート
      @user.leverage_positions.create(
          pair: params[:pair],
          status: "open",
          open_rate: params[:rate],
          close_rate: nil,
          amount: params[:amount],
          all_amount: params[:amount],
          side: side,
          stop_loss_rate: nil,
          pl: 0
      )
    elsif %(close_long close_short).include?(params[:order_type])
      leverage_position = @user.leverage_positions.find(params["position_id"])

      if side == "close_long" && ticker_hs["bid"] < params[:rate]
        # Long決済時、bidより高値での注文は約定失敗
        render json: "error", status: 500 and return
      elsif side == "sell" && ticker_hs["ask"] > params[:rate]
        # Short決済時、askより安値での注文は約定失敗
        render json: "error", status: 500 and return
      end

      # ポジションをクローズ
      leverage_position.update(status: "close",
                               close_rate: params["rate"],
                               closed_at: Time.zone.now)

      # 決済文を証拠金に加算
      trade_amount = if params[:order_type] == "close_long"
                       (leverage_position.close_rate - leverage_position.open_rate) * leverage_position.amount
                     else
                       (leverage_position.open_rate - leverage_position.close_rate) * leverage_position.amount
                     end

      @user.leverage_balance.margin += trade_amount
      @user.leverage_balance.save!
    end
  end

  # レバレッジアカウントの残高
  def accounts_leverage_balance
    res = {success: true,
           margin: {jpy: @user.leverage_balance.margin },
           margin_available: {jpy: @user.leverage_balance.margin},
           margin_level: nil
    }

    render json: res
  end

  # 検証環境用特殊API
  ## 過去テータになるseedファイルの作成＆保存API
  def save_seed
    cc = CoincheckClient.new("", "")
    stop_time = if params[:stop_time]
                  Time.zone.parse(params[:stop_time])
                else
                  #
                  Time.zone.now + 1.minute;
                end

    puts "パラメータ指定時間 #{stop_time}"
    if stop_time < Time.zone.now
      return render json: ["指定時間超過"]
    end

    interval_time = if params[:interval_time]
                      params[:interval_time].to_i
                    else
                      # 10秒
                      10
                    end
    seed_saving_status = SeedSavingStatus.create({
                                                     status: :doing
                                                 })


    save_seed_coincheck(cc, stop_time, interval_time, seed_saving_status)

    render json: "seedデータの取得を開始しています。取り込み状況の確認は /api/check_saving_statusを実行してください。"
  end

  ## save_seedの状態確認API
  def check_saving_status
    seed_saving_status = SeedSavingStatus.last

    seed_saving_status.update_seed_saving_status!

    result = case seed_saving_status.status
             when "done"
               "処理成功"
             when "doing"
               "処理途中"
             when "error"
               "処理失敗"
             end

    render json: result
  end

  # 保存済みデータのタイムレンジ取得API
  def check_saved_seed_time_range
    # TODO 存在しない時のレス対応

    hs = {}
    hs[:ticker] = {firsr: Ticker.first.trade_time_int,
                    last: Ticker.last.trade_time_int}

    hs[:order_book] = {firsr: OrderBook.first.trade_time_int,
                        last: OrderBook.last.trade_time_int}

    hs[:trade] = {firsr: Trade.first.trade_time_int,
                   last: Trade.last.trade_time_int}

    hs[:rate] = {pair: "btc_jpy",
                 firsr: Rate.where(pair: "btc_jpy").first.trade_time_int,
                 last: Rate.where(pair: "btc_jpy").last.trade_time_int}

    render json: hs
  end

  # userにレバレッジ用の証拠金を設定
  def set_user_leverage_balance
    @user.leverage_balance.margin = params[:margin].to_i
    @user.leverage_balance.save!

    render json: "ユーザーのテスト用レバレッジ証拠金が#{@user.leverage_balance.margin}円になりました。"
  end

  # テストトレード開始終了時間をuserに登録する
  def set_test_trade_time
    result = @user.set_test_trade_time

    render json: "処理成功"
  end

  def delete_all_positions
    @user.leverage_positions.destroy_all

    render json: "処理成功"
  end

  def check_test_trade_is_over
    result = @user.test_trade_is_over?

    render json: {test_trade_is_over?: result, user: @user, leverage_balance: @user.leverage_balance}
  end

  def update_start_trade_time
    result = @user.update_start_trade_time(params[:interval_time])

    render json: "処理成功"
  end

  private

  def generate_saving_process(model_saving_status = nil)
    thread = Thread.new do
      begin
        yield
      rescue => e
        puts "エラー：#{e}"
        if model_saving_status
          model_saving_status.status = :error
          model_saving_status.save!
        end
      ensure
        if model_saving_status
          model_saving_status.status = :done
          model_saving_status.save!
        end
        # Thread処理を行う場合はActiveRecordのコネクションを自分で閉じる
        # ActiveRecordのコネクションを閉じる処理
        ActiveRecord::Base.clear_active_connections!
        ActiveRecord::Base.connection.close
      end
    end

    thread
  end

  def create_model_saving_statuses(seed_saving_status, model_name)
    ModelSavingStatus.create({
                                 status: :doing,
                                 seed_saving_status_id: seed_saving_status.id,
                                 model_number: model_name.to_sym
                             })
  end

  def ticker_json
    if @user.start_trade_time
      Ticker.find_by_sql("SELECT *
                                   FROM tickers
                                   WHERE 1 = 1
                                   ORDER BY abs(CAST(trade_time_int AS SIGNED) - #{@user.start_trade_time})
                                   Limit 1
                                  ").first.json_body

    else
      Ticker.last.json_body
    end
  end

  def save_seed_coincheck(cc, stop_time, interval_time, seed_saving_status)
    #FIXME なぜか、serviceインスタンスとthreadの外で作らないとうまく動かなくなった。
    # メモリ空間で別物と見てくれないのかな？一旦動く形で作ってしまう。
    ## Ticker
    ticker_response_saver = TickerResponseSaver.new(coincheck_client: cc,
                                                    stop_time: stop_time,
                                                    interval_time: interval_time)

    ## OrderBook
    order_book_response_saver = OrderBookResponseSaver.new(coincheck_client: cc,
                                                           stop_time: stop_time,
                                                           interval_time: interval_time)

    ## Trade
    trade_response_saver = TradeResponseSaver.new(coincheck_client: cc,
                                                  stop_time: stop_time,
                                                  interval_time: interval_time)

    # TODO /api/exchange/orders/rateのAPIが有効になっていないようなので一旦pending
    # exchange_order_rate_sell_response_saver = ExchangeOrderRateResponseSaver.new(coincheck_client: cc,
    #                                                                         stop_time: stop_time,
    #                                                                         order_type: "sell",
    #                                                                         interval_time: interval_time)

    # ## BtcJpyRate
    # TODO /api/rate/btc_jpyのAPIがgemに定義されていないようなので他の処理と異なり、直接APIを叩いて取得する
    btc_jpy_rate_saver = RateResponseSaver.new(pair: "btc_jpy",
                                               stop_time: stop_time,
                                               interval_time: interval_time)

    ## model_saving_statuses
    ticker_saving_status = create_model_saving_statuses(seed_saving_status, "ticker")
    trade_saving_status = create_model_saving_statuses(seed_saving_status, "trade")
    order_book_saving_status = create_model_saving_statuses(seed_saving_status, "order_book")
    btc_jpy_rate_saving_status = create_model_saving_statuses(seed_saving_status, "btc_jpy_rate")

    generate_saving_process(ticker_saving_status) do
      # ticker
      ticker_response_saver.execute!
    end

    generate_saving_process(trade_saving_status) do
      # trade
      trade_response_saver.execute!
    end

    generate_saving_process(order_book_saving_status) do
      # order_book
      order_book_response_saver.execute!
    end

    generate_saving_process(btc_jpy_rate_saving_status) do
      # rate
      btc_jpy_rate_saver.execute!
    end
  end
end
