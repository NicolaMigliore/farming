function _land_e()
    _cursor={cx=8,cy=8}
    _tools={
        {l='hoe',s=64},
        {l='seeds',s=65},
        {l='water',s=66},
        {l='sickle',s=67}
    }
    _tool_i=1

    _screen=load_screen()

    menu_open=false
end

function _land_u()
-- input

    if (btnp(4)) menu_open=not menu_open add_timer('menu_toggle',.5)
    if menu_open then
        if(btnp(5))menu_open=false add_timer('menu_toggle',.5)
        if(btnp(⬆️))_tool_i-=1
        if(btnp(⬇️))_tool_i+=1
        if(_tool_i<1)_tool_i=#_tools
        if(_tool_i>#_tools)_tool_i=1
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

        if(btnp(➡️))_cursor.cx=min(_cursor.cx+1,15)
        if(btnp(⬅️))_cursor.cx=max(_cursor.cx-1,0)
        if(btnp(⬆️))_cursor.cy=max(_cursor.cy-1,0)
        if(btnp(⬇️))_cursor.cy=min(_cursor.cy+1,15)
    end

    -- grow
    foralltiles_s(_screen,function(tile,x,y)
        local is_harvestable=fget(tile.ss.harvest,2)
        if is_harvestable then
            -- dry
            local d_chance=.3
            if(rnd()<d_chance and tile.dry_timer>0)tile.dry_timer-=1/120
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
            local g_chance=.4
            if(rnd()<g_chance and tile.grow_timer>0 and tile.dry_timer>.2)tile.grow_timer-=1/240
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
end

function _land_d()
    -- tiles
    foralltiles_s(_screen,function(tile)tile:draw()end)

    -- cursor
    local shr=flr(sin(t()))*2
    rectc(_cursor.cx*8+4,_cursor.cy*8+4,6+shr,6+shr)

    
    if not menu_open then
        window(2,10,13,13)
        rectfill(4,12,13,21,13)
        sprc(_tools[_tool_i].s,9,17)
    end
    local menu_timer = get_timer('menu_toggle')
    if menu_timer then
        local w = 50
        local perc = ease_in_out_back(menu_timer.perc)
        local x,y=-w+(menu_open and w*perc or w*(1-perc)),10
        window(x,y,w,y+50)
        -- tools
        for i,t in pairs(_tools) do
            local ty=y+i*10
            if i==_tool_i then
                rectfill(x+3,ty-5,x+w-3,ty+4,13)
                pl(t.l,x+5,ty,'left',7,1)
            else
                pl(t.l,x+5,ty,'left',1)
            end
            sprc(t.s,x+w-7,ty)
        end

    end
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