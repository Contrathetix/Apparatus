GroupMenu.Interface = {}

GroupMenu.Interface.Elements = {}

function GroupMenu.Interface.Init()

    GroupMenu.Interface.Elements.GroupListHeaderRow = ZO_GroupListHeaders
    GroupMenu.Interface.Elements.CharacterNameHeaderLabel = ZO_GroupListHeadersCharacterName
    GroupMenu.Interface.Elements.ExtraRowElements = {}

    local prefix = 'ZO_GroupListHeaders'

    GroupMenu.Interface.Elements.ExtraHeaderLabels = {
        [GroupMenu.Constants.COLUMN_INDEX_CP] = CreateControlFromVirtual(prefix..'ChampionPointsHeader', GroupMenu.Interface.Elements.GroupListHeaderRow, 'GroupMenu_Interface_Header_ChampionPoints'),
        [GroupMenu.Constants.COLUMN_INDEX_ALLIANCE] = CreateControlFromVirtual(prefix..'Alliance', GroupMenu.Interface.Elements.GroupListHeaderRow, 'GroupMenu_Interface_Header_Alliance'),
        [GroupMenu.Constants.COLUMN_INDEX_ALLIANCE_RANK] = CreateControlFromVirtual(prefix..'AllianceRank', GroupMenu.Interface.Elements.GroupListHeaderRow, 'GroupMenu_Interface_Header_AllianceRank'),
        [GroupMenu.Constants.COLUMN_INDEX_RACE] = CreateControlFromVirtual(prefix..'Race', GroupMenu.Interface.Elements.GroupListHeaderRow, 'GroupMenu_Interface_Header_Race'),
        [GroupMenu.Constants.COLUMN_INDEX_GENDER] = CreateControlFromVirtual(prefix..'Gender', GroupMenu.Interface.Elements.GroupListHeaderRow, 'GroupMenu_Interface_Header_Gender'),
        [GroupMenu.Constants.COLUMN_INDEX_SOCIAL] = CreateControlFromVirtual(prefix..'Social', GroupMenu.Interface.Elements.GroupListHeaderRow, 'GroupMenu_Interface_Header_Social')
    }

end

function GroupMenu.Interface.UpdateMenu()

    GroupMenu.Interface.UpdateHeaderLabels()

    GROUP_LIST:UpdateHeaders(GROUP_LIST.groupSize > 0)

    for i=1, #GROUP_LIST_MANAGER.masterList do
        GroupMenu.Interface.UpdateRow(i)
    end

end

function GroupMenu.Interface.UpdateGroupMenuSize(isMenuShown)

    local baseMenuWidth = 930
    local baseMenuBackgroundWidth = 1024
    local extraMenuWidth = 0

    local menuWidthBase = 930
    local menuWidthExtra = 0

    local backgroundWidthBase = 1024
    local backgroundWidthExtra = 0

    if isMenuShown then
        local configuredColumnWidths = GroupMenu.ConfigData.GetColumnWidthAll()
        for i=1, #configuredColumnWidths do
            menuWidthExtra = menuWidthExtra + configuredColumnWidths[i]
        end
        menuWidthExtra = menuWidthExtra + 40
        backgroundWidthExtra = menuWidthExtra * 1.6
    end

    local backgroundWidth = backgroundWidthBase + backgroundWidthExtra

    local backgroundAnchorOffsetX = -35 - menuWidthExtra
    local backgroundAnchorOffsetY = -75

    local titleAnchorOffsetX = 30 - menuWidthExtra
    local titleAnchorOffsetY = -335

    local displayNameAnchorOffsetX = 0 - menuWidthExtra
    local displayNameAnchorOffsetY = 0

    local difficultySettingAnchorOffsetX = 0 - menuWidthExtra * 0.6
    local difficultySettingAnchorOffsetY = -10

    ZO_SharedRightBackgroundLeft:SetAnchor(TOPLEFT, ZO_SharedRightBackground, TOPLEFT, backgroundAnchorOffsetX, backgroundAnchorOffsetY)
    ZO_SharedRightBackgroundLeft:SetWidth(backgroundWidth)

    ZO_GroupListVeteranDifficultySettings:SetAnchor(4, ZO_GroupList, 1, difficultySettingAnchorOffsetX, difficultySettingAnchorOffsetY)

    ZO_SharedTitle:SetAnchor(8, GuiRoot, 8, titleAnchorOffsetX, titleAnchorOffsetY)
    ZO_DisplayName:SetAnchor(3, ZO_KeyboardFriendsList, 3, displayNameAnchorOffsetX, displayNameAnchorOffsetY)

    ZO_GroupMenu_Keyboard:SetWidth(menuWidthBase + menuWidthExtra)

