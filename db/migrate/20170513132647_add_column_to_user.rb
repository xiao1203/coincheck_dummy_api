class AddColumnToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :start_trade_time, :bigint, unsigned: true
  end
end
