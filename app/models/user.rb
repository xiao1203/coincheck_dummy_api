class User < ApplicationRecord
  has_one :balance, dependent: :destroy
  has_one :leverage_balance, dependent: :destroy
  has_many :leverage_positions
  accepts_nested_attributes_for :balance
  accepts_nested_attributes_for :leverage_balance

  def set_test_trade_time
    ticker_first = Ticker.first
    ticker_last = Ticker.last
    self.start_trade_time = ticker_first.trade_time_int
    self.last_trade_time = ticker_last.trade_time_int
    self.save!
  end

  #
  def test_trade_is_over?
    start_trade_time_str = self.start_trade_time.to_s
    start_trade_time = Chronic.parse("#{start_trade_time_str[0...4]}/"+
                                  "#{start_trade_time_str[4...6]}/"+
                                  "#{start_trade_time_str[6...8]} "+
                                  "#{start_trade_time_str[8...10]}:#{start_trade_time_str[10...12]}:#{start_trade_time_str[12...14]}")

    last_trade_time_str = self.last_trade_time.to_s
    last_trade_time = Chronic.parse("#{last_trade_time_str[0...4]}/"+
                                 "#{last_trade_time_str[4...6]}/"+
                                 "#{last_trade_time_str[6...8]} "+
                                 "#{last_trade_time_str[8...10]}:#{last_trade_time_str[10...12]}:#{last_trade_time_str[12...14]}")

    start_trade_time > last_trade_time
  end

  def update_start_trade_time(interval_time)
    interval_time = interval_time.to_i
    self.start_trade_time += interval_time
    start_trade_time_str = self.start_trade_time.to_s

    conv_time = Chronic.parse("#{start_trade_time_str[0...4]}/"+
                                  "#{start_trade_time_str[4...6]}/"+
                                  "#{start_trade_time_str[6...8]} "+
                                  "#{start_trade_time_str[8...10]}:#{start_trade_time_str[10...12]}:#{start_trade_time_str[12...14]}")

    self.start_trade_time = conv_time.strftime("%Y%m%d%H%M%S").to_i
    self.save!
  end
end
