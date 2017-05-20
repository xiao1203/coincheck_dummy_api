include SeedModule

ActiveRecord::Base.transaction do
  SeedModule.import("ticker", delete_all: true)
  SeedModule.import("trade", delete_all: true)
  SeedModule.import("order_book", delete_all: true)
  SeedModule.import("rate", delete_all: true)
end