class CreateBitflyerExecutions < ActiveRecord::Migration[5.1]
  def change
    create_table :bitflyer_executions, id: :bigint, unsigned: true do |t|
      t.text :json_body, :limit => 4294967295
      t.unsigned_bigint :trade_time_int
      t.string :pair

      t.timestamps
    end
  end
end
