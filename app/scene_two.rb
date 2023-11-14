def second_scene args
  args.outputs.sprites << {
    x: (args.grid.w / 2) - 50,
    y: (args.grid.h / 2) - 50,
    w: 60,
    h: 60,
    path: 'sprites/misc/black.png'
  }
end
