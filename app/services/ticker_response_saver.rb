class TickerResponseSaver < CommonResponseSaver
  def execute!
    id = 0
    CSV.open('./db/seed_datas/ticker.csv','w') do |test|
      test << %w(id json_body trade_time_int)
      while @stop_time > Time.zone.now # 時間が停止指定時間
        now_time_int = Time.zone.now.strftime("%Y%m%d%H%M%S").to_i
        id += 1
        begin
          retries = 0
          response = @cc.read_ticker
        rescue => e
          retries += 1
          if retries < 3
            retry # <-- Jumps to begin
          else
            # Error handling code, e.g.
            puts "Couldn't connect to proxy: #{e}"
          end
        end

        # response = @cc.read_ticker
        test << if response.code_type == Net::HTTPOK
                  [id, response.body, now_time_int]
                else
                  [id, "取得失敗", now_time_int]
                end

        # 取得停止時間と現時刻の差(秒)
        diff_sec = @stop_time - Time.zone.now
        if diff_sec > @interval_time
          sleep @interval_time
        elsif diff_sec > 0
          sleep diff_sec
        end
      end
    end
  end
end
