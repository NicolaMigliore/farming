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
        poke(data_address+2,flr(tile.dry_timer*100))
    end)
    cstore(0x2000,0x2000,8192)
    cstore(0x4300,0x4300,4864)
end

function load_screen()
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
        tile.dry_timer = @(data_address+2)/100
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
end