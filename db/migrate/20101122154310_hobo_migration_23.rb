class HoboMigration23 < ActiveRecord::Migration
  def self.up
    add_column :people, :name, :string

    add_index :interpersonal_relation_calculators, [:related_p2o_relation_type_id], :name => 'index_interersonal_rel_calc'
  end

  def self.down
    remove_column :people, :name

    remove_index :interpersonal_relation_calculators, :name => :index_interpersonal_rel_calc rescue ActiveRecord::StatementInvalid
  end
end
