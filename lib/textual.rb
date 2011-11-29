module Textual

  def to_textual_id
    foo = self.downcase.strip
    foo.gsub!(/[ĄÀ�?ÂÃâäàãáäå�?ăąǎǟǡǻ�?ȃȧẵặ]/,'a')
    foo.gsub!(/[Ęëêéèẽēĕėẻȅȇẹȩęḙḛ�?ếễểḕḗệ�?]/,'e')
    foo.gsub!(/[Ì�?ÎĨ�?iìíîĩīĭỉ�?ịįȉȋḭɨḯ]/,'i')
              foo.gsub!(/[ÒÓÔÕÖòóôõ�?�?ȯö�?őǒ�?�?ơǫ�?ɵøồốỗổȱȫȭ�?�?ṑṓ�?ớỡởợǭộǿ]/,'o')
              foo.gsub!(/[ÙÚÛŨÜùúûũūŭüủůűǔȕȗưụṳųṷṵṹṻǖǜǘǖǚừứữửự]/,'u')
              foo.gsub!(/[ỳýŷỹȳ�?ÿỷẙƴỵ]/,'y')
              foo.gsub!(/[œ]/,'oe')
              foo.gsub!(/[ÆǼǢæ]/,'ae')
              foo.gsub!(/[ñǹńŃ]/,'n')
              foo.gsub!(/[ÇçćĆ]/,'c')
              foo.gsub!(/[ß]/,'ss')
              foo.gsub!(/[œ]/,'oe')
              foo.gsub!(/[ĳ]/,'ij')
              foo.gsub!(/[�?łŁ]/,'l')
              foo.gsub!(/[śŚ]/,'s')
              foo.gsub!(/[źżŹŻ]/,'z')
              foo.gsub!(/[\s\'\"\\\/\?\.\=\+\&\%]$/,'')
              foo.gsub!(/[\s\'\"\\\/\?\.\=\+\&\%\(\)]/,'-')
              foo.gsub!(/[:]/,'')
              foo.gsub!(/-+/,'-')
              foo.gsub!(/[-]$/,'')
              foo
  end

end

class String
  include Textual
end
