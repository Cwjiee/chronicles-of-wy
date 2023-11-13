require 'app/require.rb'

def tick args
  args.state.scene ||= "first"
  send("#{args.state.scene}_scene", $gtk.args)
end

$gtk.reset
