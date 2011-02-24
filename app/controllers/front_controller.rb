class FrontController < ApplicationController

  hobo_controller

  caches_page :index, :expires_in => 4.minutes
  caches_page :impressum, :expires_in => 90.minutes
  caches_page :development, :expires_in => 90.minutes

  def index; end

  def impressum; end

  def development; end

  def summary
    if !(current_user.administrator? or current_user.supervisor?)
      redirect_to user_login_path
    end
  end

  def search               
    if params[:query]      
      site_search(params[:query])
    end
  end

  private

  def site_search(query)
    results = Organization.name_contains(query) + Person.last_name_contains(query) + Person.first_name_contains(query) + Litigation.name_contains(query)
    all_results = results.select { |r| r.viewable_by?(current_user) }
    if all_results.empty?
      render :text => "<p>"+ ht(:"hobo.live_search.no_results", :default=>["Your search returned no matches."]) + "</p>"
    else
      render_tags(all_results, :search_card, :for_type => true)
    end
  end
end
