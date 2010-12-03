class HoboMigration15 < ActiveRecord::Migration
  def self.up
    change_column :p2o_relation_types, :weight, :float, :limit => nil

    change_column :interpersonal_relation_calculators, :weight, :float, :limit => nil

    change_column :o2p_relation_types, :weight, :float, :limit => nil
  end

  def self.down
    change_column :p2o_relation_types, :weight, :integer

    change_column :interpersonal_relation_calculators, :weight, :integer

    change_column :o2p_relation_types, :weight, :integer
  end
end
