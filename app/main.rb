GROUND = 123
JUMP_VELO = 22
GRAVITY = -0.98
FPS = 60

def spawn_background(args, num)
    {
        x: 0,
        y: 66,
        w: 1280,
        h: 720,
        path: "sprites/forest/background/Layer_00#{num}.png",
    }
end

def spawn_character(args)
    args.state.runner ||= {
        x: (args.grid.w * 1)/5,
        y: GROUND,
        w: 110,
        h: 110,
        jump: 0,
        jumping: false,
        source_x: 10,
        source_y: 1,
        source_w: 28 ,
        source_h: 30,
    }

    if args.state.runner.jumping == true
        player_sprite_index = 0.frame_index(count: 4, hold_for: 8, repeat: true)
        args.state.runner.path = "sprites/actions/individual_sprites/adventurer-jump-0#{player_sprite_index}.png"
    else
        player_sprite_index = 0.frame_index(count: 6, hold_for: 8, repeat: true)
        args.state.runner.path = "sprites/run/adventurer-run3-0#{player_sprite_index}.png"
    end
    
end

def spawn_enemy(args)
    {
        x: args.grid.w + 10,
        y: GROUND - 3,
        w: 80,
        h: 80,
        flip_horizontally: true,
        speed: -6,
        path: "sprites/monster/Goblin/idle0.png"
    }
end

def enemy_physics(args)
    args.state.enemies.each do |enemy|
        if enemy.x < -enemy.w 
            enemy.dead = true
            args.state.enemies << spawn_enemy(args)
        end

        if args.geometry.intersect_rect?(enemy, args.state.runner)
            # game_over_tick(args)
            # return
            enemy.dead = true 
            args.state.enemies << spawn_enemy(args)
        end

        enemy.x += enemy.speed
    end

    # removes all dead objects

    args.state.enemies.reject! {|e| e.dead }
end

def jump_physics(args)
    # checks input for jumping
    if args.inputs.keyboard.key_down.space && args.state.runner.y == GROUND 
        args.state.runner.jumping = true
        args.state.runner.jump = JUMP_VELO
    end

    # implement gravity on jump
    args.state.runner.jump += GRAVITY

    # update player's position
    args.state.runner.y += args.state.runner.jump

    # prevent player from falling off the platform
    if args.state.runner.y < GROUND
        args.state.runner.y = GROUND
        args.state.runner.jumping = false
        args.state.runner.jump = 0
    end
end

def game_over_tick args
    timer += 1
    labels = []
    labels << {
        x: args.grid.w/2,
        y: args.grid.h/2,
        text: "Game Over",
        size_enum: 20,
    }

    args.outputs.labels << labels
    
    if timer > 30 && args.inputs.keyboard.key_down.space
        $gtk.reset
    end
end

def calc_time args
    args.state.timer.seconds += 1

    if args.state.timer.seconds > (60 * FPS)
        args.state.timer.minutes += 1 * FPS
        args.state.timer.seconds = 0
    end

end

def calc args 
    enemy_physics(args)
    jump_physics(args)
    calc_time(args)
end

def tick args
    spawn_character(args)
    args.state.score ||= 0

    args.state.background ||= [
        spawn_background(args, '11'),
        spawn_background(args, '10'),
        spawn_background(args, '09'),
        spawn_background(args, '08'),
        spawn_background(args, '07'),
        spawn_background(args, '06'),
        spawn_background(args, '05'),
        spawn_background(args, '04'),
        spawn_background(args, '03'),
        spawn_background(args, '02'),
        spawn_background(args, '01'),
        {
            x: 0,
            y: 0,
            w: 1280,
            h: 1450,
            path: 'sprites/forest/background/Layer_0000.png',
        }
    ]

    args.state.enemies ||= [
        spawn_enemy(args)
    ] 

    args.state.enemies.each do |enemy|
        enemy_sprite_index = 0.frame_index(count: 4, hold_for: 8, repeat: true)
        enemy.path = "sprites/monster/Goblin/idle#{enemy_sprite_index}.png"
    end
    
    
    args.state.timer ||= {
        minutes: 0,
        seconds: 45,
    }

    # implement all physics
    calc(args)

    # #coordinates debugging
    # if args.inputs.mouse.click
    #     puts " coordinates is #{args.inputs.mouse.x} , #{args.inputs.mouse.y}"
    # end

    # render sprites
    args.outputs.sprites << [args.state.background, args.state.runner, args.state.enemies]

    
    labels = []
    labels << {
        x: 30,
        y: args.grid.h - 20,
        text: "Time: #{(args.state.timer.minutes/FPS).round}m #{(args.state.timer.seconds/FPS).round}s",
        size_enum: 8,
    }
   
    args.outputs.labels << labels
end

$gtk.reset