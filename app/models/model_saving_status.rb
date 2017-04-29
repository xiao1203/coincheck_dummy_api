class ModelSavingStatus < ApplicationRecord
  extend Enumerize

  enumerize :status, in: {
                       none: 0,
                       doing: 1,
                       done: 2,
                       error: 3
                   }, predicates: true

  enumerize :model_number, in: {
      ticker: 0,
      trade: 1,
      order_book: 2,
      btc_jpy_rate: 3
  }
  belongs_to :seed_saving_status
end
