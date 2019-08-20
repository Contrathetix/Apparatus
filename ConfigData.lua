GroupMenu.ConfigData = {}

GroupMenu.ConfigData.Saved = {}

GroupMenu.ConfigData.MinColumnWidth = 1
GroupMenu.ConfigData.MaxColumnWidth = 600

GroupMenu.ConfigData.DefaultColumnWidth = {
    [GroupMenu.Constants.INDEX_CROWN] = 40,
    [GroupMenu.Constants.INDEX_NAME_ORIGINAL] = 180,
    [GroupMenu.Constants.INDEX_INDEX] = 25,
    [GroupMenu.Constants.INDEX_NAME] = 180,
    [GroupMenu.Constants.INDEX_ZONE] = 200,
    [GroupMenu.Constants.INDEX_CLASS] = 60,
    [GroupMenu.Constants.INDEX_LEVEL] = 80,
    [GroupMenu.Constants.INDEX_CHAMPIONICON] = 22,
    [GroupMenu.Constants.INDEX_ROLE] = 100,
    [GroupMenu.Constants.INDEX_CP] = 80,
    [GroupMenu.Constants.INDEX_ALLIANCE] = 50,
    [GroupMenu.Constants.INDEX_ALLIANCERANK] = 50,
    [GroupMenu.Constants.INDEX_RACE] = 80,
    [GroupMenu.Constants.INDEX_GENDER] = 70,
    [GroupMenu.Constants.INDEX_SOCIAL] = 80
}

GroupMenu.ConfigData.SavedTemplate = {
    NameDisplayMode = GroupMenu.Constants.MENU_NAME_DISPLAY_OPTION_CHARACTER,
    ChampionPointsOverCap = true,
    Columns = {
        [GroupMenu.Constants.INDEX_CROWN] = true,
        [GroupMenu.Constants.INDEX_NAME_ORIGINAL] = false,
        [GroupMenu.Constants.INDEX_INDEX] = true,
        [GroupMenu.Constants.INDEX_NAME] = true,
        [GroupMenu.Constants.INDEX_ZONE] = true,
        [GroupMenu.Constants.INDEX_CLASS] = true,
        [GroupMenu.Constants.INDEX_LEVEL] = true,
        [GroupMenu.Constants.INDEX_CHAMPIONICON] = true,
        [GroupMenu.Constants.INDEX_ROLE] = true,
        [GroupMenu.Constants.INDEX_CP] = false,
        [GroupMenu.Constants.INDEX_ALLIANCE] = true,
        [GroupMenu.Constants.INDEX_ALLIANCERANK] = true,
        [GroupMenu.Constants.INDEX_RACE] = true,
        [GroupMenu.Constants.INDEX_GENDER] = true,
        [GroupMenu.Constants.INDEX_SOCIAL] = true
    },
    ColumnWidth = {
        [GroupMenu.Constants.INDEX_CROWN] = GroupMenu.ConfigData.DefaultColumnWidth[GroupMenu.Constants.INDEX_CROWN],
        [GroupMenu.Constants.INDEX_NAME_ORIGINAL] = GroupMenu.ConfigData.DefaultColumnWidth[GroupMenu.Constants.INDEX_NAME_ORIGINAL],
        [GroupMenu.Constants.INDEX_INDEX] = GroupMenu.ConfigData.DefaultColumnWidth[GroupMenu.Constants.INDEX_INDEX],
        [GroupMenu.Constants.INDEX_NAME] = GroupMenu.ConfigData.DefaultColumnWidth[GroupMenu.Constants.INDEX_NAME],
        [GroupMenu.Constants.INDEX_ZONE] = GroupMenu.ConfigData.DefaultColumnWidth[GroupMenu.Constants.INDEX_ZONE],
        [GroupMenu.Constants.INDEX_CLASS] = GroupMenu.ConfigData.DefaultColumnWidth[GroupMenu.Constants.INDEX_CLASS],
        [GroupMenu.Constants.INDEX_LEVEL] = GroupMenu.ConfigData.DefaultColumnWidth[GroupMenu.Constants.INDEX_LEVEL],
        [GroupMenu.Constants.INDEX_CHAMPIONICON] = GroupMenu.ConfigData.DefaultColumnWidth[GroupMenu.Constants.INDEX_CHAMPIONICON],
        [GroupMenu.Constants.INDEX_ROLE] = GroupMenu.ConfigData.DefaultColumnWidth[GroupMenu.Constants.INDEX_ROLE],
        [GroupMenu.Constants.INDEX_CP] = GroupMenu.ConfigData.DefaultColumnWidth[GroupMenu.Constants.INDEX_CP],
        [GroupMenu.Constants.INDEX_ALLIANCE] = GroupMenu.ConfigData.DefaultColumnWidth[GroupMenu.Constants.INDEX_ALLIANCE],
        [GroupMenu.Constants.INDEX_ALLIANCERANK] = GroupMenu.ConfigData.DefaultColumnWidth[GroupMenu.Constants.INDEX_ALLIANCERANK],
        [GroupMenu.Constants.INDEX_RACE] = GroupMenu.ConfigData.DefaultColumnWidth[GroupMenu.Constants.INDEX_RACE],
        [GroupMenu.Constants.INDEX_GENDER] = GroupMenu.ConfigData.DefaultColumnWidth[GroupMenu.Constants.INDEX_GENDER],
        [GroupMenu.Constants.INDEX_SOCIAL] = GroupMenu.ConfigData.DefaultColumnWidth[GroupMenu.Constants.INDEX_SOCIAL]
    }
}

