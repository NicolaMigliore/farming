function _init()
    _cursor={cx=8,cy=8}
    _tools={'hoe','seeds','water'}
    _tool_i=1
    _tiles={
        ground={},
        water={},
        harvest={},
        structs={}
    }
    for i=0,15 do
        local row = {}
        for j=0,15 do
            row[j] = new_tile('grass',j,i,1)
        end
        _tiles.ground[i]=row
    end
end

function _update()
    if btnp(5) then
        local layer = _tiles.ground
        local cx,cy=_cursor.cx,_cursor.cy
        local cur_tile=layer[cy][cx]

        -- hoe
        if _tool_i==1 then
            local tt=cy-1>-1 and layer[cy-1][cx] or nil
            local rt=cx+1<16 and layer[cy][cx+1] or nil
            local bt=cy+1<16 and layer[cy+1][cx] or nil
            local lt=cx-1 and layer[cy][cx-1] or nil
            -- update top
            if tt and fget(tt.s,0) then
                local new_f=fget(tt.s) ^^ 0b01000000
                local new_s = findspr(new_f)
                -- log(dtb(new_f)..'->'..dtb(new_f)..' '..tostr(new_s))
                tt.s=new_s
                layer[cy-1][cx]=tt
            end
            -- update right
            if rt and fget(rt.s,0) then
                local new_f=fget(rt.s) ^^ 0b10000000
                local new_s = findspr(new_f)
                rt.s=new_s
                layer[cy][cx+1]=rt
            end
            -- update bottom
            if bt and fget(bt.s,0) then
                local new_f=fget(bt.s) ^^ 0b00010000
                local new_s = findspr(new_f)
                bt.s=new_s
                layer[cy+1][cx]=bt
            end
            -- update left
            if lt and fget(lt.s,0) then
                local new_f=fget(lt.s) ^^ 0b00100000
                local new_s = findspr(new_f)
                lt.s=new_s
                layer[cy][cx-1]=lt
            end
            
            -- update current
            local ct = layer[cy][cx]
            local cur_f=ct and fget(ct.s) ^^ 0b00000001 or 0b00000001
            if tt and fget(tt.s,0) then cur_f = cur_f ^^ 0b00010000 end
            if rt and fget(rt.s,0) then cur_f = cur_f ^^ 0b00100000 end
            if bt and fget(bt.s,0) then cur_f = cur_f ^^ 0b01000000 end
            if lt and fget(lt.s,0) then cur_f = cur_f ^^ 0b10000000 end
            local s = findspr(cur_f)
            layer[cy][cx]=new_tile('dirt',cx,cy,s)
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
end

function _draw()
    cls()
    -- tiles
    for layer in all({_tiles.ground,_tiles.harvest}) do
        for i=0,#layer do
            local row=layer[i]
            if row then     
                for j=0,#layer[i] do
                    local tile=layer[i][j]
                    tile:draw()
                end
            end
        end
    end
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

function findspr(b)
    for i=1,63 do
        if fget(i) == b then
            return i
        end
    end
end

function dtb(num)
  local bin=""
  for i=7,0,-1do
    bin..=num\2^i %2
  end
  return bin
end