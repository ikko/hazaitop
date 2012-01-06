# encoding: UTF-8
module Textual

  def to_textual_id
    
    foo = self.downcase.strip
#   foo.gsub!(/[Áá]/,'a')
#   foo.gsub!(/[Éé]/,'e')
#    foo.gsub!(/[Íí]/,'i')
#              foo.gsub!(/[ÓÖŐóöő]/,'o')
#              foo.gsub!(/[ÚÜŰúüű]/,'u')
#              foo.gsub!(/[ß]/,'ss')
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
