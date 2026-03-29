function _init()
    cartdata('elfamir_farming_0')
    _deb=nil
    _mode = ''
    _show_grow=true
    _show_water=true
    _show_empty=false
    _debug_layer=nil --'harvest'

    _base_d_frame_amount = 3600 -- 2min --108000
    _base_g_frame_amount = 900--5400 -- 3min --108000
    _time_speeds = {
        { label='test', mult=0.1 },
        { label='fast', mult=0.5 },
        { label='normal', mult=1 },
        { label='slow', mult=2 }
    }
    _time_speed_i = 3

    _si=0

    _last_time = {}
    _scenes = {
        land = {
            ent=_land_e,
            upd=_land_u,
            drw=_land_d
        }
    }
    _seed_types={
        {id='seed_c',s=65},
        {id='seed_t',s=30}
    }
    _seed_type_i=1
    _inventory={ gold=10,seed_c=3,seed_t=0,carrots=10 }
    _tools={
        {l='hoe',s=64},
        {l='seeds',s=65},
        {l='water',s=66},
        {l='sickle',s=67}
    }
    _tool_i=1
    _layer_names={'ground','harvest'}
    _screen_w=2
    _screen_h=2
    _screen_count=_screen_w*_screen_h
    _screen_x=0
    _screen_y=0
    _screens={}
    _screen={}
    -- clear_data()

    menuitem(1, "save", save_screens)
    menuitem(2, "game speed", cycle_time_speed)
    load_state()
    _player = new_p()
    set_scene('land')

end

function _update()
    if _si>0 then
        do_shake()
    else
        camera()
    end

    _scenes[_mode].upd()
    _effects_u()
    _timers_u()

    -- autosave
    if(time()%30==0)save_screens()add_fx(64,5,60,0,0,false,false,false,nil,{7,1},'autosave...')
end

function _draw()
    cls()
    _scenes[_mode].drw()
    _effects_d()

    if _debug_layer then
        for i=0,15 do
            local row=_screen[i]
            for j=0,15 do
                local tile=_screen[i][j]
                pl(tile.ss[_debug_layer], j*8+4, i*8+4, 'center')
            end
        end
    end
    if(_deb)pl(_deb,64,120,'left',7)
end

function set_scene(s,params)
    _mode = s
    _camera={x=0,y=0}
    -- _title_cards = {}
    local params = params or {}
    _scenes[s].ent(unpack(params))
end

function do_shake()
    local shake_x,shake_y=rnd(_si)-(_si /2),rnd(_si)-(_si /2)
    camera( shake_x, shake_y )
    _si *= .5
    if _si < .3 then _si = 0 end
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

function current_time_speed()
    return _time_speeds[_time_speed_i] or _time_speeds[1]
end

function get_dry_frame_amount()
    return _base_d_frame_amount * current_time_speed().mult
end

function get_grow_frame_amount()
    return _base_g_frame_amount * current_time_speed().mult
end

function cycle_time_speed()
    _time_speed_i += 1
    if _time_speed_i > #_time_speeds then
        _time_speed_i = 1
    end
    menuitem(2, "game speed: "..current_time_speed().label, cycle_time_speed)
    save_state()
end

function get_screen_i(screen_x,screen_y)
    return screen_x + screen_y*_screen_w
end

function transition_to_screen(screen_x,screen_y,spawn_x,spawn_y)
    _screen_x=screen_x
    _screen_y=screen_y
    _screen=_screens[get_screen_i(_screen_x,_screen_y)+1]
    _player.x=spawn_x or 0
    _player.y=spawn_y or _player.y
    _player.dx=0
    _player.dy=0
    _player.cs='idle'
    _player.anim_i=1
    _cursor.cx=flr(_player.x/8)
    _cursor.cy=flr(_player.y/8)
    save_state()
end
