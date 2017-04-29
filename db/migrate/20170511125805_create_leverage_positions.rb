class CreateLeveragePositions < ActiveRecord::Migration[5.1]
  def change
    create_table :leverage_positions, id: :bigint, unsigned: true do |t|
      t.string :pair
      t.string :status
      t.datetime :closed_at
      t.decimal :open_rate
      t.decimal :close_rate
      t.decimal :amount
      t.decimal :all_amount
      t.string :side
      t.decimal :stop_loss_rate
      t.decimal :pl
      t.column  :user_id, 'BIGINT UNSIGNED', :null => false

      t.timestamps
    end
  end
end
