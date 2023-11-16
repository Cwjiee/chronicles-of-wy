=begin
def defaults args
  args.state.walls ||= []
  args.state.flap_power = 11
  args.state.gravity = 0.9
  args.state.wall_gap_size = 100
  args.state.score ||= 0
  args.state.x ||= 50
  args.state.y ||= 500
  args.state.dy ||= 0
end

def render args
  render_walls args
  render_dragon args
end

def render_walls args
  args.state.walls.each do |wall|
    wall.sprites = [
      { x: wall.x, y: wall.bottom_height - 720, w: 100, h: 720, path: 'sprites/wy/wall.png',       angle: 180 },
      { x: wall.x, y: wall.top_y,               w: 100, h: 720, path: 'sprites/wy/wallbottom.png', angle: 0 }
    ]
  end
  args.outputs.sprites << args.state.map(& :sprites)
end

def calc args
  calc_walls args
end

def outputs args; end

def second_scene args
  defaults args
  render args
  calc args
  outputs args
end
=end

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

  if args.inputs.keyboard.key_down.space
    args.state.fireballs << {
      x: args.state.dragon.x + 100,
      y: args.state.dragon.y + 100,
      w: 40,
      h: 50,
      path: 'sprites/wy/fireball.png'
    }
  end
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
