class ArticlesController < ApplicationController

  hobo_model_controller

  auto_actions :all

  autocomplete :title

  def new
    fill_drop_down
    hobo_new
  end

  def edit
    @this = find_instance
    fill_drop_down
  end

  def show
    @this = find_instance
    @interpersonal_relations_size = @this.interpersonal_relations.size
    @person_to_org_relations_size = @this.person_to_org_relations.size
    @interorg_relations_size = @this.interorg_relations.size

    respond_to do |format| 
      format.html  { hobo_show @this }
      format.xml   { render(:xml => @this) }
      format.json  { render(:json=> @this) }
    end
  end


end
