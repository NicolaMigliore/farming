function _init()
    -- cartdata('elfamir_farming_0')
    _deb=nil
    _mode = ''

    _scenes = {
        land = {
            ent=_land_e,
            upd=_land_u,
            drw=_land_d
        }
    }

    _layer_names={'ground','harvest'}
    -- _screen={
    --     ground={},
    --     water={},
    --     harvest={},
    --     structs={}
    -- }
    -- for k,l in pairs(_screen) do
    --     local layer = {}
    --     for i=0,15 do
    --         layer[i] = {}
    --         for j=0,15 do
    --             local s = -1
    --             if(k=='ground')s=1
    --             local tile = new_tile(k,j,i,s)
    --             layer[i][j] = tile
    --         end
    --     end
    --     _screen[k] = layer
    -- end
    _screen={}


    set_scene('land')
    menuitem(1, "save", function()save_screen(_screen)end)
end

function _update()
    _scenes[_mode].upd()
end

function _draw()
    cls()
    _scenes[_mode].drw()

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