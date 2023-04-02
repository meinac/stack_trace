require "mkmf"

if ENV['ST_DEBUG']
  $defs << "-DST_DEBUG"
end

create_makefile("stack_trace/ext/stack_trace")
