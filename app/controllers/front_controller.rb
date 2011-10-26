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
    render_tags(@organizations+@people+@litigations+@articles, :search_card, :for_type => true) if request.xhr?
  end

  def detailed_search
  end

  private

  def site_search(query)
    query = "" unless query.present? 
    org_page = person_page = litigation_page = article_page = 1
    case params[:object_type]
      when "person" then person_page = params[:page]
      when "org" then org_page = params[:page]
      when "litigation" then litigation_page = params[:page]
      when "article" then article_page = params[:page]
    end
    @organizations = Organization.search(query, :name).paginate(:per_page=>10, :page=>org_page)
    @people        = Person.search(query, :last_name, :first_name).paginate(:per_page=>10, :page=>person_page)
    @litigations   = Litigation.search(query, :name).paginate(:per_page=>10, :page=>litigation_page)
    @articles      = Article.search(query, :title).paginate(:per_page=>10, :page=>article_page)
  end
end
