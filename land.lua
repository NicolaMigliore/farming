function _land_e()
    _cursor={cx=flr(_player.x/8),cy=flr(_player.y/8)}

    _screen=load_screen()
    update_crops(_screen)

    menu_open=false
end

function _land_u()
-- input

    if (btnp(4)) menu_open=not menu_open add_timer('menu_toggle',.5) _player.can_input=not menu_open
    if menu_open then
        if(btnp(5))menu_open=false add_timer('menu_toggle',.5)_player.can_input=not menu_open
        if(btnp(⬆️))_tool_i-=1
        if(btnp(⬇️))_tool_i+=1
        if(_tool_i<1)_tool_i=#_tools
        if(_tool_i>#_tools)_tool_i=1
        if _tool_i==2 then
            if(btnp(⬅️))_seed_type_i-=1
            if(btnp(➡️))_seed_type_i+=1
            if(_seed_type_i<1)_seed_type_i=#_seed_types
            if(_seed_type_i>#_seed_types)_seed_type_i=1
        end

    else
        if btnp(5) then
            local cx,cy=_cursor.cx,_cursor.cy
            local ct = get_tile(_screen,cx,cy)
            local is_dirt = fget(ct.ss.ground,0)
            local has_plant = ct.ss.harvest~=16
            local is_harvestable = fget(ct.ss.harvest,6)
            -- hoe
            if _tool_i==1 then
                ct.grow_stage=1
                ct.grow_timer=0
                if has_plant then
                    set_harvest(_screen,cx,cy,16)
                else
                    till_ground(cx,cy,ct)
                end
            end
            -- seeds
            if _tool_i==2 and is_dirt and not has_plant then
                set_harvest(_screen,cx,cy,6)
                local t = _screen[cy][cx]
            end

            -- water
            if _tool_i==3 and has_plant then
                ct.dry_timer=1
                if(ct.dry_timer>.2)ct.ss.harvest=ct.grow_sequence[ct.grow_stage]
            end

            -- sickle
            if _tool_i==4 and is_harvestable then
                ct:harvest()
            end
        end

        -- if(btnp(➡️))_cursor.cx=min(_cursor.cx+1,15)
        -- if(btnp(⬅️))_cursor.cx=max(_cursor.cx-1,0)
        -- if(btnp(⬆️))_cursor.cy=max(_cursor.cy-1,0)
        -- if(btnp(⬇️))_cursor.cy=min(_cursor.cy+1,15)

        _cursor.cx=flr(_player.x/8)
        if(_player.d==1)_cursor.cx+=1
        if(_player.d==2)_cursor.cx-=1
        _cursor.cy=flr(_player.y/8)
        if(_player.d==3)_cursor.cy-=1
        if(_player.d==4)_cursor.cy+=1
    end

    -- grow
    foralltiles_s(_screen,function(tile,x,y)
        local is_harvestable=fget(tile.ss.harvest,2)
        if is_harvestable then
            -- dry
            local d_rate=1/_d_frame_amount
            tile.dry_timer-=d_rate
            if tile.dry_timer<=.2 then
                tile.ss.harvest=tile.dry_sequence[tile.grow_stage]
                if rnd()<.002 then
                    tile.ss.harvest=16
                    tile.grow_stage=1
                    tile.grow_timer=1
                    tile.dry_timer=1
                    for i=0,5+rnd()*5 do
                        add_fx(x*8+4,y*8+4,10,rnd()-.5,rnd()-1.5,true,rnd({true,false}),rnd({true,false}),1,{13,5,1})
                    end
                end
            end

            -- grow
            local g_rate = 1/_g_frame_amount
            tile.grow_timer-=g_rate
            if tile.grow_timer<0 and tile.grow_stage<#tile.grow_sequence then
                tile.grow_stage+=1
                tile.grow_timer=1
                tile.ss.harvest=tile.grow_sequence[tile.grow_stage]

                local c_table={7,9,10}
                if(tile.grow_stage==#tile.grow_sequence)c_table={13,5,1}
                for i=0,5+rnd()*5 do
                    add_fx(x*8+4,y*8+4,10,rnd()-.5,rnd()-1.5,true,rnd({true,false}),rnd({true,false}),1,c_table)
                end
            end
        end
    end)

    _player:update()
end

function _land_d()
    -- tiles
    foralltiles_s(_screen,function(tile)tile:draw()end)

    -- cursor
    local shr=flr(sin(t()))*2
    rectc(_cursor.cx*8+4,_cursor.cy*8+4,6+shr,6+shr)

    
    _player:draw()
    
    if not menu_open then
        window(2,10,13,13)
        rectfill(4,12,13,21,13)
        sprc(_tools[_tool_i].s,9,17)
    end
    local menu_timer = get_timer('menu_toggle')
    if menu_timer then
        local w = 70
        local perc = ease_in_out_back(menu_timer.perc)
        local x,y=-w+(menu_open and w*perc or w*(1-perc)),10
        window(x,y,w,y+50)
        -- tools
        for i,t in pairs(_tools) do
            local ty=y+i*12
            if i==_tool_i then
                rectfill(x+3,ty-5,x+w-3,ty+4,13)
                pl(t.l,x+5,ty,'left',7,1)
            else
                pl(t.l,x+5,ty,'left',1)
            end
            if i==2 and i==_tool_i then
                local cur_seed=_seed_types[_seed_type_i]
                pl('⬅️',x+w-33,ty, 'right',7,1)
                -- sprc(t.s,x+w-26,ty,8,8,1)
                sprc(cur_seed.s,x+w-27,ty,8,8,1)
                local n = '0'.._inventory[cur_seed.id]
                n = sub(n,-2)
                pl(n,x+w-20,ty,'left',7,1)
                pl(' ➡️',x+w-14,ty, 'left',7,1)
            else
                sprc(t.s,x+w-7,ty,8,8,1)
            end
        end
    end
    
    -- inventory
    window(-15,110,40,20)
    sprc(14,7,121,nil,nil,1)
    pl(_inventory.carrots,16,122,'center',7,1)

end

function till_ground(cx,cy,ct)
    local cur_f=ct and fget(ct.ss.ground) ^^ 0b00000001 or 0b00000001

    local tt=cy-1>-1 and get_tile(_screen,cx,cy-1)
    local rt=cx+1<16 and get_tile(_screen,cx+1,cy)
    local bt=cy+1<16 and get_tile(_screen,cx,cy+1)
    local lt=cx-1 and get_tile(_screen,cx-1,cy)
    -- update top
    if tt and fget(tt.ss.ground,0) then
        local new_f=fget(tt.ss.ground) ^^ 0b01000000
        local new_s = findspr(new_f)
        tt.ss.ground=new_s
        _screen[cy-1][cx]=tt
        cur_f = cur_f ^^ 0b00010000
    end
    -- update right
    if rt and fget(rt.ss.ground,0) then
        local new_f=fget(rt.ss.ground) ^^ 0b10000000
        local new_s = findspr(new_f)
        rt.ss.ground=new_s
        _screen[cy][cx+1]=rt
        cur_f = cur_f ^^ 0b00100000
    end
    -- update bottom
    if bt and fget(bt.ss.ground,0) then
        local new_f=fget(bt.ss.ground) ^^ 0b00010000
        local new_s = findspr(new_f)
        bt.ss.ground=new_s
        _screen[cy+1][cx]=bt
        cur_f = cur_f ^^ 0b01000000
    end
    -- update left
    if lt and fget(lt.ss.ground,0) then
        local new_f=fget(lt.ss.ground) ^^ 0b00100000
        local new_s = findspr(new_f)
        lt.ss.ground=new_s
        _screen[cy][cx-1]=lt
        cur_f = cur_f ^^ 0b10000000
    end

    -- update current
    local s = findspr(cur_f)
    _screen[cy][cx].ss.ground=s
end