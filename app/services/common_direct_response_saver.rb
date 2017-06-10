class CommonDirectResponseSaver
  require "openssl"

  def initialize(pair:, stop_time:, interval_time:)
    @pair = pair
    @stop_time = stop_time
    @interval_time = interval_time

    # public APIだから空で良い
    @headers = {
        "ACCESS-KEY" => "",
        "ACCESS-NONCE" => "",
        "ACCESS-SIGNATURE" => ""
    }
  end

  def execute!
    id = 0
    CSV.open(@csv_file_path,'w') do |test|
      test << %w(id json_body trade_time_int pair)
      while @stop_time > Time.zone.now # 時間が停止指定時間
        now_time_int = Time.zone.now.strftime("%Y%m%d%H%M%S").to_i
        id += 1
        begin
          retries = 0
          response = @https.start {
            @https.get(@uri.request_uri, @headers)
          }
        rescue => e
          retries += 1
          if retries < 3
            retry # <-- Jumps to begin
          else
            # Error handling code, e.g.
            puts "Couldn't connect to proxy: #{e}"
          end
        end
        test << if response.code_type == Net::HTTPOK
                  [id, response.body, now_time_int, @pair]
                else
                  [id, "取得失敗", now_time_int, @pair]
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
