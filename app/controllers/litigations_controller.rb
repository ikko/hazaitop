# -*- encoding : utf-8 -*-
class LitigationsController < ApplicationController

  hobo_model_controller

  auto_actions :all

  index_action :query do
    render :json => Litigation.name_contains(params[:term]).order_by(:name).limit(100).all(:select=>'id, name').map {|litigation|
      {:label => litigation.name, :id => litigation.id}
    }
  end

  index_action :interpersonal_pagination do
    @this = find_instance
    return unless @this
    @interpersonals = @this.interpersonal_relations.paginate(:per_page=>10, :page=>params[:page])
  end

  index_action :interorg_pagination do
    @this = find_instance
    return unless @this
    @interorgs = @this.interorg_relations.paginate(:per_page=>10, :page=>params[:page])
  end

  index_action :person_to_org_pagination do
    @this = find_instance
    return unless @this
    @person_to_orgs = @this.interorg_relations.paginate(:per_page=>10, :page=>params[:page])
  end

  def show
    @this = find_instance
  end
end

