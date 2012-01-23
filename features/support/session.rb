module SessionHelper

  def get_session(user)
    return $DEFAULT_SESSION if user == model("én")
    @session ||= {}
    @session[user.name] ||= Capybara::Session.new(Capybara.current_driver, Capybara.app)
  end
end

World(SessionHelper)
