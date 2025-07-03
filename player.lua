_directions = { 'r', 'l', 'u', 'd' }

function new_p()
    local x = dget(7)>0 and dget(7) or 64
    local y = dget(8)>0 and dget(8) or 64
    return {
        x = x,
        y = y,
        dx = 0,
        dy = 0,
        spd = 1,
        d = 4,
        can_input=true,
        sm = {
            idle = function(s)
                local input = btnp()
                log('got input:' .. tostr(input))
                if (input ~= 0) return 'walk'
                return 'idle'
            end,
            walk = function(s)
                if (s.movement > 1) s.movement = 0 return 'idle'
                s.movement += 1 / 30
                return 'walk'
            end
        },
        cs = 'idle',
        anim = {
            idle_r = { s = .2, f = { 103, 103, 104, 105 } },
            idle_l = { s = .2, f = { 119, 119, 120, 121 } },
            idle_u = { s = .2, f = { 87, 87, 88, 89 } },
            idle_d = { s = .2, f = { 71, 71, 72, 73 } },
            walk_r = { s = 1/3, f = { 106, 107, 108, 109, 110, 111 } },
            walk_l = { s = 1/3, f = { 122, 123, 124, 125, 126, 127 } },
            walk_u = { s = 1/3, f = { 90, 91, 92, 93, 94, 95 } },
            walk_d = { s = 1/3, f = { 74, 75, 76, 77, 78, 79 } }
        },
        anim_i = 1,
        update = function(p)
            if p.can_input then
                if p.cs == 'walk' then
                    -- continue moving
                    p.x += p.dx
                    p.y += p.dy

                    -- check if we reached the next tile
                    if p.x % 8 == 0 and p.y % 8 == 0 then
                        p.dx = 0
                        p.dy = 0

                        -- check for continued input
                        if (btn(➡️)) then p.d=1 p.dx=p.spd
                        elseif (btn(⬅️)) then p.d=2 p.dx=-p.spd
                        elseif (btn(⬆️)) then p.d=3 p.dy=-p.spd
                        elseif (btn(⬇️)) then p.d=4 p.dy=p.spd
                        else
                            p.cs = 'idle'
                        end
                    end
                else
                    -- check for new input
                    if btnp(➡️) then
                        if p.d == 1 then
                            p.dx = p.spd p.cs = 'walk'
                        else
                            p.d = 1
                        end
                    elseif btnp(⬅️) then
                        if p.d == 2 then
                            p.dx = -p.spd p.cs = 'walk'
                        else
                            p.d = 2
                        end
                    elseif btnp(⬆️) then
                        if p.d == 3 then
                            p.dy = -p.spd p.cs = 'walk'
                        else
                            p.d = 3
                        end
                    elseif btnp(⬇️) then
                        if p.d == 4 then
                            p.dy = p.spd p.cs = 'walk'
                        else
                            p.d = 4
                        end
                    end
                end
            end

            -- advance animation
            local anim_name = p.cs .. '_' .. _directions[p.d]
            local ca = p.anim[anim_name]
            p.anim_i += ca.s
            if (p.anim_i > #ca.f + 1) p.anim_i = 1
        end,
        draw = function(p)
            local anim_name = p.cs .. '_' .. _directions[p.d]
            local ca = p.anim[anim_name]
            local n = ca.f[flr(p.anim_i)]
            local x, y = p.x+4, p.y+4
            local sx,sy=(n%16)*8,flr(n/16)*8
            ssprc(sx,sy,8,8,x,y,16,16,false,1)
        end
    }
end