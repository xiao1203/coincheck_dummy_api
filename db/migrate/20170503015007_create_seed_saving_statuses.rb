class CreateSeedSavingStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :seed_saving_statuses, id: :bigint, unsigned: true  do |t|
      t.integer :status

      t.timestamps
    end
  end
end
