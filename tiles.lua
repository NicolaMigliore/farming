function new_tile(cx,cy,sprites,grow_sequence)
    return {
        cx=cx,
        cy=cy,
        ss=sprites or {},
        grow_sequence=grow_sequence or {6,8,10,12}, -- {},
        grow_stage=1,
        grow_timer=1,
        dry_sequence={7,9,11,13},
        dry_timer=1,
        draw=function(self)
            for ln in all(_layer_names) do
                local s=self.ss[ln]
                if s and (s~=16 or _show_empty) then
                    local sx,sy=self.cx*8,self.cy*8
                    spr(s,sx,sy)
                    if fget(s,2) and _show_grow then
                        line(sx+1,sy-1,sx+7,sy-1,2)
                        line(sx+1,sy-1,sx+1+7*self.grow_timer,sy-1,8)
                    end
                    if fget(s,2) and _show_water then
                        line(sx+1,sy,sx+7,sy,1)
                        line(sx+1,sy,sx+1+7*max(0,self.dry_timer),sy,12)
                    end
                end
            end
        end,
        harvest=function(self)
            local amount=1+min(1,flr(rnd()*max(0,self.dry_timer)*3))
            _inventory.carrots+=amount
            add_fx(self.cx*8+4,self.cy*8+4,10,0,rnd()-1.5,false,false,false,nil,{7,1},'+'..amount)
            sfx(1,-1,0,8)
            self.ss.harvest=16
            self.grow_timer=1
            self.grow_stage=1
            self.dry_timer=1
        end
    }
end
function get_tile(screen,cx,cy)
    if screen[cy] then
        return screen[cy][cx]
    end
    return nil
end

function get_screen(screen_x,screen_y)
    if screen_x<0 or screen_x>=_screen_w or screen_y<0 or screen_y>=_screen_h then
        return nil
    end
    return _screens[get_screen_i(screen_x,screen_y)+1]
end

function is_blocked_tile(screen,cx,cy)
    local tile=get_tile(screen,cx,cy)
    return tile and tile.ss.harvest and fget(tile.ss.harvest,3)
end

function can_move_to(screen_x,screen_y,cx,cy)
    local target_screen_x,target_screen_y=screen_x,screen_y
    local target_cx,target_cy=cx,cy

    if target_cx<0 then
        target_screen_x-=1
        target_cx=15
    elseif target_cx>15 then
        target_screen_x+=1
        target_cx=0
    end

    if target_cy<0 then
        target_screen_y-=1
        target_cy=15
    elseif target_cy>15 then
        target_screen_y+=1
        target_cy=0
    end

    local target_screen=get_screen(target_screen_x,target_screen_y)
    if not target_screen then
        return false
    end

    return not is_blocked_tile(target_screen,target_cx,target_cy)
end

-- set the harvest layer of a tile
function set_harvest(screen,cx,cy,s)
    local ct = screen[cy][cx]
    ct.ss.harvest=s
    ct.grow_timer=1
    ct.grow_stage=1
    ct.dry_timer=1
end

-- execute function on all tiles in the given screen
-- @param f Function in the form function(tile,x,y,layer_name)
function foralltiles_s(screen, f)
    for i=0,15 do
        local row=screen[i]
        for j=0,15 do
            local tile=screen[i][j]
            f(tile,j,i)
        end
    end
end

function new_screen(layer_g,layer_w,layer_h,layer_s)
    return {
        ground=layer_g,
        water=layer_w,
        harvest=layer_h
    }
end

function update_crops(screen)
    local elapsed_mins = dget(5)
    log('updating crops for '..elapsed_mins..' minutes')
    foralltiles_s(screen, function(ct,x,y)
        local is_harvestable=fget(ct.ss.harvest,2)
        if is_harvestable then
            -- dry
            local d_rate = 1/(get_dry_frame_amount()/30/60)
            ct.dry_timer-=d_rate * elapsed_mins

            -- grow
            local g_rate = 1/(get_grow_frame_amount()/30/60)
            ct.grow_timer-=g_rate * elapsed_mins
        end
    end)
end

function update_crop_tile(tile,x,y,do_fx)
    local is_harvestable=fget(tile.ss.harvest,2)
    if is_harvestable then
        local d_rate=1/get_dry_frame_amount()
        tile.dry_timer-=d_rate
        if tile.dry_timer<=.2 then
            tile.ss.harvest=tile.dry_sequence[tile.grow_stage]
            if rnd()<.002 then
                tile.ss.harvest=16
                tile.grow_stage=1
                tile.grow_timer=1
                tile.dry_timer=1
                if do_fx then
                    for i=0,5+rnd()*5 do
                        add_fx(x*8+4,y*8+4,10,rnd()-.5,rnd()-1.5,true,rnd({true,false}),rnd({true,false}),1,{13,5,1})
                    end
                end
            end
        end

        local g_rate = 1/get_grow_frame_amount()
        tile.grow_timer-=g_rate
        if tile.grow_timer<0 and tile.grow_stage<#tile.grow_sequence then
            tile.grow_stage+=1
            tile.grow_timer=1
            tile.ss.harvest=tile.grow_sequence[tile.grow_stage]

            if do_fx then
                local c_table={7,9,10}
                if(tile.grow_stage==#tile.grow_sequence)c_table={13,5,1}
                for i=0,5+rnd()*5 do
                    add_fx(x*8+4,y*8+4,10,rnd()-.5,rnd()-1.5,true,rnd({true,false}),rnd({true,false}),1,c_table)
                end
            end
        end
    end
end

function update_all_crops()
    for i,screen in ipairs(_screens) do
        local is_active=i==get_screen_i(_screen_x,_screen_y)+1
        foralltiles_s(screen,function(tile,x,y)
            update_crop_tile(tile,x,y,is_active)
        end)
    end
end
