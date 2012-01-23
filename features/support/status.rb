def get_status_code status
  case status
  when "láthatatlan" then RealActor::Application::OFFLINE_STATUS
  when "elérhető" then "null" #RealActor::Application::ONLINE_STATUS
  when "bannolt" then  RealActor::Application::BLOCKED_STATUS
  when "default" then "null"
  end
end
