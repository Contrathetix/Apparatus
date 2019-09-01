GroupMenu.Utilities = {}

function GroupMenu.Utilities.CopyTable(source)
    if source == nil then return nil end
    local target = {}
    for key, value in pairs(source) do
        if type(value) == 'table' then
            target[key] = GroupMenu.Utilities.CopyTable(value)
        else
            target[key] = value
        end
    end
    setmetatable(target, GroupMenu.Utilities.CopyTable(getmetatable(source)))
    return target
end

function GroupMenu.Utilities.DoesTableContainValue(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function GroupMenu.Utilities.DoesTableContainKey(table, key)
    for k, _ in pairs(table) do
        if k == key then
            return true
        end
    end
    return false
end
