class BitflyerApiController < CommonController
  before_action :set_user, only: [:bitflyer_ticker,
                                  :bitflyer_board,
                                  :bitflyer_executions]

  def bitflyer_ticker
    target = if @user.start_trade_time
               ZaifTicker.find_by_sql("SELECT *
                                   FROM bitflyer_tickers
                                   WHERE 1 = 1
                                   ORDER BY abs(CAST(trade_time_int AS SIGNED) - #{@user.start_trade_time})
                                   Limit 1
                                  ").first.json_body

             else
               ZaifTicker.last.json_body
             end

    render json: JSON.parse(target)
  end

  def bitflyer_board
    target = if @user.start_trade_time
               BitflyerBoard.find_by_sql("SELECT *
                                   FROM bitflyer_boards
                                   WHERE 1 = 1
                                   ORDER BY abs(CAST(trade_time_int AS SIGNED) - #{@user.start_trade_time})
                                   Limit 1
                                  ").first.json_body

             else
               BitflyerBoard.last.json_body
             end

    render json: JSON.parse(target)
  end

  def bitflyer_executions
    target = if @user.start_trade_time
               BitflyerExecution.find_by_sql("SELECT *
                                   FROM bitflyer_executions
                                   WHERE 1 = 1
                                   ORDER BY abs(CAST(trade_time_int AS SIGNED) - #{@user.start_trade_time})
                                   Limit 1
                                  ").first.json_body

             else
               BitflyerExecution.last.json_body
             end

    render json: JSON.parse(target)
  end
end