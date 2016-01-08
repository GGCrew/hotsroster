class AddValueToFranchise < ActiveRecord::Migration
  def change
  	add_column	'franchises', 'value', :string,	after: 'name'
  end
end
