class HoboMigration21 < ActiveRecord::Migration
  def self.up
    drop_table :revealed_interpersonal_relations

    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_a_id rescue ActiveRecord::StatementInvalid
    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_b_id rescue ActiveRecord::StatementInvalid

  end

  def self.down
    create_table "revealed_interpersonal_relations", :force => true do |t|
      t.integer  "weight"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index :interorg_relations, [:organization_id], :name => 'index_interorg_relations_on_organization_a_id'
    add_index :interorg_relations, [:related_organization_id], :name => 'index_interorg_relations_on_organization_b_id'

  end
end
