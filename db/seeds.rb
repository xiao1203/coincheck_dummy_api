include SeedModule

ActiveRecord::Base.transaction do
  SeedModule.import("ticker", delete_all: true)
  SeedModule.import("trade", delete_all: true)
  SeedModule.import("order_book", delete_all: true)
  SeedModule.import("rate", delete_all: true)

  # SeedModule.import("zaif_ticker", delete_all: true)
  # SeedModule.import("zaif_trade", delete_all: true)
  # SeedModule.import("zaif_depth", delete_all: true)
  #
  # SeedModule.import("bitflyer_ticker", delete_all: true)
  # SeedModule.import("bitflyer_board", delete_all: true)
  # SeedModule.import("bitflyer_execution", delete_all: true)
end