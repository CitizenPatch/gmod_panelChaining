--- Hydra — вспомогательная библиотека для упрощённого создания VGUI-панелей
-- с поддержкой цепочного вызова методов.
hydra = hydra or {}

--- Создает VGUI-панель с возможностью цепочного вызова методов.
-- @param panelName string Имя панели, которую нужно создать (например, 'DFrame', 'DButton').
-- @param callback function|nil Функция, которая принимает proxy-панель для настройки её свойств и методов.
-- @param parent Panel|nil Родительский элемент панели, если требуется.
-- @return table Proxy-объект, позволяющий вызывать методы панели цепочкой.
--
-- Пример использования:
-- 
-- local panel = hydra.chain('DFrame', function(p)
--     p:SetSize(300, 200)
--     p:SetTitle('Пример')
--     p:MakePopup()
-- end, parent)
-- 
-- Или:
-- 
-- local pnl = hydra.chain('DFrame', parent)
-- :SetSize(300, 300)
-- :SetTitle('Пример')
-- :MakePopup()

--- Создает панель с возможностью цепочного вызова методов.
-- @param panel string Имя панели
-- @param callback fun(proxy: table)|nil Функция для настройки proxy-панели.
-- @param parent Panel|nil Родительский элемент панели.
-- @return table proxy Proxy-объект панели, поддерживающий цепочные вызовы методов.
function hydra.chain(panelName, callback, parent)
    if callback and not isfunction(callback) then
        parent = callback
        callback = function() end
    end
    
    callback = callback or function() end
    
    local realParent = parent and parent.__vgui or parent
    local v = vgui.Create(panelName, realParent)

    local proxy = {}
    proxy.__vgui = v

    setmetatable(proxy, {
        __index = function(t, key)
            local orig = v[key]
            if not isfunction(orig) then return orig end

            return function(_, ...)
                local result = orig(v, ...)

                if result == nil or result == v then
                    return t
                else
                    return result
                end
            end
        end,

        __newindex = function(t, key, value)
            v[key] = value
        end
    })

    callback(proxy)

    return proxy
end






