# -*- encoding : utf-8 -*-
class HoboMigration19 < ActiveRecord::Migration
  def self.up
    add_column :interpersonal_relations, :article_id, :integer

    add_column :interorg_relations, :article_id, :integer

    add_column :person_to_org_relations, :article_id, :integer

    remove_column :articles, :articable_id
    remove_column :articles, :articable_type

    add_index :interpersonal_relations, [:article_id]

    add_index :interorg_relations, [:article_id]

    add_index :person_to_org_relations, [:article_id]

    remove_index :articles, :name => :index_articles_on_articable_type_and_articable_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    remove_column :interpersonal_relations, :article_id

    remove_column :interorg_relations, :article_id

    remove_column :person_to_org_relations, :article_id

    add_column :articles, :articable_id, :integer
    add_column :articles, :articable_type, :string

    remove_index :interpersonal_relations, :name => :index_interpersonal_relations_on_article_id rescue ActiveRecord::StatementInvalid

    remove_index :interorg_relations, :name => :index_interorg_relations_on_article_id rescue ActiveRecord::StatementInvalid

    remove_index :person_to_org_relations, :name => :index_person_to_org_relations_on_article_id rescue ActiveRecord::StatementInvalid

    add_index :articles, [:articable_type, :articable_id]
  end
end

