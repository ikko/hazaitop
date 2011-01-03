class HoboMigration20 < ActiveRecord::Migration
  def self.up
    create_table :article_relations do |t|
      t.integer :relationable_id
      t.string  :relationable_type
      t.integer :article_id
    end
    add_index :article_relations, [:relationable_type, :relationable_id]
    add_index :article_relations, [:article_id]

    remove_column :interpersonal_relations, :article_id

    remove_column :interorg_relations, :article_id

    remove_column :person_to_org_relations, :article_id

    remove_index :interpersonal_relations, :name => :index_interpersonal_relations_on_article_id rescue ActiveRecord::StatementInvalid

    remove_index :interorg_relations, :name => :index_interorg_relations_on_article_id rescue ActiveRecord::StatementInvalid

    remove_index :person_to_org_relations, :name => :index_person_to_org_relations_on_article_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    add_column :interpersonal_relations, :article_id, :integer

    add_column :interorg_relations, :article_id, :integer

    add_column :person_to_org_relations, :article_id, :integer

    drop_table :article_relations

    add_index :interpersonal_relations, [:article_id]

    add_index :interorg_relations, [:article_id]

    add_index :person_to_org_relations, [:article_id]
  end
end
