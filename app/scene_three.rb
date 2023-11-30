def defaults(args)
  args.state.buttons ||= [
    create_button(args, id: :button_1, row: 11, col: 6, text: 'fireball'),
    create_button(args, id: :button_2, row: 11, col: 10, text: 'block'),
    create_button(args, id: :skip, row: 11, col: 14, text: 'skip')
  ]
  args.state.griffin ||= render_enemies(args)

  args.state.fireballs_atk ||= []
  args.state.enemy_atk ||= []
  args.state.dragon_hitpoint ||= 100
  args.state.hitpoint ||= 100
  args.state.fireball_dmg ||= 20
  args.state.enemy_dmg ||= 15
  args.state.turn_index ||= 0
  args.state.third_timer ||= 3 * 60
  args.state.third_finish ||= false
  args.state.block ||= false
end

def render_dragon args
  args.state.final_dragon ||= {
    x: (args.grid.w / 2) - 150,
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
    x: (args.grid.w / 2) - 150,
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
    x: args.state.griffin.x,
    y: args.state.griffin.y + args.state.griffin.h,
    text: args.state.hitpoint.to_s,
    alignment_enum: 1,
    vertical_alignment_enum: 1
  }

  args.outputs.labels << {
    x: args.state.final_dragon.x,
    y: args.state.final_dragon.y + args.state.final_dragon.h,
    text: args.state.dragon_hitpoint.to_s,
    alignment_enum: 1,
    vertical_alignment_enum: 1
  }

  if args.state.center_label_text
    args.outputs.labels << {
      x: args.grid.w - 150,
      y: 100,
      text: args.state.center_label_text,
      alignment_enum: 1,
      vertical_alignmet_enum: 1
    }
  end

  args.outputs.sprites << [args.state.griffin, args.state.final_dragon, args.state.fireballs_atk, args.state.enemy_atk]
end

def inputs args
  if args.inputs.mouse.click
    button = args.state.buttons.find do |b|
      args.inputs.mouse.intersect_rect? b
    end

    fireball = {
      x: args.state.final_dragon.x + 100,
      y: args.state.final_dragon.y + 100,
      w: 40,
      h: 50,
      path: 'sprites/wy/fireball.png'
    }

    if args.state.turn_index % 2 == 0
      case button.id
      when :button_1
        args.state.fireballs_atk << fireball
        args.state.center_label_text = 'used fireball attack'
        args.state.turn_index += 1
      when :button_2
        args.state.block = true
        args.state.center_label_text = 'block next enemy attack'
        args.state.turn_index += 1
      when :skip
        args.state.turn_index += 1
      end
    end
  end
end

def calc args
  args.state.fireballs_atk.each do |fireball|
    fireball.y += args.state.final_dragon.speed + 2
    fireball.dead = true if fireball.x > args.grid.h
    if fireball.intersect_rect? args.state.griffin
      args.state.hitpoint -= args.state.fireball_dmg
      fireball.dead = true
    end
  end

  args.state.fireballs_atk.reject!(&:dead)

  if args.state.turn_index % 2 != 0
    args.state.third_timer -= 1
  end

  if args.state.third_timer.negative?
    args.state.center_label_text = 'enemy used fireball'
    args.state.enemy_atk << {
      x: args.state.griffin.x + 100,
      y: args.state.griffin.y + 100,
      w: 40,
      h: 50,
      path: 'sprites/wy/fireball.png'
    }
    args.state.turn_index += 1
    args.state.third_timer = 3 * 60
  end

  args.state.enemy_atk.each do |fireball|
    fireball.y -= args.state.final_dragon.speed + 2
    fireball.dead = true if fireball.y < 0
    if fireball.intersect_rect? args.state.final_dragon
      if !args.state.block
        args.state.dragon_hitpoint -= 20
      else
        args.state.center_label_text = 'blocked enemy attack'
        args.state.block = false
      end
      fireball.dead = true
    end
  end

  args.state.enemy_atk.reject!(&:dead)

  check_gameover args
end

def check_gameover args
  if args.state.dragon_hitpoint <= 0
    args.state.scene = 'third_gameover'
  elsif args.state.hitpoint <= 0
    args.state.third_finish = true
    args.state.scene = 'third_gameover'
  end
end

def third_gameover_scene args
  labels = []
  if !args.state.third_finish
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
  inputs args
  calc args
  render args
end
