class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.text :user_id
      t.text :url

      t.timestamps
    end
  end
end
