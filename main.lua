function _init()
    cartdata('elfamir_farming_0')
    _deb=nil
    _mode = ''
    _show_grow=true
    _show_water=true
    _show_empty=false
    _debug_layer=nil --'harvest'

    _d_frame_amount = 3600 -- 2min --108000
    _g_frame_amount = 900--5400 -- 3min --108000

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
    _screen={}
    -- clear_data()

    menuitem(1, "save", function()save_screen(_screen)end)
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
    if(time()%30==0)save_state()add_fx(64,5,60,0,0,false,false,false,nil,{7,1},'autosave...')
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