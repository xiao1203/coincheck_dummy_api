class BitflyerExecutionResponseSaver < CommonDirectResponseSaver
  def initialize(pair:, stop_time:, interval_time:)
    super

    @uri = URI.parse("https://api.bitflyer.jp/v1/executions")
    @https = Net::HTTP.new(@uri.host, @uri.port)
    @https.use_ssl = true
    @csv_file_path = './db/seed_datas/bitflyer_execution.csv'
  end
end