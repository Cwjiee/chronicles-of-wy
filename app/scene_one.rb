def spawn_falling_objects(args)
  type = rand(3)
  {
    x: rand(args.state.grid.w) + 60,
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
  args.state.falling_objects.each { |x| x.y -= x.speed }
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

def first_scene(args)
  args.state.score ||= 0
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

  dragon_movement args
  falling_objects_movement args

  scoring_logic args
  args.state.falling_objects.reject! { |t| t.dead }
end
