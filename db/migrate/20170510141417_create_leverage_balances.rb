class CreateLeverageBalances < ActiveRecord::Migration[5.1]
  def change
    create_table :leverage_balances, id: :bigint, unsigned: true do |t|
      t.column  :user_id, 'BIGINT UNSIGNED', :null => false
      t.integer :margin, default: 0
      t.integer :margin_available, default: 0
      t.float :margin_level, default: 0

      t.timestamps
    end
  end
end
