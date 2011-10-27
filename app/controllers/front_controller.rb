class FrontController < ApplicationController

  hobo_model_controller

  caches_page :index, :expires_in => 4.minutes
  caches_page :impressum, :expires_in => 90.minutes
  caches_page :development, :expires_in => 90.minutes

  def index
<<<<<<< HEAD
    @people        = Person.list.apply_scopes(:order_by => parse_sort_param(:name, :information_source)).paginate(:per_page=>10, :page=>params[:page])
    @organizations = Organization.list.apply_scopes(:order_by => parse_sort_param(:name, :information_source)).paginate(:per_page=>10, :page=>params[:page])
    @contracts     = Contract.apply_scopes(:order_by => parse_sort_param(:name)).paginate(:per_page=>10, :page=>params[:page])
  end

  index_action :person_pagination do
    @people = Person.list.apply_scopes(:order_by => parse_sort_param(:name, :information_source)).paginate(:per_page=>10, :page=>params[:page])
  end

  index_action :org_pagination do
    @organizations = Organization.list.apply_scopes(:order_by => parse_sort_param(:name, :information_source)).paginate(:per_page=>10, :page=>params[:page])
  end

  index_action :contract_pagination do
    @contracts = Contract.apply_scopes(:order_by => parse_sort_param(:name)).paginate(:per_page=>10, :page=>params[:page])
    @people        = Person.list.apply_scopes(:order_by => parse_sort_param(:name, :information_source))
    @organizations = Organization.list.apply_scopes(:order_by => parse_sort_param(:name, :information_source))
  end

  def impressum; end

  def development; end

  def summary ; end

  def api ; end

  def search               
    site_search(params[:query])
    render_tags(@organizations+@people+@litigations+@articles, :search_card, :for_type => true) if request.xhr?
  end

  def detailed_search
  end

  private

  def site_search(query)
    query = "" unless query.present? 
    @organizations = Organization.search(query, :name).paginate(:per_page=>10, :page=>1)
    @people        = Person.search(query, :last_name, :first_name).paginate(:per_page=>10, :page=>1)
    @litigations   = Litigation.search(query, :name).paginate(:per_page=>10, :page=>1)
    @articles      = Article.search(query, :title).paginate(:per_page=>10, :page=>1)
  end
end
