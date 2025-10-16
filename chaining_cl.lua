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
-- end)
-- 
-- Или:
-- 
-- local pnl = hydra.chain('DFrame')
-- :SetSize(300, 300)
-- :SetTitle('Пример')
-- :MakePopup()

--- Создает панель с возможностью цепочного вызова методов.
-- @param panelName string Имя панели, например 'DFrame' или 'DButton'.
-- @param callback fun(proxy: table)|Panel|nil Функция инициализации proxy или родительский элемент панели.
-- @param parent Panel|nil Родительский элемент панели, если второй аргумент — callback.
-- @return table proxy Proxy-объект, поддерживающий цепочные вызовы методов.
function hydra.chain(panelName, callback, parent)
    local callback = nil

    if isfunction(callback) then
        callback = callback
    else
        parent = callback
        callback = function() end
    end

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


