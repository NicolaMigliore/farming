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
            local amount=1+flr(rnd()*self.dry_timer*3)
            _inventory.carrots+=amount
            add_fx(self.cx*8+4,self.cy*8+4,10,0,rnd()-1.5,false,false,false,nil,{7,1},'+'..amount)
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
        harvest=layer_h,
        structs=layer_s
    }
end

function update_crops(screen)
    local elapsed_mins = dget(5)
    log('updating crops for '..elapsed_mins..' minutes')
    foralltiles_s(screen, function(ct,x,y)
        local is_harvestable=fget(ct.ss.harvest,2)
        if is_harvestable then
            -- dry
            local d_rate = 1/(_d_frame_amount/30/60)
            ct.dry_timer-=d_rate * elapsed_mins

            -- grow
            local g_rate = 1/(_g_frame_amount/30/60)
            ct.grow_timer-=g_rate * elapsed_mins
        end
    end)
end