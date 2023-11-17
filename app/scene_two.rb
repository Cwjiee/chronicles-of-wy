def defaults args
  args.state.score ||= 0
  args.state.fireballs ||= []
  args.state.targets ||= [
    render_target(args),
    render_target(args),
    render_target(args),
    render_target(args)
  ]
  args.state.timer ||= 30 * 60
end

def render args
  render_dragon args
end

def render_dragon args
  args.state.dragon ||= {
    x: 50,
    y: 500,
    w: 200,
    h: 150,
    speed: 10,
    path: 'sprites/wy/adult-0.png',
    flip_horizontally: true
  }
end

def render_target args
  size = 64
  type = rand 3
  {
    x: args.grid.w + rand(args.grid.w),
    y: rand(args.grid.h - size * 2) + size,
    w: size,
    h: size,
    path: "sprites/wy/fish-#{type}.png"
  }
end

def inputs args
  if args.inputs.keyboard.key_held.w
    args.state.dragon.y += args.state.dragon.speed
  elsif args.inputs.keyboard.key_held.a
    args.state.dragon.x -= args.state.dragon.speed
  elsif args.inputs.keyboard.key_held.s
    args.state.dragon.y -= args.state.dragon.speed
  elsif args.inputs.keyboard.key_held.d
    args.state.dragon.x += args.state.dragon.speed
  end

  return unless args.inputs.keyboard.key_down.space

  args.state.fireballs << {
    x: args.state.dragon.x + 100,
    y: args.state.dragon.y + 100,
    w: 40,
    h: 50,
    path: 'sprites/wy/fireball.png'
  }
end

def calc args
  args.state.fireballs.each do |fireball|
    fireball.x += args.state.dragon.speed + 2
    fireball.dead = true if fireball.x.negative?
  end

  args.state.fireballs.reject!(&:dead)

  args.state.targets.each do |target|
    target.x -= args.state.dragon.speed
    if target.x.negative?
      target.dead = true
      args.state.targets << render_target(args)
    end
    if target.intersect_rect? args.state.dragon
      args.state.scene = 'second_gameover'
      break
    end
  end

  args.state.targets.reject!(&:dead)

  second_game_timer args
end

def second_game_timer args
  args.state.timer -= 1

  args.state.scene = 'second_gameover' if args.state.timer.negative?
end

def second_gameover_scene args
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

    second_scene_reset(args) if args.inputs.keyboard.key_down.space
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

def second_scene_reset args
  args.state.score = 0
  args.state.fireballs = []
  args.state.targets = [
    render_target(args),
    render_target(args),
    render_target(args),
    render_target(args)
  ]
  args.state.timer = 30 * 60
  args.state.scene = 'second'
end

def second_scene args
  defaults args
  render args
  inputs args
  calc args
  args.outputs.sprites << [args.state.dragon, args.state.fireballs, args.state.targets]
  args.outputs.labels << {
    x: 50,
    y: 50,
    text: "Timer: #{(args.state.timer / 60).round}",
    size_enum: 10
  }
end
