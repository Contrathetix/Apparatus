GroupMenu.ConfigData = {}

GroupMenu.ConfigData.Saved = {}

-- reset saved data and get default saved data

function GroupMenu.ConfigData.ResetSavedData()
    GroupMenu.ConfigData.Saved = GroupMenu.ConfigData.GetDefaultSavedData()
end

function GroupMenu.ConfigData.GetDefaultSavedData()
    local savedDataDefault = {
        NameDisplayMode = GroupMenu.ConfigData.GetNameDisplayModeDefault(),
        ChampionPointsOverCap = GroupMenu.ConfigData.GetDisplayChampionPointsOverCapDefault(),
        Columns = GroupMenu.ConfigData.GetColumnEnabledDefault(),
        ColumnWidth = GroupMenu.ConfigData.GetColumnWidthDefault()
    }
    return savedDataDefault
end

-- name display mode

function GroupMenu.ConfigData.GetNameDisplayMode()
    return GroupMenu.ConfigData.Saved.NameDisplayMode
end

function GroupMenu.ConfigData.GetNameDisplayModeDefault()
    return GroupMenu.Constants.DEFAULT_MENU_NAME_DISPLAY_OPTION
end

function GroupMenu.ConfigData.SetNameDisplayMode(mode)
    GroupMenu.ConfigData.Saved.NameDisplayMode = mode
end

-- champion points over cap

function GroupMenu.ConfigData.GetDisplayChampionPointsOverCap()
    return GroupMenu.ConfigData.Saved.ChampionPointsOverCap
end

function GroupMenu.ConfigData.GetDisplayChampionPointsOverCapDefault()
    return GroupMenu.Constants.DEFAULT_DISPLAY_CHAMPIONPOINTS_OVER_CAP
end

function GroupMenu.ConfigData.SetDisplayChampionPointsOverCap(value)
    GroupMenu.ConfigData.Saved.ChampionPointsOverCap = value
end

-- column width

function GroupMenu.ConfigData.GetColumnWidthTable(default)
    local table = nil
    if default then
        table = {
            [GroupMenu.Constants.KEY_CROWN] = GroupMenu.Constants.DEFAULT_COLUMN_WIDTH_CROWN,
            [GroupMenu.Constants.KEY_NAME_ORIGINAL] = GroupMenu.Constants.DEFAULT_COLUMN_WIDTH_NAME_ORIGINAL,
            [GroupMenu.Constants.KEY_INDEX] = GroupMenu.Constants.DEFAULT_COLUMN_WIDTH_INDEX,
            [GroupMenu.Constants.KEY_NAME] = GroupMenu.Constants.DEFAULT_COLUMN_WIDTH_NAME,
            [GroupMenu.Constants.KEY_ZONE] = GroupMenu.Constants.DEFAULT_COLUMN_WIDTH_ZONE,
            [GroupMenu.Constants.KEY_CLASS] = GroupMenu.Constants.DEFAULT_COLUMN_WIDTH_CLASS,
            [GroupMenu.Constants.KEY_LEVEL] = GroupMenu.Constants.DEFAULT_COLUMN_WIDTH_LEVEL,
            [GroupMenu.Constants.KEY_CHAMPIONICON] = GroupMenu.Constants.DEFAULT_COLUMN_WIDTH_CHAMPIONICON,
            [GroupMenu.Constants.KEY_ROLE] = GroupMenu.Constants.DEFAULT_COLUMN_WIDTH_ROLE,
            [GroupMenu.Constants.KEY_CP] = GroupMenu.Constants.DEFAULT_COLUMN_WIDTH_CP,
            [GroupMenu.Constants.KEY_ALLIANCE] = GroupMenu.Constants.DEFAULT_COLUMN_WIDTH_ALLIANCE,
            [GroupMenu.Constants.KEY_ALLIANCERANK] = GroupMenu.Constants.DEFAULT_COLUMN_WIDTH_ALLIANCERANK,
            [GroupMenu.Constants.KEY_RACE] = GroupMenu.Constants.DEFAULT_COLUMN_WIDTH_RACE,
            [GroupMenu.Constants.KEY_GENDER] = GroupMenu.Constants.DEFAULT_COLUMN_WIDTH_GENDER,
            [GroupMenu.Constants.KEY_SOCIAL] = GroupMenu.Constants.DEFAULT_COLUMN_WIDTH_SOCIAL
        }
    else
        table = {
            [GroupMenu.Constants.KEY_CROWN] = GroupMenu.ConfigData.Saved.ColumnWidth[GroupMenu.Constants.KEY_CROWN],
            [GroupMenu.Constants.KEY_NAME_ORIGINAL] = GroupMenu.ConfigData.Saved.ColumnWidth[GroupMenu.Constants.KEY_NAME_ORIGINAL],
            [GroupMenu.Constants.KEY_INDEX] = GroupMenu.ConfigData.Saved.ColumnWidth[GroupMenu.Constants.KEY_INDEX],
            [GroupMenu.Constants.KEY_NAME] = GroupMenu.ConfigData.Saved.ColumnWidth[GroupMenu.Constants.KEY_NAME],
            [GroupMenu.Constants.KEY_ZONE] = GroupMenu.ConfigData.Saved.ColumnWidth[GroupMenu.Constants.KEY_ZONE],
            [GroupMenu.Constants.KEY_CLASS] = GroupMenu.ConfigData.Saved.ColumnWidth[GroupMenu.Constants.KEY_CLASS],
            [GroupMenu.Constants.KEY_LEVEL] = GroupMenu.ConfigData.Saved.ColumnWidth[GroupMenu.Constants.KEY_LEVEL],
            [GroupMenu.Constants.KEY_CHAMPIONICON] = GroupMenu.ConfigData.Saved.ColumnWidth[GroupMenu.Constants.KEY_CHAMPIONICON],
            [GroupMenu.Constants.KEY_ROLE] = GroupMenu.ConfigData.Saved.ColumnWidth[GroupMenu.Constants.KEY_ROLE],
            [GroupMenu.Constants.KEY_CP] = GroupMenu.ConfigData.Saved.ColumnWidth[GroupMenu.Constants.KEY_CP],
            [GroupMenu.Constants.KEY_ALLIANCE] = GroupMenu.ConfigData.Saved.ColumnWidth[GroupMenu.Constants.KEY_ALLIANCE],
            [GroupMenu.Constants.KEY_ALLIANCERANK] = GroupMenu.ConfigData.Saved.ColumnWidth[GroupMenu.Constants.KEY_ALLIANCERANK],
            [GroupMenu.Constants.KEY_RACE] = GroupMenu.ConfigData.Saved.ColumnWidth[GroupMenu.Constants.KEY_RACE],
            [GroupMenu.Constants.KEY_GENDER] = GroupMenu.ConfigData.Saved.ColumnWidth[GroupMenu.Constants.KEY_GENDER],
            [GroupMenu.Constants.KEY_SOCIAL] = GroupMenu.ConfigData.Saved.ColumnWidth[GroupMenu.Constants.KEY_SOCIAL]
        }
    end
    return table
