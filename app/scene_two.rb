def defaults args
  args.state.score ||= 0
  args.state.targets ||= [
    render_target(args),
    render_target(args),
    render_target(args)
  ]
  args.state.fireballs ||= []
end

def render args
  render_dragon args
  render_target args
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
  {
    x: rand(args.grid.w * 0.4) + args.grid.w * 0.6,
    y: rand(args.grid.h - size * 2) + size,
    w: size,
    h: size,
    path: 'sprites/target.png'
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
  end
end

def second_scene args
  defaults args
  render args
  inputs args
  calc args
  args.outputs.sprites << [args.state.dragon, args.state.fireballs]
end
