class RateResponseSaver < CommonDirectResponseSaver
  def initialize(pair:, stop_time:, interval_time:)
    super

    @uri = URI.parse("https://coincheck.jp/api/rate/#{@pair}")
    @https = Net::HTTP.new(@uri.host, @uri.port)
    @https.use_ssl = true
    @csv_file_path = './db/seed_datas/rate.csv'
  end
end
