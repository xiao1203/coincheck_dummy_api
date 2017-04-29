class CreateBalances < ActiveRecord::Migration[5.1]
  def change
    create_table :balances, id: :bigint, unsigned: true do |t|
      t.column  :user_id, 'BIGINT UNSIGNED', :null => false
      t.integer :jpy, default: 0
      t.integer :btc, default: 0
      t.integer :jpy_reserved, default: 0
      t.integer :btc_reserved, default: 0
      t.integer :jpy_lend_in_use, default: 0
      t.integer :btc_lend_in_use, default: 0
      t.integer :jpy_lent, default: 0
      t.integer :btc_lent, default: 0
      t.integer :jpy_debt, default: 0
      t.integer :btc_debt, default: 0

      t.timestamps
    end
  end
end
