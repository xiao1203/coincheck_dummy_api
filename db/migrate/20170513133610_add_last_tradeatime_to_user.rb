class AddLastTradeatimeToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :last_trade_time, :bigint, unsigned: true
  end
end
