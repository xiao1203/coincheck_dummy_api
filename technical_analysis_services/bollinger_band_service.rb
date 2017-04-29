class BollingerBandService

  # データ不足
  LACK_DATA = 0
  PLUS_SIGNAL_LV_3 = 1
  PLUS_SIGNAL_LV_2 = 2
  PLUS_SIGNAL_LV_1 = 3
  MINUS_SIGNAL_LV_1 = 4
  MINUS_SIGNAL_LV_2 = 5
  MINUS_SIGNAL_LV_3 = 6

  def initialize
    @rates = []
    @average_rates = []
    @range = 0

    # 平均値
    @avg = 0

    @plus_one_std_dev = 0
    @minus_one_std_dev = 0
    @plus_two_std_dev = 0
    @minus_two_std_dev = 0
  end

  def set_rate(rate:)
    @rates.push(rate)
    rates_ary_size = @rates.size
    if rates_ary_size > 60
      @rates = @rates[(rates_ary_size - 60)...rates_ary_size]
      @average_rates = @rates.each_slice(6).to_a.map { |ary| ary.inject(:+)/6 }

      # 平均値
      @avg = @rates.inject(:+)/@rates.size

      # 分散値
      var = @rates.reduce(0) { |a,b| a + (b - @avg) ** 2 } / (@rates.size - 1)

      # 標準偏差
      sd = Math.sqrt(var)

      @plus_one_std_dev = @avg + sd
      @minus_one_std_dev = @avg - sd
      @plus_two_std_dev = @avg + (2 * sd)
      @minus_two_std_dev = @avg - (2 * sd)
    end
  end

  # 単純に現在のレートが
  def check_signal_exec(rate)
    # データ不足
    return LACK_DATA if @rates.size < 60

    if @plus_two_std_dev <= rate
      # +2σ以上
      PLUS_SIGNAL_LV_3
    elsif @plus_one_std_dev <= rate && @plus_two_std_dev > rate
      # +1σ以上、+2σ未満
      PLUS_SIGNAL_LV_2
    elsif @avg <= rate && @plus_one_std_dev > rate
      # 平均以上、+1σ未満
      PLUS_SIGNAL_LV_1
    elsif @minus_one_std_dev <= rate && @avg > rate
      # -1σ以上、平均未満
      MINUS_SIGNAL_LV_1
    elsif @minus_two_std_dev <= rate && @minus_one_std_dev > rate
      # -2σ以上、-1σ未満
      MINUS_SIGNAL_LV_2
    else
      # -2σ以下
      MINUS_SIGNAL_LV_3
    end
  end
end