function GroupMenu.ConfigData.GetNameDisplayMode()
    return GroupMenu.ConfigData.Saved.NameDisplayMode
end

function GroupMenu.ConfigData.SetNameDisplayMode(mode)
    GroupMenu.ConfigData.Saved.NameDisplayMode = mode
end

function GroupMenu.ConfigData.GetDisplayChampionPointsOverCap()
    return GroupMenu.ConfigData.Saved.ChampionPointsOverCap
end

function GroupMenu.ConfigData.SetDisplayChampionPointsOverCap(value)
    GroupMenu.ConfigData.Saved.ChampionPointsOverCap = value
end

function GroupMenu.ConfigData.GetColumnEnabled(column)
    return GroupMenu.ConfigData.Saved.Columns[column]
end

function GroupMenu.ConfigData.SetColumnEnabled(column, value)
    GroupMenu.ConfigData.Saved.Columns[column] = value
end

function GroupMenu.ConfigData.GetColumnWidth(column)
    local columnWidth = GroupMenu.ConfigData.Saved.ColumnWidth[column]
    if GroupMenu.ConfigData.GetColumnEnabled(column) == false or columnWidth < GroupMenu.ConfigData.MinColumnWidth then
        columnWidth = GroupMenu.ConfigData.MinColumnWidth
    elseif columnWidth > GroupMenu.ConfigData.MaxColumnWidth then
        columnWidth = GroupMenu.ConfigData.MaxColumnWidth
    end
    return columnWidth
end

function GroupMenu.ConfigData.GetConfiguredColumnWidth(column)
    return GroupMenu.ConfigData.Saved.ColumnWidth[column]
end

function GroupMenu.ConfigData.SetConfiguredColumnWidth(column, width)
    GroupMenu.ConfigData.Saved.ColumnWidth[column] = width
end

function GroupMenu.ConfigData.GetDefaultColumnWidth(column)
    return GroupMenu.ConfigData.DefaultColumnWidth[column]
end

function GroupMenu.ConfigData.ResetSavedData()
    GroupMenu.ConfigData.Saved = GroupMenu.ConfigData.RecursiveTableCopy(GroupMenu.ConfigData.SavedTemplate)
end

function GroupMenu.ConfigData.RecursiveTableCopy(source)
    if source == nil then return nil end
    local target = {}
    for key, value in pairs(source) do
        if type(value) == 'table' then
            target[key] = GroupMenu.ConfigData.RecursiveTableCopy(value)
        else
            target[key] = value
        end
    end
    setmetatable(target, GroupMenu.ConfigData.RecursiveTableCopy(getmetatable(source)))
    return target
end

function GroupMenu.ConfigData.GetTotalColumnWidth()

    local totalWidth = 0

    local columnWidths = {
        GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.INDEX_CROWN),
        GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.INDEX_NAME_ORIGINAL),
        GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.INDEX_INDEX),
        GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.INDEX_NAME),
        GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.INDEX_ZONE),
        GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.INDEX_CLASS),
        GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.INDEX_LEVEL),
        GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.INDEX_CHAMPIONICON),
        GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.INDEX_ROLE),
        GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.INDEX_CP),
        GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.INDEX_ALLIANCE),
        GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.INDEX_ALLIANCERANK),
        GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.INDEX_RACE),
        GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.INDEX_GENDER),
        GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.INDEX_SOCIAL)
    }

    for i=1, #columnWidths do
        totalWidth = totalWidth + columnWidths[i] + ZO_KEYBOARD_GROUP_LIST_PADDING_X
    end

    return totalWidth

end
