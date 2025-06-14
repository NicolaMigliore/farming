function _land_e()
    _cursor={cx=8,cy=8}
    _tools={'hoe','seeds','water'}
    _tool_i=1

    _screen=load_screen()
end

function _land_u()
-- input
    if btnp(5) then
        local cx,cy=_cursor.cx,_cursor.cy        
        local ct = get_tile(_screen,cx,cy)
        local is_dirt = fget(ct.ss.ground,0)
        local has_plant = ct.ss.harvest>-1
        -- hoe
        if _tool_i==1 then
            if has_plant then
                _screen[cy][cx].ss.harvest=-1
            else
                till_ground(cx,cy,ct)
            end
        end
        
        -- seeds
        if _tool_i==2 then
            if is_dirt and not has_plant then
                _screen[cy][cx].ss.harvest=16
            end
        end
    end

    if btn(4) then
        if(btnp(⬆️))_tool_i+=1
        if(btnp(⬇️))_tool_i-=1
        if(_tool_i<1)_tool_i=#_tools
        if(_tool_i>#_tools)_tool_i=1
    else 
        if(btnp(➡️))_cursor.cx=min(_cursor.cx+1,15)
        if(btnp(⬅️))_cursor.cx=max(_cursor.cx-1,0)
        if(btnp(⬆️))_cursor.cy=max(_cursor.cy-1,0)
        if(btnp(⬇️))_cursor.cy=min(_cursor.cy+1,15)
    end

    -- -- grow
    -- local layer=_screen.harvest
    -- for i=0,15 do
    --     for j=0,15 do            
    --         tile=layer[i][j]
    --         local is_harvestable=fget(tile.s,2)
    --     end
    -- end
end

function _land_d()
    -- tiles
    foralltiles_s(_screen,function(tile)tile:draw()end)

    -- cursor
    local shr=flr(sin(t()))*2
    rectc(_cursor.cx*8+4,_cursor.cy*8+4,6+shr,6+shr)
    -- tools
    for i,t in pairs(_tools) do
        if i==_tool_i then
            pl(t,2,i*8,'left',7,1)
        else
            pl(t,2,i*8,'left',1)
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