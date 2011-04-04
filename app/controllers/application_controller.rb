# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  include Hobo::AuthenticationSupport
  #  before_filter :login_required

  def fill_drop_down
#    @organizations = Organization.all
#    @people = Person.all
    @o2o_types = O2oRelationType.visual + O2oRelationType.litig
    @p2p_types = P2pRelationType.not_internal
    @p2o_types = P2oRelationType.all
    @info_sources = InformationSource.not_internal
    @recent_articles = Article.recent(30)
  end

end
