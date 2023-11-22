def defaults(args)
  args.state.buttons ||= [
    create_button(args, id: :button_1, row: 10, col: 4, text: 'button 1'),
    create_button(args, id: :button_2, row: 10, col: 8, text: 'button 2'),
    create_button(args, id: :clear, row: 10, col: 12, text: 'clear')
  ]
end

def render args
  args.outputs.primitives << args.state.buttons.map do |b|
    b.primitives
  end

  if args.state.center_label_text
    args.outputs.labels << {
      x: 640,
      y: 360,
      text: args.state.center_label_text,
      alignment_enum: 1,
      vertical_alignment_enum: 1
    }
  end
end

def inputs args
  if args.inputs.mouse.click
    button = args.state.buttons.find do |b|
      args.inputs.mouse.intersect_rect? b
    end

    case button.id
    when :button_1
      args.state.center_label_text = 'button 1 was clicked'
    when :button_2
      args.state.center_label_text = 'button 2 was clicked'
    when :clear
      args.state.center_label_text = nil
    end
  end
end

def calc args; end

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
