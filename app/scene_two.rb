def second_defaults args
  args.state.fireballs ||= []
  args.state.targets ||= [
    second_render_target(args),
    second_render_target(args),
    second_render_target(args),
    second_render_target(args)
  ]
  args.state.second_timer ||= 15 * 60
  args.state.finish ||= false
end

def second_render args
  second_render_dragon args
end

def second_render_dragon args
  args.state.second_dragon ||= {
    x: 50,
    y: 500,
    w: 200,
    h: 150,
    speed: 10,
    path: 'sprites/wy/Wy2.png',
    flip_horizontally: true
  }
  sprite_index = 0.frame_index(count: 2, hold_for: 18, repeat: true)
  args.state.second_dragon.path = "sprites/wy/teen-#{sprite_index}.png"
end

def second_render_target args
  size = 64
  type = rand 3
  {
    x: args.grid.w + rand(args.grid.w),
    y: rand(args.grid.h - size * 2) + size,
    w: size,
    h: size,
    path: "sprites/wy/Rock#{type + 1}.png"
  }
end

def second_inputs args
  if args.inputs.keyboard.key_held.w
    args.state.second_dragon.y += args.state.second_dragon.speed
  elsif args.inputs.keyboard.key_held.a
    args.state.second_dragon.x -= args.state.second_dragon.speed
  elsif args.inputs.keyboard.key_held.s
    args.state.second_dragon.y -= args.state.second_dragon.speed
  elsif args.inputs.keyboard.key_held.d
    args.state.second_dragon.x += args.state.second_dragon.speed
  end

  return unless args.inputs.keyboard.key_down.space

  args.state.fireballs << {
    x: args.state.second_dragon.x + 100,
    y: args.state.second_dragon.y + 100,
    w: 40,
    h: 50,
    path: 'sprites/wy/fireball.png'
  }
end

def second_calc args
  args.state.fireballs.each do |fireball|
    fireball.x += args.state.second_dragon.speed + 2
    fireball.dead = true if fireball.x.negative?
  end

  args.state.fireballs.reject!(&:dead)

  args.state.targets.each do |target|
    target.x -= args.state.second_dragon.speed
    if target.x.negative?
      target.dead = true
      args.state.targets << second_render_target(args)
    end
    if target.intersect_rect? args.state.second_dragon
      args.state.scene = 'second_gameover'
      break
    end
  end

  args.state.targets.reject!(&:dead)

  second_game_timer args
end

def second_game_timer args
  args.state.second_timer -= 1

  return unless args.state.second_timer.negative?

  args.state.finish = true
  args.state.scene = 'second_gameover'
end

def second_gameover_scene args
  labels = []
  if !args.state.finish
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

    second_scene_reset(args) if args.inputs.keyboard.key_down.space
  else
    labels << {
      x: (args.grid.w / 2) - 50,
      y: args.grid.h - 90,
      text: 'You have reached the targeted time!',
      size_enum: 10
    }
    labels << {
      x: (args.grid.w / 2) - 50,
      y: args.grid.h - 132,
      text: 'Press space to enter the next stage'
    }

    if args.inputs.keyboard.key_down.space && args.state.finish
      args.state.scene = 'third'
      return
    end
  end
  args.outputs.labels << labels
end

def second_scene_reset args
  args.state.finish = false
  args.state.fireballs = []
  args.state.targets = [
    second_render_target(args),
    second_render_target(args),
    second_render_target(args),
    second_render_target(args)
  ]
  args.state.second_timer = 15 * 60
  args.state.scene = 'second'
end

def second_scene args
  second_defaults args
  second_render args
  second_inputs args
  second_calc args
  args.outputs.sprites << [args.state.second_dragon, args.state.fireballs, args.state.targets]
  if args.state.second_timer
    args.outputs.labels << {
      x: 50,
      y: 50,
      text: "timer: #{(args.state.second_timer / 60).round}",
      size_enum: 10
    }
  end
end
