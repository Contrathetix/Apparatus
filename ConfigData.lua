GroupMenu.ConfigData = {}

GroupMenu.ConfigData.Saved = {}

GroupMenu.ConfigData.Default = {
    NameDisplayMode = GroupMenu.Constants.MENU_NAME_DISPLAY_OPTION_CHARACTER,
    Columns = {
        [GroupMenu.Constants.COLUMN_INDEX_CP] = true,
        [GroupMenu.Constants.COLUMN_INDEX_ALLIANCE] = true,
        [GroupMenu.Constants.COLUMN_INDEX_ALLIANCE_RANK] = true,
        [GroupMenu.Constants.COLUMN_INDEX_RACE] = true,
        [GroupMenu.Constants.COLUMN_INDEX_GENDER] = true,
        [GroupMenu.Constants.COLUMN_INDEX_SOCIAL] = true
    }
}

GroupMenu.ConfigData.ColumnWidth = {
    [GroupMenu.Constants.COLUMN_INDEX_CP] = 50,
    [GroupMenu.Constants.COLUMN_INDEX_ALLIANCE] = 50,
    [GroupMenu.Constants.COLUMN_INDEX_ALLIANCE_RANK] = 50,
    [GroupMenu.Constants.COLUMN_INDEX_RACE] = 70,
    [GroupMenu.Constants.COLUMN_INDEX_GENDER] = 70,
    [GroupMenu.Constants.COLUMN_INDEX_SOCIAL] = 70
}

function GroupMenu.ConfigData.GetNameDisplayMode()
    return GroupMenu.ConfigData.Saved.NameDisplayMode
end

function GroupMenu.ConfigData.SetNameDisplayMode(mode)
    GroupMenu.ConfigData.Saved.NameDisplayMode = mode
end

function GroupMenu.ConfigData.GetColumnEnabled(column)
    local value = GroupMenu.ConfigData.Saved.Columns[column]
    return value
end

function GroupMenu.ConfigData.SetColumnEnabled(column, value)
    GroupMenu.ConfigData.Saved.Columns[column] = value
end

function GroupMenu.ConfigData.GetColumnWidth(column)
    return GroupMenu.ConfigData.GetColumnEnabled(column) and GroupMenu.ConfigData.ColumnWidth[column] or 1
end

function GroupMenu.ConfigData.GetColumnWidthAll()
    return {
        [GroupMenu.Constants.COLUMN_INDEX_CP] = GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.COLUMN_INDEX_CP),
        [GroupMenu.Constants.COLUMN_INDEX_ALLIANCE] = GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.COLUMN_INDEX_ALLIANCE),
        [GroupMenu.Constants.COLUMN_INDEX_ALLIANCE_RANK] = GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.COLUMN_INDEX_ALLIANCE_RANK),
        [GroupMenu.Constants.COLUMN_INDEX_RACE] = GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.COLUMN_INDEX_RACE),
        [GroupMenu.Constants.COLUMN_INDEX_GENDER] = GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.COLUMN_INDEX_GENDER),
        [GroupMenu.Constants.COLUMN_INDEX_SOCIAL] = GroupMenu.ConfigData.GetColumnWidth(GroupMenu.Constants.COLUMN_INDEX_SOCIAL)
    }
end