end

function GroupMenu.Interface.UpdateHeaderLabels()

    GroupMenu.Interface.UpdateColumnVisibility(GroupMenu.Interface.Elements.ExtraHeaderLabels, true)

    if GroupMenu.ConfigData.GetNameDisplayMode() == GroupMenu.Constants.MENU_NAME_DISPLAY_OPTION_ACCOUNT then
        GroupMenu.Interface.Elements.CharacterNameHeaderLabel:SetText(GroupMenu.Strings.DisplayName)
    else
        GroupMenu.Interface.Elements.CharacterNameHeaderLabel:SetText(GroupMenu.Strings.CharacterName)
    end

end

function GroupMenu.Interface.UpdateColumnVisibility(rowItemList, isHeaderRow)

    for i=1, #rowItemList do

        local currentItem = rowItemList[i]
        local columnEnabled = GroupMenu.ConfigData.GetColumnEnabled(i)
        local columnWidth = GroupMenu.ConfigData.GetColumnWidth(i)

        if isHeaderRow then
            local isInHeadersTable = GroupMenu.Interface.DoesTableContainElement(GROUP_LIST.headers, currentItem)
            if columnEnabled and isInHeadersTable == false then
                table.insert(GROUP_LIST.headers, currentItem)
            end
        end

        currentItem:SetWidth(columnWidth)
        currentItem:SetHidden(columnEnabled == false)

    end

end

