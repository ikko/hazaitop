# -*- encoding : utf-8 -*-
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def commify(v) 
    a = (s=v.to_s;x=s.length;s).rjust(x+(3-(x%3))).scan(/.{3}/).join('.').strip
    if a[0] == 46
      a = a[1..-1]
    end
    a
  end

  def get_sort_param attr, default_order = 'asc'
    # default_order: az az alapállapot ami első rákattintásnál történik
    if default_order == 'desc'
      "#{@sort_field != attr || @sort_field == attr && @sort_direction == 'desc' ? '' : '-'}#{attr}"
    else
      "#{@sort_field != attr || @sort_field == attr && @sort_direction == 'asc' ? '-' : ''}#{attr}"
    end
  end

end

