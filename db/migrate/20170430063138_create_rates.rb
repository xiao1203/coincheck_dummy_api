class CreateRates < ActiveRecord::Migration[5.1]
  def change
    create_table :rates, id: :bigint, unsigned: true   do |t|
      t.text :json_body
      t.unsigned_bigint :trade_time_int
      t.string :pair

      t.timestamps
    end
  end
end
