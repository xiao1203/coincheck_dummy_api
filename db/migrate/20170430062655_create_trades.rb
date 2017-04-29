class CreateTrades < ActiveRecord::Migration[5.1]
  def change
    create_table :trades, id: :bigint, unsigned: true do |t|
      t.text :json_body
      t.unsigned_bigint :trade_time_int

      t.timestamps
    end
  end
end
