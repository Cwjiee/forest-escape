GROUND = 123
JUMP_VELO = 22
GRAVITY = -0.98
FPS = 60
SPEED = -5

def spawn_background(args, num)
    {
        x: 0,
        y: 66,
        w: 1290,
        h: 720,
        path: "sprites/forest/background/Layer_00#{num}.png",
    }
end

def spawn_background2(args, num)
    {
        x: args.grid.w,
        y: 66,
        w: 1290,
        h: 720,
        path: "sprites/forest/background/Layer_00#{num}.png",
    }
end

def spawn_character(args)
    args.state.runner ||= {
        x: (args.grid.w * 1)/5,
        y: GROUND,
        w: 90,
        h: 90,
        jump: 0,
        running: true,
        jumping: false,
        attacking: false,
        idle: false,
        source_x: 10,
        source_y: 1,
        source_w: 28 ,
        source_h: 30,
    }

    if args.state.runner.jumping
        player_sprite_index = 0.frame_index(count: 4, hold_for: 8, repeat: true)
        args.state.runner.path = "sprites/actions/individual_sprites/adventurer-jump-0#{player_sprite_index}.png"
    elsif args.state.runner.attacking
        player_sprite_index = 0.frame_index(count: 6, hold_for: 8, repeat: true)
        args.state.runner.path = "sprites/actions/individual_sprites/adventurer-attack2-0#{player_sprite_index}.png"
    elsif args.state.runner.running
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

        if !args.state.runner.attacking
            if args.geometry.intersect_rect?(enemy, args.state.runner)
                args.state.game_end = true
            end
        end

        enemy.x += SPEED
    end

    # removes all dead objects
    args.state.enemies.reject! {|e| e.dead }
end

def jump_physics(args)
    # checks input for jumping
    if args.inputs.keyboard.key_down.space && args.state.runner.y == GROUND 
        args.state.runner.running = false
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
        args.state.runner.running = true
        args.state.runner.jump = 0
    end
end

def attack_physics(args)
    if args.inputs.keyboard.key_down.j && args.state.runner.y == GROUND
        args.state.runner.running = false
        args.state.runner.attacking = true 
    end

    if args.state.runner.attacking
        args.state.timer.game_tick += 1
        args.state.enemies.each do |enemy|
            if args.geometry.intersect_rect?(args.state.runner, enemy)
                enemy.dead = true 
                args.state.score += 1
                args.state.enemies << spawn_enemy(args)
            end
        end

        if args.state.timer.game_tick == 48
            args.state.runner.attacking = false
            args.state.runner.running = true
            args.state.timer.game_tick = 0
        end
    end
end


def game_over_tick(args)

    labels = []
    labels << {
        x: args.grid.w/2,
        y: args.grid.h/2,
        z: 20,
        text: "Game Over",
        size_enum: 20,
        r: 233,
        g: 218,
        b: 0,
    }
    labels << {
        x: args.grid.w/2,
        y: args.grid.h/2 - 50,
        z: 20,
        text: "Final score: #{(args.state.timer.seconds/FPS).round + (args.state.score/48).round}",
        size_enum: 15,
        r: 233,
        g: 218,
        b: 0,
    }

    args.outputs.labels << labels
        
    if args.state.timer.game_over > 30 && args.inputs.keyboard.key_down.space
        $gtk.reset
    end
end

def calc_time(args)
    args.state.timer.seconds += 1

    if args.state.timer.seconds > (60 * FPS)
        args.state.timer.minutes += 1 * FPS
        args.state.timer.seconds = 0
    end
end

def background_scroll(args)
    args.state.backgrounds.each do |background|
        background.x += SPEED 
        if background.x < -background.w
            background.x = args.grid.w - 10
        end
    end

    args.state.backgrounds2.each do |background|
        background.x += SPEED
        if background.x < -background.w 
            background.x = args.grid.w - 10
        end
    end
end

def calc args 
    attack_physics(args)
    jump_physics(args)
    enemy_physics(args)
    calc_time(args)
    background_scroll(args)
end

def tick args
    spawn_character(args)
    args.state.score ||= 0
    args.state.game_end ||= false

    if args.state.game_end == true
        args.state.timer.game_over += 1
        game_over_tick(args)
        return
    end

    args.state.backgrounds ||= [
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
            idle: false,
            path: 'sprites/forest/background/Layer_0000.png',
        }
    ]

    args.state.backgrounds2 ||= [
        spawn_background2(args, '11'),
        spawn_background2(args, '10'),
        spawn_background2(args, '09'),
        spawn_background2(args, '08'),
        spawn_background2(args, '07'),
        spawn_background2(args, '06'),
        spawn_background2(args, '05'),
        spawn_background2(args, '04'),
        spawn_background2(args, '03'),
        spawn_background2(args, '02'),
        spawn_background2(args, '01'),
        {
            x: args.grid.w,
            y: 0,
            w: 1280,
            h: 1450,
            idle: false,
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
        seconds: 0,
        game_tick: 0,
        game_over: 0,
    }

    # implement all physics
    calc(args)

    # render sprites
    args.outputs.sprites << [args.state.backgrounds, args.state.backgrounds2, args.state.runner, args.state.enemies]

    args.state.board = []
    args.state.board << {
        x: 30,
        y: args.grid.h - 20,
        text: "Score: #{(args.state.timer.seconds/FPS).round + (args.state.score/48).round}",
        size_enum: 8,
    }
   
    args.outputs.labels << [args.state.board, args.state.hitscore]
end

$gtk.reset