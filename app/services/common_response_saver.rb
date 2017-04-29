class CommonResponseSaver
  def initialize(coincheck_client:, stop_time:, interval_time:)
    @cc = coincheck_client
    @stop_time = stop_time
    @interval_time = interval_time
  end
end
