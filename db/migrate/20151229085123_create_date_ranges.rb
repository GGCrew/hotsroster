class CreateDateRanges < ActiveRecord::Migration
  def change
    create_table :date_ranges do |t|
    	t.datetime	:start
    	t.datetime	:end

      t.timestamps null: false
    end
  end
end
