function new_tile(kind,cx,cy,s)
    return {
        kind=kind,
        s=s,
        cx=cx,
        cy=cy,
        borders=0,
        draw=function(s)
            spr(s.s,s.cx*8,s.cy*8)
        end
    }
end
