function _init()
    _deb=nil
    _cursor={cx=8,cy=8}
    _tools={'hoe','seeds','water'}
    _tool_i=1
    _tiles={
        ground={},
        water={},
        harvest={},
        structs={}
    }
    for k,l in pairs(_tiles) do
        local layer = {}
        for i=0,15 do
            layer[i] = {}
            for j=0,15 do
                local s = -1
                if(k=='ground')s=1
                local tile = new_tile(k,j,i,s)
                layer[i][j] = tile
            end
        end
        _tiles[k] = layer
    end

end

function _update()
    -- input
    if btnp(5) then
        local cx,cy=_cursor.cx,_cursor.cy        
        
        -- hoe
        if _tool_i==1 then
            local layer = _tiles.ground
            local tt=cy-1>-1 and get_tile(layer,cx,cy-1) or nil
            local rt=cx+1<16 and get_tile(layer,cx+1,cy) or nil
            local bt=cy+1<16 and get_tile(layer,cx,cy+1) or nil
            local lt=cx-1 and get_tile(layer,cx-1,cy) or nil
            -- update top
            if tt and fget(tt.s,0) then
                local new_f=fget(tt.s) ^^ 0b01000000
                local new_s = findspr(new_f)
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
            local ct = get_tile(layer,cx,cy)
            local cur_f=ct and fget(ct.s) ^^ 0b00000001 or 0b00000001
            if tt and fget(tt.s,0) then cur_f = cur_f ^^ 0b00010000 end
            if rt and fget(rt.s,0) then cur_f = cur_f ^^ 0b00100000 end
            if bt and fget(bt.s,0) then cur_f = cur_f ^^ 0b01000000 end
            if lt and fget(lt.s,0) then cur_f = cur_f ^^ 0b10000000 end
            local s = findspr(cur_f)
            layer[cy][cx]=new_tile('dirt',cx,cy,s)
        end
        
        -- seeds
        if _tool_i==2 then
            -- local layer = _tiles.harvest
            local ct=_tiles.harvest[cy][cx]
            local gt=_tiles.ground[cy][cx] -- ground tile
            local is_dirt = fget(gt.s,0)
            local has_plant = fget(ct.s,4)
            if is_dirt and not has_plant then
                ct=new_tile('harvest',cx,cy,16)
                _tiles.harvest[cy][cx] = ct
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

    -- grow
    local layer=_tiles.harvest
    for i=0,15 do
        for j=0,15 do            
            tile=layer[i][j]
            local is_harvestable=fget(tile.s,2)
        end
    end
end

function _draw()
    cls()
    -- tiles
    for layer in all({_tiles.ground, _tiles.harvest}) do
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

    if(_deb)print(_deb,1,120)
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