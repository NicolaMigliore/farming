_timers = {}

function _timers_u()
    for k,timer in pairs(_timers) do
        if(timer.t>0)timer.t=timer.t-1/30 timer.perc = (timer.start_time - timer.t) / timer.start_time
        if timer.t<=0 and timer.done == false then 
            timer.done = true
            timer.f()
        end
    end
end

function add_timer(name, time, fn)
    _timers[name] = {
        start_time = time,
        t = time,
        f = fn or function()end,
        perc = 0,
        done = false
    }
    if(name=='transition')_can_input=false
end

function get_timer(name)
    return _timers[name]
end