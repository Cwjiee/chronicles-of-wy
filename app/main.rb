require 'app/require.rb'

def tick args
  if !args.inputs.keyboard.has_focus && args.state.tick_count != 0
    pause_scene args
  else
    args.audio[:bg_music] ||= { 
      input: 'sounds/audio.mp3',
      gain: 0.08,
      looping: true
    }
    args.state.scene ||= 'start'
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
  args.audio[:bg_music] = nil
  args.state.scene = args.state.previous_scene if args.inputs.keyboard.key_down.space
end

def start_scene args
  bg ||= []
  btn ||= []

  bg << {
    x: 0,
    y: 0,
    w: args.grid.w,
    h: args.grid.h,
    path: 'sprites/wy/Opening.png'
  }

  btn << {
    x: 640 - (250 / 2),
    y: 340,
    w: 250,
    h: 60,
    path: 'sprites/wy/Button.png'
  }

  if args.inputs.mouse.click
    clicked = btn.find do |b|
      args.inputs.mouse.intersect_rect? b
    end

    args.state.scene = 'first' if clicked
  end

  args.outputs.sprites << [bg, btn]

  args.outputs.labels << {
    x: 640,
    y: 550,
    text: 'Chronicles of Wy',
    alignment_enum: 1,
    font: 'fonts/oldEnglish.otf',
    size_enum: 30,
    r: 255,
    g: 255,
    b: 255
  }


  args.state.scene = 'first' if args.inputs.keyboard.key_down.space
end

def end_scene args
  args.outputs.labels << {
    x: 640,
    y: 550,
    text: 'The End',
    alignment_enum: 1,
    font: 'fonts/oldEnglish.otf',
    size_enum: 30,
    r: 255,
    g: 255,
    b: 255
  }

  args.outputs.labels << {
    x: 640,
    y: 440,
    text: 'CONGRATULATIONS!',
    alignment_enum: 1,
    r: 255,
    g: 255,
    b: 255,
    size_enum: 2
  }

  args.outputs.labels << {
    x: 640,
    y: 410,
    text: 'WY HAS GROWN INTO A',
    alignment_enum: 1,
    r: 255,
    g: 255,
    b: 255,
    size_enum: 2
  }

  args.outputs.labels << {
    x: 640,
    y: 380,
    text: 'MATURE WYVERN!',
    alignment_enum: 1,
    r: 255,
    g: 255,
    b: 255,
    size_enum: 2
  }

  args.outputs.sprites << {
    x: 0,
    y: 0,
    w: args.grid.w,
    h: args.grid.h,
    path: 'sprites/wy/End.png'
  }

  args.outputs.sprites << {
    x: 700,
    y: 280,
    w: 250,
    h: 250,
    path: 'sprites/wy/WyHappy.png'
  }
end

$gtk.reset
