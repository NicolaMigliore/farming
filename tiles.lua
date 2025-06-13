function new_tile(kind,cx,cy,s,sm,grow_sequence)
    return {
        kind=kind,
        s=s,
        sm=sm or {},
        cx=cx,
        cy=cy,
        age=0,
        grow_age=60,
        grow_sequence=grow_sequence or {},
        draw=function(s)
            if(s.s>-1)spr(s.s,s.cx*8,s.cy*8)
        end
    }
end
function get_tile(l,cx,cy)
    if l[cy] then
        return l[cy][cx]
    end
    return nil
end
