class Guest < Hobo::Guest

  def administrator?
    false
  end

  def editor?
    false
  end

end
