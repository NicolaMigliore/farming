function _land_e()
    _cursor={cx=flr(_player.x/8),cy=flr(_player.y/8)}

    _screen=load_screen()
    update_crops(_screen)

    mode=1 --1:play 2:tool select 3:sell

    pad_sell={
        x=124,
        y=4,
        draw=function(s)
            local w=(sin(t())+1)/2*7
            local x1=s.x-w/2
            local y1=s.y-w/2
            local x2=s.x+w/2
            local y2=s.y+w/2 
            rectfill(s.x-4,s.y-4,s.x+3,s.y+3,7)
            rect(x1,y1,x2,y2,8)
            rect(x1+.4,y1+.4,x2-.4,y2-.4,8)
        end
    }
    trades={
        { give='carrots', g_icon=14, g_amount=5, take='gold', t_icon=68, t_amount=15 },
        -- { give='carrots', g_icon=14, g_amount=10, take='gold', t_icon=68, t_amount=20 },
        { give='gold', g_icon=68, g_amount=10, take='seed_c', t_icon=65, t_amount=5 },
        -- { give='gold', g_icon=68, g_amount=15, take='seed_c', t_icon=65, t_amount=10 },
    }
    sell_i=1
end

function _land_u()    
    if mode==1 then
        if btnp(4) then
            toggle_menu()
        end
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
            if _tool_i==2 and _inventory.seed_c>0 and is_dirt and not has_plant then
                _inventory.seed_c-=1
                set_harvest(_screen,cx,cy,6)
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
        _cursor.cx=flr(_player.x/8)
        if(_player.d==1)_cursor.cx+=1
        if(_player.d==2)_cursor.cx-=1
        _cursor.cy=flr(_player.y/8)
        if(_player.d==3)_cursor.cy-=1
        if(_player.d==4)_cursor.cy+=1
    elseif mode==2 then
        if btnp(4) then
            toggle_menu()
        end
        if(btnp(5))mode=1 add_timer('menu_toggle',.5)_player.can_input= mode==1
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

    elseif mode==3 then
        if(btnp(4))toggle_sell()
        if btnp(5) then
            local trade = trades[sell_i]
            if _inventory[trade.give]>=trade.g_amount then
                _inventory[trade.give]-=trade.g_amount
                _inventory[trade.take]+=trade.t_amount
                sfx(0,-1,0,4)
            else
                sfx(0,-1,8,4)
                _si+=2
            end

        end

        if(btnp(⬆️))sell_i-=1
        if(btnp(⬇️))sell_i+=1
        if(sell_i<1)sell_i=#trades
        if(sell_i>#trades)sell_i=1
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

    -- toggle sell
    if  mode!=3 and _player.x==120 and _player.y==0 then
        mode=3
        _player.can_input=false
        add_timer('sell_toggle',.8)
    end
end

function _land_d()
    -- tiles
    foralltiles_s(_screen,function(tile)tile:draw()end)

    -- pad_sell
    pad_sell:draw()

    -- cursor
    local shr=flr(sin(t()))*2
    rectc(_cursor.cx*8+4,_cursor.cy*8+4,6+shr,6+shr)

    
    _player:draw()
    
    -- menu
    if mode==1 or mode==3 then
        window(2,10,13,13)
        rectfill(4,12,13,21,13)
        sprc(_tools[_tool_i].s,9,17)
    end

    local menu_timer = get_timer('menu_toggle')
    if menu_timer then
        local w,perc =70,ease_in_out_back(menu_timer.perc)
        perc= mode==2 and perc or 1-perc
        local x,y=-w+w*perc,10
        window(x,y,w,y+51)

        pl('tools',x+w/2,y+7,'center',10,1)
        y+=5
        for i,t in pairs(_tools) do
            local ty=y+i*12
            local c,co=1,nil
            if(i==_tool_i) c,co=7,1 rectfill(x+3,ty-6,x+w-3,ty+5,13)
            pl(t.l,x+5,ty,'left',c,co)
            
            if i==2 and i==_tool_i then
                local cur_seed=_seed_types[_seed_type_i]
                pl('⬅️',x+w-33,ty, 'right',7,1)
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

    -- sell
    local st = get_timer('sell_toggle')
    if st then
        local w,h,perc = 54,32+#trades*12,ease_in_out_back(st.perc)
        perc= mode==3 and perc or 1-perc
        local x,y=64-w/2,-h+(h+10)*perc
        window(x,y,w,h)
 
        pl('sell/buy',x+w/2,y+7,'center',10,1)
        y+=5
        for i,v in ipairs(trades) do
            local c,oc=1,nil
            local vx,vy=x+8,y+i*12
            if(i==sell_i)c,oc=7,1 rectfill(x+3,vy-6,x+w-3,vy+5,13)

            sprc(v.g_icon,vx,vy,nil,nil,1)
            pl(v.g_amount,vx+8,vy,'left',c,oc)
            sprc(v.t_icon,vx+28,vy,nil,nil,1)
            pl(v.t_amount,vx+36,vy,'left',c,oc)
        end
        y+=12*#trades+7
        line(x+w/2,y-12*#trades,x+w/2,y-3,1)
        line(x+6,y,x+w-6,y,1)
        pl('❎ trade\n🅾️ close',x+w/2,y+11,'center',7,1)
    end
    
    -- inventory
    window(-15,110,68,20)
    sprc(68,6,121,nil,nil,1)
    pl(_inventory.gold,16,122,'center',7,1)
    sprc(14,32,121,nil,nil,1)
    pl(_inventory.carrots,45,122,'center',7,1)

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

function toggle_menu()
    mode=(mode==1) and 2 or 1
    add_timer('menu_toggle',.5)
    _player.can_input= mode==1
end
function toggle_sell()
    mode=(mode==1) and 3 or 1
    add_timer('sell_toggle',.8)
    _player.can_input=mode==1
    if(mode==1)_player.y+=8
end