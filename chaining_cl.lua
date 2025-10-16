hydra = hydra or {}

function hydra.chain(panelName, callback, parent)
    parent = parent or nil
    callback = callback or function() end

    local v = vgui.Create(panelName, parent)

    local proxy = {}
    setmetatable(proxy, {
        __index = function(t, key)
            local orig = v[key]
            if isfunction(orig) then
                return function(_, ...)
                    local result = orig(v, ...)
                    if result == nil or result == v then
                        return t
                    else
                        return result
                    end
                end
            else
                return orig
            end
        end
    })

    callback(proxy)

    return proxy
end