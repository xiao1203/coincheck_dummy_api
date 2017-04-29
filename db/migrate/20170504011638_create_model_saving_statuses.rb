class CreateModelSavingStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :model_saving_statuses, id: :bigint, unsigned: true   do |t|
      t.integer :status
      t.integer :model_number
      t.unsigned_bigint :seed_saving_status_id

      t.timestamps
    end
  end
end
