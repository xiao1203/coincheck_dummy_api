class CreateExchangeOrderRates < ActiveRecord::Migration[5.1]
  def change
    create_table :exchange_order_rates, id: :bigint, unsigned: true   do |t|
      t.text :json_body
      t.unsigned_bigint :trade_time_int

      t.timestamps
    end
  end
end
