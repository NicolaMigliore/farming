function log(_text, override)
    printh(_text, "log", override or false)
end

function circle_rect_collision(cx,cy,radius,rx,ry,rw,rh)
    local test_x,text_y=cx,cy
    if cx < rx then
        testX = rx
    elseif cx > rx+rw then
        testX = rx+rw
    end

    if cy < ry then
        testY = ry
    elseif cy > ry+rh then
        testY = ry+rh
    end

    local dist_x = cx-testX;
    local dist_y = cy-testY;
    local distance = sqrt( (dist_x*dist_x) + (dist_y*dist_y) );

    return distance <= radius
end

-- sprite centered
function sprc(n,x,y,w,h,oc)
    w = w or 8
    h = h or w
    x = x - w/2
    y = y - h/2

    -- outline
    if oc then
        for i=1,15 do pal(i,oc) end
        spr(n,x-1,y)
        spr(n,x+1,y)
        spr(n,x,y-1)
        spr(n,x,y+1)
        pal()
    end

    spr(n,x,y)
end
function ssprc(sx,sy,sw,sh,dx,dy,dw,dh,fx,oc)
    dw = dw or sw
    dh = dh or sh
    dx = dx - dw/2
    dy = dy - dh/2
    fx = fx or false

    -- outline
    if oc then
        for i=1,15 do pal(i,oc) end
        sspr(sx,sy,sw,sh,dx-1,dy,dw,dh,fx)
        sspr(sx,sy,sw,sh,dx+1,dy,dw,dh,fx)
        sspr(sx,sy,sw,sh,dx,dy-1,dw,dh,fx)
        sspr(sx,sy,sw,sh,dx,dy+1,dw,dh,fx)
        pal()
    end

    sspr(sx,sy,sw,sh,dx,dy,dw,dh,fx)
end
function rectc(x,y,w,h,c)
    local x1,y1,x2,y2=x-w/2,y-h/2,x+w/2,y+h/2
    rect(x1,y1,x2,y2,c)
end

-- pal multiple
function palm(from,to)
    pal()
    for i,f in ipairs(from) do
        pal(f,to[i])
    end
end

-- point distance
function point_dist(x1,y1,x2,y2)
    return sqrt((x2-x1)^2+(y2-y1)^2)
end

-- print label
function pl(text,x,y,align,c,oc)
    ext = tostr(text)
    local lines = split(text,'\n')
    local h=7*#lines
    y=y-flr(h/2)
    for i,l in ipairs(lines) do
        cx=x
        cy = y + (i-1)*8 --- 3
        c = c or 7
        w = print(l,128,-10) - 128
        if align=='right' then
            cx = x - w
        elseif align=='center' then
            cx = x - w/2
        end
        if oc then
            print(l,cx,cy-1,oc)
            print(l,cx,cy+1,oc)
            print(l,cx-1,cy,oc)
            print(l,cx+1,cy,oc)
        end
        print(l,cx,cy,c)
    end
end

function btn_list(btns,ai)
    for i,b in ipairs(btns) do
        local bg,o= 6,5
        if(i==ai)bg,o=10,1
        local x,y = b.pos.x,b.pos.y
        local w,h=52,16
        local rx,ry=x-w/2,y-1-h/2

        rectfill(rx,ry+1,rx+w,ry+h-1,o)
        rectfill(rx+1,ry,rx+w-1,ry+h,o)
        rectfill(rx+2,ry+2,rx+w-2,ry+h-2,bg)

        pl(b.label,x,y,'center',5)
    end
end

function new_btn(l,a,p,anim)
    return { label=l,
            active=false,
            action=a,
            pos=p,
            anim=anim,
            active_t=0,
            update=function(b)
                if b.anim then
                    local delta = b.anim.to.y - b.anim.from.y
                    b.pos.y = b.anim.from.y + delta*ease_in_out_back(_btn_anim)
                end
                if(b.active_t>0)b.active_t-=1
            end,
            draw=function(b)
                local bg,o= 6,5
                if(b.active)bg,o=10,1
                local x,y = b.pos.x,b.pos.y
                local w,h=52+b.active_t,16-b.active_t/2.5
                local rx,ry=x-w/2,y-1-h/2

                rectfill(rx,ry+1,rx+w,ry+h-1,o)
                rectfill(rx+1,ry,rx+w-1,ry+h,o)
                rectfill(rx+2,ry+2,rx+w-2,ry+h-2,bg)

                pl(b.label,x,y,'center',5)
            end
        }
end

function window(x,y,w,h)
    rectfill(x,y+1,x+w,y+h-1,1)
    rectfill(x+1,y,x+w-1,y+h,1)
    rectfill(x+2,y+2,x+w-2,y+h-2,7)
end

function ease_in_cubic(x)
    return x * x * x
end

function ease_in_out_back(x)
    local c1 = 1.70158
    local c2 = c1 * 1.525
    
    return x < 0.5
      and ((2 * x)^2 * ((c2 + 1) * 2 * x - c2)) / 2
      or ((2 * x - 2)^2 * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
    
end

function rect_rect(r1x,r1y,r1w,r1h,r2x,r2y,r2w,r2h)
    -- are the sides of one rectangle touching the other?
    if (r1x + r1w >= r2x and    -- r1 right edge past r2 left
        r1x <= r2x + r2w and    -- r1 left edge past r2 right
        r1y + r1h >= r2y and    -- r1 top edge past r2 bottom
        r1y <= r2y + r2h) then  -- r1 bottom edge past r2 top
        return true
    end
    return false
end

-- print out a table - for debug
function tableout(t,deep)
 deep=deep or 0
 local str=sub("    ",1,deep)
 log(str.."table size: "..#t) 
 for k,v in pairs(t) do
   if type(v)=="table" then
     log(str..tostr(k).."[]")
     tableout(v,deep+1)
   else
     log(str..tostr(k).." = "..tostr(v))
   end
 end
end