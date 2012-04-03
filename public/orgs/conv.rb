Dir.foreach '.' do |file|
  next if file =='.' or file == '..'
  system "enconv -L hu -x utf8 #{file}"
end
