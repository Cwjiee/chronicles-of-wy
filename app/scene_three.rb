def defaults(args)
  args.state.buttons ||= [
    create_button(args, id: :button_1, row: 12, col: 4, text: 'button 1'),
    create_button(args, id: :button_2, row: 12, col: 8, text: 'button 2'),
    create_button(args, id: :clear, row: 12, col: 12, text: 'clear')
  ]
  args.state.enemies ||= render_enemies(args)

  args.state.fireballs ||= []
  args.state.dragon_hitpoint ||= 100
  args.state.hitpoint ||= 100
  args.state.fireball_dmg ||= 20
  args.state.enemy_dmg ||= 15
  args.state.turn_index ||= 0
  args.state.timer ||= 3 * 60
end

def render_dragon args
  args.state.dragon ||= {
    x: (args.grid.w / 2) - 50,
    y: 200,
    w: 200,
    h: 150,
    speed: 10,
    path: 'sprites/wy/adult-0.png',
    flip_horizontally: true
  }
end

def render_enemies args
  {
    x: (args.grid.w / 2) - 50,
    y: 500,
    w: 200,
    h: 150,
    path: 'sprites/wy/Griffin.png',
    flip_horizontally: true,
    r: 255,
    g: 255,
    b: 255
  }
end

def render args
  args.outputs.primitives << args.state.buttons.map do |b|
    b.primitives
  end

  render_dragon args

  args.outputs.labels << {
    x: args.state.enemies.x,
    y: args.state.enemies.y + args.state.enemies.h,
    text: args.state.hitpoint.to_s,
    alignment_enum: 1,
    vertical_alignment_enum: 1
  }

  args.outputs.labels << {
    x: args.state.dragon.x,
    y: args.state.dragon.y + args.state.dragon.h,
    text: args.state.dragon_hitpoint.to_s,
    alignment_enum: 1,
    vertical_alignment_enum: 1
  }

  if args.state.center_label_text
    args.outputs.labels << {
      x: 640,
      y: 360,
      text: args.state.center_label_text,
      alignment_enum: 1,
      vertical_alignment_enum: 1
    }
  end


  args.outputs.sprites << [args.state.enemies, args.state.dragon, args.state.fireballs]
end

def inputs args
  if args.inputs.mouse.click
    button = args.state.buttons.find do |b|
      args.inputs.mouse.intersect_rect? b
    end

    fireball = {
      x: args.state.dragon.x + 100,
      y: args.state.dragon.y + 100,
      w: 40,
      h: 50,
      path: 'sprites/wy/fireball.png'
    }

    big_fireball = {
      x: args.state.dragon.x + 100,
      y: args.state.dragon.y + 100,
      w: 70,
      h: 80,
      path: 'sprites/wy/fireball.png'
    }

    if args.state.turn_index % 2 == 0
      case button.id
      when :button_1
        args.state.fireballs << fireball
        args.state.center_label_text = 'button 1 was clicked'
        args.state.turn_index += 1
      when :button_2
        args.state.fireballs << big_fireball
        args.state.center_label_text = 'button 2 was clicked'
        args.state.turn_index += 1
      when :clear
        args.state.center_label_text = nil
        args.state.turn_index += 1
      end
    end
  end
end

def calc args
  args.state.fireballs.each do |fireball|
    fireball.y += args.state.dragon.speed + 2
    fireball.dead = true if fireball.x > args.grid.h
    if fireball.intersect_rect? args.state.enemies
      args.state.hitpoint -= args.state.fireball_dmg
      fireball.dead = true
    end
  end

  args.state.fireballs.reject!(&:dead)

  if args.state.turn_index % 2 != 0
    args.state.timer -= 1
  end

  if args.state.timer.negative?
    args.state.dragon_hitpoint -= 20
    args.state.turn_index += 1
    args.state.timer = 3 * 60
    puts 'again'
  end

  check_gameover args
end

def check_gameover args
  if args.state.dragon_hitpoint <= 0 || args.state.hitpoint <= 0
    args.state.scene = "third_gameover"
  end
end

def third_gameover_scene args
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
      text: 'You have defeated the enemy',
      size_enum: 10
    }
    labels << {
      x: (args.grid.w / 2) - 50,
      y: args.grid.h - 132,
      text: 'Press space to enter the next stage'
    }

    if args.inputs.keyboard.key_down.space
      args.state.scene = 'end'
      return
    end
  end
  args.outputs.labels << labels
end

def create_button(args, id:, row:, col:, text:)
  rect = args.layout.rect row: row, col: col, w: 3, h: 1

  center = args.geometry.rect_center_point rect

  {
    id: id,
    x: rect.x,
    y: rect.y,
    w: rect.w,
    h: rect.h,
    primitives: [
      {
        x: rect.x,
        y: rect.y,
        w: rect.w,
        h: rect.h,
        primitive_marker: :border
      },
      {
        x: center.x,
        y: center.y,
        text: text,
        size_enum: -1,
        alignment_enum: 1,
        vertical_alignment_enum: 1,
        primitive_marker: :label
      }
    ]
  }
end

def third_scene(args)
  defaults args
  render args
  inputs args
  calc args
end
