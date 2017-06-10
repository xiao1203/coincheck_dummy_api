class ZaifApiController < CommonController
  before_action :set_user, only: [:zaif_ticker,
                                 :zaif_trades,
                                 :zaif_depth]

  def zaif_ticker
    target = if @user.start_trade_time
               ZaifTicker.find_by_sql("SELECT *
                                   FROM zaif_tickers
                                   WHERE 1 = 1
                                   ORDER BY abs(CAST(trade_time_int AS SIGNED) - #{@user.start_trade_time})
                                   Limit 1
                                  ").first.json_body

             else
               ZaifTicker.last.json_body
             end

    render json: JSON.parse(target)
  end

  def zaif_trades
    target = if @user.start_trade_time
               ZaifTrade.find_by_sql("SELECT *
                                   FROM zaif_trades
                                   WHERE 1 = 1
                                   ORDER BY abs(CAST(trade_time_int AS SIGNED) - #{@user.start_trade_time})
                                   Limit 1
                                  ").first.json_body

             else
               ZaifTrade.last.json_body
             end

    render json: JSON.parse(target)
  end

  def zaif_depth
    target = if @user.start_trade_time
               ZaifDepth.find_by_sql("SELECT *
                                   FROM zaif_depths
                                   WHERE 1 = 1
                                   ORDER BY abs(CAST(trade_time_int AS SIGNED) - #{@user.start_trade_time})
                                   Limit 1
                                  ").first.json_body

             else
               ZaifDepth.last.json_body
             end

    render json: JSON.parse(target)
  end
end
