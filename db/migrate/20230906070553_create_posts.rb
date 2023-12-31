class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.integer :member_id,  null: false
      t.string :title,       null: false
      t.string :tool,        null: false
      t.text :body,          null: false
      t.boolean :is_publish, null: false, default: true
      t.timestamps
    end
  end
end
