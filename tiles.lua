function new_tile(cx,cy,sprites,grow_sequence)
    return {
        cx=cx,
        cy=cy,
        ss=sprites or {},
        grow_sequence=grow_sequence or {},
        age=0,
        grow_age=60,
        draw=function(self)
            for ln in all(_layer_names) do
                local s=self.ss[ln]
                if(s and s>-1)spr(s,self.cx*8,self.cy*8)
            end
        end
    }
end
function get_tile(screen,cx,cy)
    if screen[cy] then
        return screen[cy][cx]
    end
    return nil
end

-- execute function on all tiles in the given layer
-- @param f Function in the form function(tile,x,y,layer_name)
function foralltiles_l(layer,l_name,f)
    for i=0,#layer do
        local row=layer[i]
        if row then
            for j=0,#layer[i] do
                local tile=layer[i][j]
                f(tile,j,i,l_name)
            end
        end
    end
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