function save_screen(screen)
    local ox,oy = 0,0 -- cell offsets
    local address=0x2000
    foralltiles_s(screen,function(tile,x,y,l_name)
        for i,ln in ipairs(_layer_names) do
            local oy=(i-1)*16
            mset(ox+x,oy+y,tile.ss[ln])
        end

        -- set memory 
        -- poke(address,@address)
        -- log('final '..@address)
    end)
    cstore(0x2000,0x2000,8192)
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
        tile.ss={}
        for i,ln in ipairs(_layer_names) do
            local oy=(i-1)*16
            tile.ss[ln]=mget(ox+x,oy+y)
        end
    end)
    return screen
end