end

function GroupMenu.ConfigData.GetColumnWidth(column)
    local configuredColumnWidthTable = GroupMenu.ConfigData.GetColumnWidthTable(false)
    if not column then
        return configuredColumnWidthTable
    elseif configuredColumnWidthTable[column] then
        return configuredColumnWidthTable[column]
    else
        return nil
    end
end

function GroupMenu.ConfigData.GetColumnWidthDefault(column)
    local defaultWidthTable = GroupMenu.ConfigData.GetColumnWidthTable(true)
    if not column then
        return defaultWidthTable
    elseif defaultWidthTable[column] then
        return defaultWidthTable[column]
    else
        return nil
    end
end

function GroupMenu.ConfigData.GetColumnWidthTotal()
    -- get total column width, including padding between the columns
    local totalWidth = 0
    local widths = GroupMenu.ConfigData.GetColumnWidthTable()
    local enabled = GroupMenu.ConfigData.GetColumnEnabledTable()
    for key, width in pairs(widths) do
        if enabled[key] then
            totalWidth = totalWidth + width + ZO_KEYBOARD_GROUP_LIST_PADDING_X
        end
    end
    return totalWidth
end

function GroupMenu.ConfigData.SetColumnWidth(column, width)
    if width > GroupMenu.Constants.COLUMN_WIDTH_MAX then
        width = GroupMenu.Constants.COLUMN_WIDTH_MAX
    elseif width < GroupMenu.Constants.COLUMN_WIDTH_MIN then
        width = GroupMenu.Constants.COLUMN_WIDTH_MIN
    end
    GroupMenu.ConfigData.Saved.ColumnWidth[column] = width
end

-- column enabled

