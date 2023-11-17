require 'app/require.rb'

def tick args
  if !args.inputs.keyboard.has_focus && args.state.tick_count != 0
    pause_scene args
  else
    args.state.scene ||= 'first'
    send("#{args.state.scene}_scene", $gtk.args)
    if args.inputs.keyboard.key_down.escape
      args.state.previous_scene = args.state.scene
      args.state.scene = 'pause'
    end
  end
end

def pause_scene args
  args.outputs.background_color = [0, 0, 0]
  args.outputs.labels << {
    x: 640,
    y: 360,
    text: 'Game Paused (click to resume).',
    alignment_enum: 1,
    r: 255,
    g: 255,
    b: 255
  }
  args.state.scene = args.state.previous_scene if args.inputs.keyboard.key_down.space
end

$gtk.reset
