include SeedModule

ActiveRecord::Base.transaction do
  SeedModule.import("ticker")
  SeedModule.import("trade")
  SeedModule.import("order_book")
  SeedModule.import("rate")
end