# -*- encoding : utf-8 -*-
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
    @o2o_types = O2oRelationType.visual.not_parsed + O2oRelationType.litig.not_parsed
    @p2p_types = P2pRelationType.not_internal.not_parsed
    @p2o_types = P2oRelationType.not_parsed
    @info_sources = InformationSource.not_internal
    @recent_articles = Article.limit(0)
  end

end

