module Hobofix
  def parse_sort_param(*sort_fields)
    if params[:sort]
      _, desc, field = *params[:sort]._?.match(/^(-)?([a-z0-9_]+(?:\.[a-z0-9_]+)?)$/)

      if field
        if field.in?(sort_fields.*.to_s)
          @sort_field = field
          @sort_direction = desc ? "desc" : "asc"

          [@sort_field, @sort_direction].join(' ')
        end
      end
    else
      ''
    end
  end
end
