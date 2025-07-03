function save_screen(screen)
    local ox,oy = 0,0 -- cell offsets
    local address=0x2000
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
        local data_address = 0x4300+(x+y*16)*3
        poke(data_address,tile.grow_stage)
        poke(data_address+1,flr(tile.grow_timer * 100))
        local tmp_dry = tile.dry_timer*100
        if(tmp_dry ~= 0)log('dry-timer save: '..tmp_dry)
        poke(data_address+2,flr(tmp_dry))
    end)
    cstore(0x2000,0x2000,8192)
    cstore(0x4300,0x4300,4864)

    save_state()
end

function load_screen()
    log('loading screen')
    local screen = {}
    -- create empty tiles
    for i=0,15 do
        screen[i]={}
        for j=0,15 do
            screen[i][j]=new_tile(j,i)
        end
    end

    local ox,oy = 0,0 -- cell offsets
    foralltiles_s(screen,function(tile,x,y)
        -- load tile sprites
        tile.ss={}
        for i,ln in ipairs(_layer_names) do
            local oy=(i-1)*16
            tile.ss[ln]=mget(ox+x,oy+y)
        end
        -- load tile state
        local data_address = 0x4300+(x+y*16)*3
        tile.grow_stage = @data_address
        tile.grow_timer = @(data_address+1)/100
        local tmp_dry = @(data_address+2)/100
        if(tmp_dry ~= 0)log('dry-timer load: '..tmp_dry)
        tile.dry_timer = tmp_dry
    end)
    return screen
end

function clear_data()
    local ox,oy = 0,0 -- cell offsets
    local address=0x2000

    for y=0,15 do
        for x=0,15 do
        -- store tiles
        for i,ln in ipairs(_layer_names) do
            local oy=(i-1)*16
            if ln=='ground' then
                mset(ox+x,oy+y,1)
            else
                mset(ox+x,oy+y,16)
            end
        end

        -- store tile state
        local data_address = 0x4300+(x+y*16)*3
        poke(data_address,0)
        poke(data_address+1,0)
        poke(data_address+2,0)
        end
    end

    cstore(0x2000,0x2000,8192)
    cstore(0x4300,0x4300,4864)

    -- clear state
    for i=0,4 do
        dset(i,0)
    end
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
    log('------')
    log('loaded '..dget(3)..':'..dget(4))
    tableout(dt)
    dset(5,elapsed_time)

    -- last time 17:19

    _tool_i = dget(6)
    _inventory.carrots = dget(9)
end