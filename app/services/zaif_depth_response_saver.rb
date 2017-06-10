class ZaifDepthResponseSaver < CommonDirectResponseSaver
  def initialize(pair:, stop_time:, interval_time:)
    super

    @uri = URI.parse("https://api.zaif.jp/api/1/depth/#{@pair}")
    @https = Net::HTTP.new(@uri.host, @uri.port)
    @https.use_ssl = true
    @csv_file_path = './db/seed_datas/zaif_depth.csv'
  end
end