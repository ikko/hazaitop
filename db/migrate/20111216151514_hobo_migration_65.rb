class HoboMigration65 < ActiveRecord::Migration
  def self.up
    add_column :organizations, :ksh_number, :string
    add_column :organizations, :social_security_number, :string
    add_column :organizations, :law_successor_cgjsz, :string
    add_column :organizations, :law_successed_at, :date
    add_column :organizations, :law_successor_id, :integer

    change_column :interorg_relations, :weight, :float, :default => 1

    change_column :person_to_org_relations, :weight, :float, :default => 1

    change_column :interpersonal_relation_calculators, :weight, :float, :default => 1

    add_index :organizations, [:law_successor_id]
  end

  def self.down
    remove_column :organizations, :ksh_number
    remove_column :organizations, :social_security_number
    remove_column :organizations, :law_successor_cgjsz
    remove_column :organizations, :law_successed_at
    remove_column :organizations, :law_successor_id

    change_column :interorg_relations, :weight, :float

    change_column :person_to_org_relations, :weight, :float

    change_column :interpersonal_relation_calculators, :weight, :float

    remove_index :organizations, :name => :index_organizations_on_law_successor_id rescue ActiveRecord::StatementInvalid
  end
end