function GroupMenu.ConfigData.GetColumnEnabledTable(default)
    local table = nil
    if default then
        table = {
            [GroupMenu.Constants.KEY_CROWN] = GroupMenu.Constants.DEFAULT_DISPLAY_COLUMN_CROWN,
            [GroupMenu.Constants.KEY_INDEX] = GroupMenu.Constants.DEFAULT_DISPLAY_COLUMN_INDEX,
            [GroupMenu.Constants.KEY_NAME] = GroupMenu.Constants.DEFAULT_DISPLAY_COLUMN_NAME,
            [GroupMenu.Constants.KEY_NAME_ORIGINAL] = GroupMenu.Constants.DEFAULT_DISPLAY_COLUMN_NAME_ORIGINAL,
            [GroupMenu.Constants.KEY_ZONE] = GroupMenu.Constants.DEFAULT_DISPLAY_COLUMN_ZONE,
            [GroupMenu.Constants.KEY_CLASS] = GroupMenu.Constants.DEFAULT_DISPLAY_COLUMN_CLASS,
            [GroupMenu.Constants.KEY_LEVEL] = GroupMenu.Constants.DEFAULT_DISPLAY_COLUMN_LEVEL,
            [GroupMenu.Constants.KEY_CHAMPIONICON] = GroupMenu.Constants.DEFAULT_DISPLAY_COLUMN_CHAMPIONICON,
            [GroupMenu.Constants.KEY_ROLE] = GroupMenu.Constants.DEFAULT_DISPLAY_COLUMN_ROLE,
            [GroupMenu.Constants.KEY_CP] = GroupMenu.Constants.DEFAULT_DISPLAY_COLUMN_CP,
            [GroupMenu.Constants.KEY_ALLIANCE] = GroupMenu.Constants.DEFAULT_DISPLAY_COLUMN_ALLIANCE,
            [GroupMenu.Constants.KEY_ALLIANCERANK] = GroupMenu.Constants.DEFAULT_DISPLAY_COLUMN_ALLIANCERANK,
            [GroupMenu.Constants.KEY_RACE] = GroupMenu.Constants.DEFAULT_DISPLAY_COLUMN_RACE,
            [GroupMenu.Constants.KEY_GENDER] = GroupMenu.Constants.DEFAULT_DISPLAY_COLUMN_GENDER,
            [GroupMenu.Constants.KEY_SOCIAL] = GroupMenu.Constants.DEFAULT_DISPLAY_COLUMN_SOCIAL
        }
    else
        table = {
            [GroupMenu.Constants.KEY_CROWN] = GroupMenu.ConfigData.Saved.Columns[GroupMenu.Constants.KEY_CROWN],
            [GroupMenu.Constants.KEY_INDEX] = GroupMenu.ConfigData.Saved.Columns[GroupMenu.Constants.KEY_INDEX],
            [GroupMenu.Constants.KEY_NAME] = GroupMenu.ConfigData.Saved.Columns[GroupMenu.Constants.KEY_NAME],
            [GroupMenu.Constants.KEY_NAME_ORIGINAL] = GroupMenu.ConfigData.Saved.Columns[GroupMenu.Constants.KEY_NAME_ORIGINAL],
            [GroupMenu.Constants.KEY_ZONE] = GroupMenu.ConfigData.Saved.Columns[GroupMenu.Constants.KEY_ZONE],
            [GroupMenu.Constants.KEY_CLASS] = GroupMenu.ConfigData.Saved.Columns[GroupMenu.Constants.KEY_CLASS],
            [GroupMenu.Constants.KEY_LEVEL] = GroupMenu.ConfigData.Saved.Columns[GroupMenu.Constants.KEY_LEVEL],
            [GroupMenu.Constants.KEY_CHAMPIONICON] = GroupMenu.ConfigData.Saved.Columns[GroupMenu.Constants.KEY_CHAMPIONICON],
            [GroupMenu.Constants.KEY_ROLE] = GroupMenu.ConfigData.Saved.Columns[GroupMenu.Constants.KEY_ROLE],
            [GroupMenu.Constants.KEY_CP] = GroupMenu.ConfigData.Saved.Columns[GroupMenu.Constants.KEY_CP],
            [GroupMenu.Constants.KEY_ALLIANCE] = GroupMenu.ConfigData.Saved.Columns[GroupMenu.Constants.KEY_ALLIANCE],
            [GroupMenu.Constants.KEY_ALLIANCERANK] = GroupMenu.ConfigData.Saved.Columns[GroupMenu.Constants.KEY_ALLIANCERANK],
            [GroupMenu.Constants.KEY_RACE] = GroupMenu.ConfigData.Saved.Columns[GroupMenu.Constants.KEY_RACE],
            [GroupMenu.Constants.KEY_GENDER] = GroupMenu.ConfigData.Saved.Columns[GroupMenu.Constants.KEY_GENDER],
            [GroupMenu.Constants.KEY_SOCIAL] = GroupMenu.ConfigData.Saved.Columns[GroupMenu.Constants.KEY_SOCIAL]
        }
    end
    return table
end

function GroupMenu.ConfigData.GetColumnEnabled(column)
    local columnEnabledTable = GroupMenu.ConfigData.GetColumnEnabledTable(false)
    if not column then
        return columnEnabledTable
    elseif columnEnabledTable[column] then
        return columnEnabledTable[column]
    else
        return nil
    end
end

function GroupMenu.ConfigData.GetColumnEnabledDefault(column)
    local columnEnabledDefaultTable = GroupMenu.ConfigData.GetColumnEnabledTable(true)
    if not column then
        return columnEnabledDefaultTable
    elseif columnEnabledDefaultTable[column] then
        return columnEnabledDefaultTable[column]
    else
        return nil
    end
end

function GroupMenu.ConfigData.SetColumnEnabled(column, value)
    GroupMenu.ConfigData.Saved.Columns[column] = value
end
