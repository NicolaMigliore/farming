function get_screen_map_origin(screen_i)
    return screen_i*16,0
end

function get_screen_data_origin(screen_i)
    return 0x4300+screen_i*16*16*3
end

function save_screen(screen,screen_i)
    local ox,oy = get_screen_map_origin(screen_i)
    local data_origin = get_screen_data_origin(screen_i)
    foralltiles_s(screen,function(tile,x,y,l_name)
        -- store tiles
        for i,ln in ipairs(_layer_names) do
            local oy=(i-1)*16
            mset(ox+x,oy+y,tile.ss[ln])
        end

        -- set memory 
        -- poke(address,@address)
        -- log('final '..@address)

        -- store tile state
        local data_address = data_origin+(x+y*16)*3
        poke(data_address,tile.grow_stage)
        poke(data_address+1,flr(tile.grow_timer * 100))
        local tmp_dry = tile.dry_timer*100
        if(tmp_dry ~= 0)log('dry-timer save: '..tmp_dry)
        poke(data_address+2,flr(tmp_dry))
    end)
end

function load_screen(screen_i)
    local screen = {}
    -- create empty tiles
    for i=0,15 do
        screen[i]={}
        for j=0,15 do
            screen[i][j]=new_tile(j,i)
        end
    end

    local ox,oy = get_screen_map_origin(screen_i)
    local data_origin = get_screen_data_origin(screen_i)
    foralltiles_s(screen,function(tile,x,y)
        -- load tile sprites
        tile.ss={}
        for i,ln in ipairs(_layer_names) do
            local oy=(i-1)*16
            tile.ss[ln]=mget(ox+x,oy+y)
        end
        -- load tile state
        local data_address = data_origin+(x+y*16)*3
        tile.grow_stage = @data_address
        tile.grow_timer = @(data_address+1)/100
        local tmp_dry = @(data_address+2)/100
        if(tmp_dry ~= 0)log('dry-timer load: '..tmp_dry)
        tile.dry_timer = tmp_dry
    end)
    return screen
end

function save_screens()
    for screen_i=0,_screen_count-1 do
        save_screen(_screens[screen_i+1],screen_i)
    end
    cstore(0x2000,0x2000,8192)
    cstore(0x4300,0x4300,4864)
    save_state()
end

function load_screens()
    _screens={}
    for screen_i=0,_screen_count-1 do
        local screen=load_screen(screen_i)
        update_crops(screen)
        add(_screens,screen)
    end
end

function clear_data()
    for screen_i=0,_screen_count-1 do
        local ox,oy = get_screen_map_origin(screen_i)
        local data_origin = get_screen_data_origin(screen_i)

        for y=0,15 do
            for x=0,15 do
                local harvest_y = 16+y
                local harvest_s = mget(ox+x,harvest_y)
                local keep_tile = fget(harvest_s,3) and fget(harvest_s,4)

                if not keep_tile then
                    -- store tiles
                    for i,ln in ipairs(_layer_names) do
                        local layer_y = (i-1)*16
                        if ln=='ground' then
                            mset(ox+x,layer_y+y,1)
                        else
                            mset(ox+x,layer_y+y,16)
                        end
                    end

                    -- store tile state
                    local data_address = data_origin+(x+y*16)*3
                    poke(data_address,0)
                    poke(data_address+1,0)
                    poke(data_address+2,0)
                end
            end
        end
    end

    cstore(0x2000,0x2000,8192)
    cstore(0x4300,0x4300,4864)

    -- clear state
    for i=0,12 do
        dset(i,0)
    end
end

function reset_game_data()
    clear_data()

    _tool_i=1
    _time_speed_i=3
    _screen_x=0
    _screen_y=0
    _inventory.gold=10
    _inventory.seed_c=3
    _inventory.seed_t=0
    _inventory.carrots=10

    load_screens()
    _screen=_screens[get_screen_i(_screen_x,_screen_y)+1]

    if _player then
        _player.x=64
        _player.y=64
        _player.dx=0
        _player.dy=0
        _player.d=4
        _player.cs='idle'
        _player.anim_i=1
        _player.can_input=true
    end

    if _cursor then
        _cursor.cx=flr(_player.x/8)
        _cursor.cy=flr(_player.y/8)
    end

    menuitem(2, "game speed: "..current_time_speed().label, cycle_time_speed)
    save_state()
end

function save_state()
    -- save time @TODO: write in for loop
    dset(0,stat(80)) -- y
    dset(1,stat(81)) -- m
    dset(2,stat(82)) -- d
    dset(3,stat(83)) -- h
    dset(4,stat(84)) -- mi

    dset(6,_tool_i)
    dset(7,_player.x)
    dset(8,_player.y)
    dset(9,_inventory.carrots)
    dset(10,_time_speed_i)
    dset(11,_screen_x)
    dset(12,_screen_y)

    log('save at '..dget(3)..':'..dget(4))
end

function load_state()
    local dt = {}   -- delta time
    _last_time = {}
    for i=0,4 do
        local last,cur= dget(i),stat(80+i)
        add(_last_time,last)
        add(dt,cur-last)
    end

    -- Adjust for negative differences
    local y,m,d,h,mi = dt[1],dt[2],dt[3],dt[4],dt[5]
    if mi < 0 then mi += 60 h -= 1 end
    if h  < 0 then h  += 24 d -= 1 end
    if d < 0 then d += 30 m -= 1 end -- approximate
    if m < 0 then m += 12 y -= 1 end

    -- elapsed time
    local elapsed_time = 0
    if y>0 or m>0 then
        elapsed_time = 10080
    else
        elapsed_time = ((d * 24) + (h * 60) + mi)
    end
    dset(5,elapsed_time)
    _tool_i = dget(6)
    if(_tool_i<1)_tool_i=1
    _inventory.carrots = dget(9)
    _time_speed_i = dget(10)
    if _time_speed_i < 1 or _time_speed_i > #_time_speeds then
        _time_speed_i = 3
    end
    _screen_x = dget(11)
    if _screen_x < 0 or _screen_x >= _screen_w then
        _screen_x = 0
    end
    _screen_y = dget(12)
    if _screen_y < 0 or _screen_y >= _screen_h then
        _screen_y = 0
    end
    menuitem(2, "game speed: "..current_time_speed().label, cycle_time_speed)
end
