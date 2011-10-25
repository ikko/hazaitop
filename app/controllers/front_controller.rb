class FrontController < ApplicationController

  hobo_model_controller

  caches_page :index, :expires_in => 4.minutes
  caches_page :impressum, :expires_in => 90.minutes
  caches_page :development, :expires_in => 90.minutes

  def index
    @people        = Person.list.apply_scopes(:order_by => parse_sort_param(:name, :information_source))
    @organizations = Organization.list.apply_scopes(:order_by => parse_sort_param(:name, :information_source))
  end

  def impressum; end

  def development; end

  def summary ; end

  def api ; end

  def search               
    site_search(params[:query])
    render_tags(@organizations+@people+@litigations+@articles, :search_card, :for_type => true)
  end

  def detailed_search
  end

  private

  def site_search(query)
    @organizations = Organization.search(query, :name)
    @people        = Person.search(query, :last_name, :first_name)
    @litigations   = Litigation.search(query, :name) 
    @articles      = Article.search(query, :title)
  end
end
