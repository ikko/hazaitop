class OrganizationsController < ApplicationController

  hobo_model_controller

  auto_actions :all

  autocomplete

  index_action :query do
    render :json => Organization.name_contains(params[:term]).order_by(:name).limit(100).all(:select=>'id, name').map {|org|
      {:label => org.name, :id => org.id}
    }
  end
end
