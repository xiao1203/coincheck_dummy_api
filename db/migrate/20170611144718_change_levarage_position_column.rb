class ChangeLevaragePositionColumn < ActiveRecord::Migration[5.1]
  # 変更内容
  def change
    change_column :leverage_positions, :amount, :decimal, precision:  9, scale: 3
    change_column :leverage_positions, :all_amount, :decimal, precision:  9, scale: 3
    change_column :leverage_positions, :open_rate, :decimal, precision:  9, scale: 3
    change_column :leverage_positions, :close_rate, :decimal, precision:  9, scale: 3
    change_column :leverage_positions, :stop_loss_rate, :decimal, precision:  9, scale: 3
    change_column :leverage_positions, :pl, :decimal, precision:  9, scale: 3
  end
end
