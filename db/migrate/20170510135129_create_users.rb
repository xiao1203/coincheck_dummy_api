class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users, id: :bigint, unsigned: true do |t|
      t.string :api_key
      t.string :secret_key

      t.timestamps
    end
  end
end
