# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def commify(v) 
    a = (s=v.to_s;x=s.length;s).rjust(x+(3-(x%3))).scan(/.{3}/).join('.').strip
    if a[0] == 46
      a = a[1..-1]
    end
    a
  end


end
