function _init()
    _cursor={cx=8,cy=8}
    _tools={'hoe','seeds','water'}
    _tool_i=1
    _tiles={}
    for i=0,15 do
        local row = {}
        for j=0,15 do
            row[j] = new_tile('grass',j,i,36)
        end
        _tiles[i]=row
    end
end

function _update()
    if btnp(5) then
        local cx,cy=_cursor.cx,_cursor.cy
        local cur_tile=_tiles[cy][cx]
        if _tool_i==1 and cur_tile.kind=='grass' then
            
            local tt=_tiles[cy-1][cx]
            local rt=_tiles[cy][cx+1]
            local bt=_tiles[cy+1][cx]
            local lt=_tiles[cy][cx-1]
            -- update top
            if cy>0 and fget(tt.s,0) then
                local new_f=fget(tt.s) | 0b01000001
                local new_s = findspr(new_f)
                -- log(dtb(new_f)..'->'..dtb(new_f)..' '..tostr(new_s))
                tt.s=new_s
                _tiles[cy-1][cx]=tt
            end
            -- update right
            if cx>0 and fget(rt.s,0) then
                local new_f=fget(rt.s) | 0b10000001
                local new_s = findspr(new_f)
                rt.s=new_s
                _tiles[cy][cx+1]=rt
            end
            -- update bottom
            if cy<16 and fget(bt.s,0) then
                local new_f=fget(bt.s) | 0b00010001
                local new_s = findspr(new_f)
                bt.s=new_s
                _tiles[cy+1][cx]=bt
            end
            -- update left
            if cx<16 and fget(lt.s,0) then
                local new_f=fget(lt.s) | 0b00100001
                local new_s = findspr(new_f)
                lt.s=new_s
                _tiles[cy][cx-1]=lt
            end
            
            -- update current
            local cur_f=0b00000001
            if tt and fget(tt.s,0) then cur_f = cur_f | 0b00010001 end
            if rt and fget(rt.s,0) then cur_f = cur_f | 0b00100001 end
            if bt and fget(bt.s,0) then cur_f = cur_f | 0b01000001 end
            if lt and fget(lt.s,0) then cur_f = cur_f | 0b10000001 end
            local s = findspr(cur_f)
            _tiles[cy][cx]=new_tile('dirt',cx,cy,s)
        end
    end
    if btn(4) then
        if(btnp(⬆️))_tool_i+=1
        if(btnp(⬇️))_tool_i-=1
        if(_tool_i<1)_tool_i=#_tools
        if(_tool_i>#_tools)_tool_i=1
    else 
        if(btnp(➡️))_cursor.cx+=1
        if(btnp(⬅️))_cursor.cx-=1
        if(btnp(⬆️))_cursor.cy-=1
        if(btnp(⬇️))_cursor.cy+=1
    end
end

function _draw()
    cls()
    -- tiles
    for i=0,15 do
        for j=0,15 do
            local tile=_tiles[i][j]
            tile:draw()
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
    for i=0,63 do
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