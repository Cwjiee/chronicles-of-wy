def spawn_falling_objects(args)
  type = rand(3)
  {
    x: rand(args.grid.w),
    y: args.grid.h - 60,
    w: 60,
    h: 60,
    speed: 5,
    path: "sprites/misc/fish-#{type}.png",
    dead: false,
    angle: 90
  }
end

# calc
def dragon_movement args
  sprite_index = 0.frame_index(count: 2, hold_for: 8, repeat: true)
  args.state.dragon.path = "sprites/wy/baby-#{sprite_index}.png"

  if args.inputs.keyboard.key_held.a
    args.state.dragon.x -= args.state.dragon.speed
    if args.state.dragon.flip_horizontally == true
      args.state.dragon.flip_horizontally = false
    end
  elsif args.inputs.keyboard.key_held.d
    args.state.dragon.x += args.state.dragon.speed
    if args.state.dragon.flip_horizontally == false
      args.state.dragon.flip_horizontally = true
    end
  end
end

def falling_objects_movement args
  args.state.falling_objects.each do |obj|
    obj.y -= obj.speed
    if obj.y.negative?
      obj.dead = true
      args.state.falling_objects << spawn_falling_objects(args)
    end
  end
end

def game_timer(args)
  args.state.timer -= 1

  if args.state.timer.negative?
    args.state.scene = 'first_gameover'
    return
  end
end

def scoring_logic args
  args.state.falling_objects.each do |obj|
    if obj.intersect_rect? args.state.dragon
      obj.dead = true
      args.state.falling_objects << spawn_falling_objects(args)
      args.state.score += 1
    end
  end
end

def first_gameover_scene(args)
  labels = []
  if args.state.score < 10
    labels << {
      x: (args.grid.w / 2) - 50,
      y: args.grid.h - 90,
      text: "Time's Up!",
      size_enum: 10
    }
    labels << {
      x: (args.grid.w / 2) - 50,
      y: args.grid.h - 132,
      text: 'Press space to try again',
      size_enum: 2
    }

    $gtk.reset if args.inputs.keyboard.key_down.space
  else
    labels << {
      x: (args.grid.w / 2) - 50,
      y: args.grid.h - 90,
      text: 'You have reached the targeted score!',
      size_enum: 10
    }
    labels << {
      x: (args.grid.w / 2) - 50,
      y: args.grid.h - 132,
      text: 'Press space to enter the next stage'
    }

    if args.inputs.keyboard.key_down.space
      args.state.scene = 'second'
      return
    end
  end
  args.outputs.labels << labels
end

def first_scene(args)
  args.state.score ||= 0
  args.state.timer ||= 30 * 60
  args.state.dragon ||= {
    x: 640 - 60,
    y: 0,
    w: 100,
    h: 100,
    speed: 8,
    flip_horizontally: false
  }
  args.state.falling_objects ||= [
    spawn_falling_objects(args)
  ]

  args.outputs.sprites << [args.state.dragon, args.state.falling_objects]
  args.outputs.labels << [
    {
      x: 40,
      y: args.grid.h - 40,
      text: "Score: #{args.state.score}/10",
      size_enum: 4
    },
    {
      x: args.grid.w - 40,
      y: args.grid.h - 40,
      text: "Timer: #{(args.state.timer / 60).round}",
      size_enum: 2,
      alignment_enum: 2
    }
  ]

  game_timer(args)
  dragon_movement args
  falling_objects_movement args

  scoring_logic args
  args.state.falling_objects.reject! { |t| t.dead }
end