function GroupMenu.Interface.DoesTableContainElement(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function GroupMenu.Interface.UpdateRow(index)

    local row = GroupMenu.Interface.GetGroupListRow(index)

    if row == nil then return end

    local unitData = GROUP_LIST_MANAGER.masterList[index]
    local extraRowElements = GroupMenu.Interface.GetRow(index)

    local displayName = GetUnitDisplayName(unitData.unitTag)
    local characterName = GetUnitName(unitData.unitTag)
    local race = GetUnitRace(unitData.unitTag)
    local socialStatus = 'Neutral'
    local gender = unitData.gender == 1 and GroupMenu.Strings.GenderFemale or GroupMenu.Strings.GenderMale
    local trueChampionPoints = unitData.online and GetUnitChampionPoints(unitData.unitTag) or ''
    local allianceId = GetUnitAlliance(unitData.unitTag)
    local allianceRank = GetUnitAvARank(unitData.unitTag)
    local allianceRankName = GetAvARankName(unitData.gender, allianceRank)

    if unitData.online == false then
        socialStatus = ''
    elseif unitData.isPlayer then
        socialStatus = 'Self'
    elseif IsUnitFriend(unitData.unitTag) then
        socialStatus = 'Friend'
    elseif IsUnitIgnored(unitData.tag) then
        socialStatus = 'Ignored'
    end

    -- update the champion point label text
    extraRowElements[GroupMenu.Constants.COLUMN_INDEX_CP]:SetText(trueChampionPoints)

    -- update the alliance indicator texture path and tooltip
    local allianceIndicatorTexture = extraRowElements[GroupMenu.Constants.COLUMN_INDEX_ALLIANCE]:GetNamedChild('Texture')
    allianceIndicatorTexture:SetTexture(ZO_GuildBrowser_GuildList_Keyboard:GetAllianceIcon(allianceId))
    allianceIndicatorTexture.allianceName = GetAllianceName(allianceId)
    extraRowElements[GroupMenu.Constants.COLUMN_INDEX_ALLIANCE]:SetHidden(unitData.online == false)

    -- update alliance rank indicator texture and tooltip
    local allianceRankIndicatorTexture = extraRowElements[GroupMenu.Constants.COLUMN_INDEX_ALLIANCE_RANK]:GetNamedChild('Texture')
    allianceRankIndicatorTexture:SetTexture(GetAvARankIcon(allianceRank))
    allianceRankIndicatorTexture.rankName = allianceRankName

    -- update race, gender and social status text
    extraRowElements[GroupMenu.Constants.COLUMN_INDEX_RACE]:SetText(race)
    extraRowElements[GroupMenu.Constants.COLUMN_INDEX_GENDER]:SetText(gender)
    extraRowElements[GroupMenu.Constants.COLUMN_INDEX_SOCIAL]:SetText(socialStatus)

    if GroupMenu.ConfigData.GetNameDisplayMode() == GroupMenu.Constants.MENU_NAME_DISPLAY_OPTION_ACCOUNT then
        row:GetNamedChild('CharacterName'):SetText(displayName)
        GROUP_LIST_MANAGER.masterList[index].displayName = characterName
        GROUP_LIST_MANAGER.masterList[index].characterName = displayName
    else
        row:GetNamedChild('CharacterName'):SetText(characterName)
        GROUP_LIST_MANAGER.masterList[index].displayName = displayName
        GROUP_LIST_MANAGER.masterList[index].characterName = characterName
    end

    GroupMenu.Interface.UpdateColumnVisibility(extraRowElements, false)

    ZO_GroupListRow_OnMouseExit(row)

end

function GroupMenu.Interface.GetRow(index)

    if GroupMenu.Interface.Elements.ExtraRowElements[index] == nil then

        local row = GroupMenu.Interface.GetGroupListRow(index)
        local prefix = 'ZO_GroupListList1Row'..index

        GroupMenu.Interface.Elements.ExtraRowElements[index] = {
            [GroupMenu.Constants.COLUMN_INDEX_CP] = CreateControlFromVirtual(prefix..'ChampionPointsLabel', row, 'GroupMenu_Interface_Row_ChampionPoints'),
            [GroupMenu.Constants.COLUMN_INDEX_ALLIANCE] = CreateControlFromVirtual(prefix..'Alliance', row, 'GroupMenu_Interface_Row_Alliance'),
            [GroupMenu.Constants.COLUMN_INDEX_ALLIANCE_RANK] = CreateControlFromVirtual(prefix..'AllianceRank', row, 'GroupMenu_Interface_Row_AllianceRank'),
            [GroupMenu.Constants.COLUMN_INDEX_RACE] = CreateControlFromVirtual(prefix..'Race', row, 'GroupMenu_Interface_Row_Race'),
            [GroupMenu.Constants.COLUMN_INDEX_GENDER] = CreateControlFromVirtual(prefix..'Gender', row, 'GroupMenu_Interface_Row_Gender'),
            [GroupMenu.Constants.COLUMN_INDEX_SOCIAL] = CreateControlFromVirtual(prefix..'Social', row, 'GroupMenu_Interface_Row_Social')
        }

    end

    return GroupMenu.Interface.Elements.ExtraRowElements[index]

end

function GroupMenu.Interface.GetGroupListRow(index)

    return _G['ZO_GroupListList1Row'..index]

end

function GroupMenu.Interface.AllianceIndicator_OnMouseEnter(control)

    if control.allianceName then
        InitializeTooltip(InformationTooltip, control, BOTTOM)
        SetTooltipText(InformationTooltip, control.allianceName)
    end

    GroupMenu.Interface.Generic_OnMouseEnter(control)

end

function GroupMenu.Interface.AllianceRankIndicator_OnMouseEnter(control)

    if control.rankName then
        InitializeTooltip(InformationTooltip, control, BOTTOM)
        SetTooltipText(InformationTooltip, control.rankName)
    end

    GroupMenu.Interface.Generic_OnMouseEnter(control)

end

function GroupMenu.Interface.Generic_OnMouseEnter(control)

    GROUP_LIST:EnterRow(control.row)

end
