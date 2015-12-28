class CreateTypps < ActiveRecord::Migration
  def change
    create_table :typps do |t|
    	t.string	:name
    	t.string	:slug

      t.timestamps null: false
    end
  end
end
