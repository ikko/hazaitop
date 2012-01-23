require 'open3'
def console_run command
  $CONSOLE_STDIN, $CONSOLE_STDOUT, $CONSOLE_STDERR = Open3.popen3 command 
end
