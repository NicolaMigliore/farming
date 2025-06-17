function _init()
    -- cartdata('elfamir_farming_0')
    _deb=nil
    _mode = ''
    _effects={}
    _show_grow=false
    _show_water=true
    _show_empty=false
    _debug_layer=nil --'harvest'

    
    _scenes = {
        land = {
            ent=_land_e,
            upd=_land_u,
            drw=_land_d
        }
    }

    _layer_names={'ground','harvest'}
    _screen={}
    -- clear_data()


    set_scene('land')
    menuitem(1, "save", function()save_screen(_screen)end)
end

function _update()
    _scenes[_mode].upd()
    _effects_u()
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
    if(_deb)print(_deb,1,120)
end

function set_scene(s,params)
    _mode = s
    _camera={x=0,y=0}
    -- _timers = {}
    -- _title_cards = {}
    local params = params or {}
    _scenes[s].ent(unpack(params))
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