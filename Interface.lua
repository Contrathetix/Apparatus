GroupMenu.Interface = {}

GroupMenu.Interface.LevelToChampionPointThreshold = 50

GroupMenu.Interface.Elements = {}
GroupMenu.Interface.Elements.RowElements = {}

GroupMenu.Interface.Elements.PotentialColumnChildrenToToggle = {
    'Icon', 'Heal', 'Tank', 'DPS'
}

function GroupMenu.Interface.UpdateMenuData()
    GroupMenu.Interface.UpdateHeaderRow()
    for i=1, #GROUP_LIST_MANAGER.masterList do
        GroupMenu.Interface.UpdateRowData(i)
    end
end

function GroupMenu.Interface.GetHeaderRow()
    return ZO_GroupListHeaders, 'ZO_GroupListHeaders'
end

function GroupMenu.Interface.GetListRow(index)
    local name = 'ZO_GroupListList1Row'..index
    return _G[name], name
end

function GroupMenu.Interface.DoesTableContainElement(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function GroupMenu.Interface.GetGenericRowElements(parent, namePrefix, templatePrefix, isHeaderRow)

    return {
        [GroupMenu.Constants.INDEX_CROWN] = isHeaderRow and CreateControlFromVirtual(namePrefix..'Leader', parent, templatePrefix..'Leader') or parent:GetNamedChild('Leader'),
        [GroupMenu.Constants.INDEX_NAME_ORIGINAL] = parent:GetNamedChild('CharacterName'),
        [GroupMenu.Constants.INDEX_INDEX] = CreateControlFromVirtual(namePrefix..'MemberIndex', parent, templatePrefix..'MemberIndex'),
        [GroupMenu.Constants.INDEX_NAME] = CreateControlFromVirtual(namePrefix..'Name', parent, templatePrefix..'Name'),
        [GroupMenu.Constants.INDEX_ZONE] = parent:GetNamedChild('Zone'),
        [GroupMenu.Constants.INDEX_CLASS] = parent:GetNamedChild('Class'),
        [GroupMenu.Constants.INDEX_LEVEL] = isHeaderRow and parent:GetNamedChild('Level') or CreateControlFromVirtual(namePrefix..'CustomLevel', parent, templatePrefix..'CustomLevel'),
        [GroupMenu.Constants.INDEX_CHAMPIONICON] = parent:GetNamedChild('Champion'),
        [GroupMenu.Constants.INDEX_ROLE] = parent:GetNamedChild('Role'),
        [GroupMenu.Constants.INDEX_CP] = CreateControlFromVirtual(namePrefix..'ChampionPoints', parent, templatePrefix..'ChampionPoints'),
        [GroupMenu.Constants.INDEX_ALLIANCE] = CreateControlFromVirtual(namePrefix..'Alliance', parent, templatePrefix..'Alliance'),
        [GroupMenu.Constants.INDEX_ALLIANCERANK] = CreateControlFromVirtual(namePrefix..'AllianceRank', parent, templatePrefix..'AllianceRank'),
        [GroupMenu.Constants.INDEX_RACE] = CreateControlFromVirtual(namePrefix..'Race', parent, templatePrefix..'Race'),
        [GroupMenu.Constants.INDEX_GENDER] = CreateControlFromVirtual(namePrefix..'Gender', parent, templatePrefix..'Gender'),
        [GroupMenu.Constants.INDEX_SOCIAL] = CreateControlFromVirtual(namePrefix..'Social', parent, templatePrefix..'Social')
    }

end

function GroupMenu.Interface.GetHeaderRowElements()

    if GroupMenu.Interface.Elements.HeaderElements == nil then

        local headerRow, namePrefix = GroupMenu.Interface.GetHeaderRow()
        local templatePrefix = 'GroupMenu_GroupListHeaders'
        local headerElements = GroupMenu.Interface.GetGenericRowElements(headerRow, namePrefix, templatePrefix, true)

        -- update the zone label anchor to make room for the new name column
        headerElements[GroupMenu.Constants.INDEX_ZONE]:SetAnchor(
            LEFT,
            headerElements[GroupMenu.Constants.INDEX_NAME],
            RIGHT,
            ZO_KEYBOARD_GROUP_LIST_PADDING_X
        )

        -- insert the new leader header label
        headerElements[GroupMenu.Constants.INDEX_NAME_ORIGINAL]:SetAnchor(
            LEFT,
            headerElements[GroupMenu.Constants.INDEX_CROWN],
            RIGHT,
            0
        )

        -- update the offset between the index and new name label, so it looks better
        headerElements[GroupMenu.Constants.INDEX_NAME]:SetAnchor(
            LEFT,
            headerElements[GroupMenu.Constants.INDEX_INDEX],
            RIGHT,
            ZO_KEYBOARD_GROUP_LIST_PADDING_X * 3
        )

        GroupMenu.Interface.Elements.HeaderElements = headerElements

    end

    return GroupMenu.Interface.Elements.HeaderElements

end

function GroupMenu.Interface.GetListRowElements(index)

    if GroupMenu.Interface.Elements.RowElements[index] == nil then

        local listRow, namePrefix = GroupMenu.Interface.GetListRow(index)
        local templatePrefix = 'GroupMenu_GroupListRow'
        local rowElements = GroupMenu.Interface.GetGenericRowElements(listRow, namePrefix, templatePrefix, false)

        -- hide the existing level label
        local originalLevelLabel = GroupMenu.Interface.GetListRow(index):GetNamedChild('Level')
        originalLevelLabel:SetWidth(1)
        GroupMenu.Interface.UpdateControlHiddenStatus(originalLevelLabel, true)

        -- update the zone anchor to account for the new name column
        rowElements[GroupMenu.Constants.INDEX_ZONE]:SetAnchor(
            LEFT,
            rowElements[GroupMenu.Constants.INDEX_NAME],
            RIGHT,
            ZO_KEYBOARD_GROUP_LIST_PADDING_X
        )

        -- anchor the role container to the new level container
        rowElements[GroupMenu.Constants.INDEX_ROLE]:SetAnchor(
            LEFT,
            rowElements[GroupMenu.Constants.INDEX_LEVEL],
            RIGHT,
            ZO_KEYBOARD_GROUP_LIST_PADDING_X
        )

        -- update the offset between the index and new name label, so it looks better
        rowElements[GroupMenu.Constants.INDEX_NAME]:SetAnchor(
            LEFT,
            rowElements[GroupMenu.Constants.INDEX_INDEX],
            RIGHT,
            ZO_KEYBOARD_GROUP_LIST_PADDING_X * 3
        )

        -- set the index column number
        rowElements[GroupMenu.Constants.INDEX_INDEX]:SetText(index..'.')

        GroupMenu.Interface.Elements.RowElements[index] = rowElements

    end

    return GroupMenu.Interface.Elements.RowElements[index]

end

function GroupMenu.Interface.UpdateRowData(index)

    local rowElements = GroupMenu.Interface.GetListRowElements(index)

    local unitData = GROUP_LIST_MANAGER.masterList[index]

    local displayName = GetUnitDisplayName(unitData.unitTag)
    local characterName = GetUnitName(unitData.unitTag)
    local race = GetUnitRace(unitData.unitTag)
    local socialStatus = GroupMenu.Strings.SocialStatusNeutral
    local gender = unitData.gender == 1 and GroupMenu.Strings.GenderFemale or GroupMenu.Strings.GenderMale
    local trueChampionPoints = unitData.online and GetUnitChampionPoints(unitData.unitTag) or ''
    local allianceId = GetUnitAlliance(unitData.unitTag)
    local allianceRank = GetUnitAvARank(unitData.unitTag)
    local allianceRankName = GetAvARankName(unitData.gender, allianceRank)

    if unitData.online == false then
        socialStatus = ''
    elseif unitData.isPlayer then
        socialStatus = GroupMenu.Strings.SocialStatusSelf
    elseif IsUnitFriend(unitData.unitTag) then
        socialStatus = GroupMenu.Strings.SocialStatusFriend
    elseif IsUnitIgnored(unitData.tag) then
        socialStatus = GroupMenu.Strings.SocialStatusIgnored
    end

    -- update the new name label text and tooltip
    if GroupMenu.ConfigData.GetNameDisplayMode() == GroupMenu.Constants.MENU_NAME_DISPLAY_OPTION_ACCOUNT then
        rowElements[GroupMenu.Constants.INDEX_NAME]:SetText(displayName)
        rowElements[GroupMenu.Constants.INDEX_NAME].tooltip = characterName
    else
        rowElements[GroupMenu.Constants.INDEX_NAME]:SetText(characterName)
        rowElements[GroupMenu.Constants.INDEX_NAME].tooltip = displayName
    end

    -- update the champion point label text
    rowElements[GroupMenu.Constants.INDEX_CP]:SetText(trueChampionPoints)

    -- display champion points only up to cap or above the cap, depending on user choice
    if unitData.level >= GroupMenu.Interface.LevelToChampionPointThreshold then
        rowElements[GroupMenu.Constants.INDEX_LEVEL]:SetText(GroupMenu.ConfigData.GetDisplayChampionPointsOverCap() and trueChampionPoints or unitData.championPoints)
    else
        rowElements[GroupMenu.Constants.INDEX_LEVEL]:SetText(unitData.level)
    end

    -- update the alliance indicator texture path and tooltip
    local allianceIndicatorTexture = rowElements[GroupMenu.Constants.INDEX_ALLIANCE]:GetNamedChild('Texture')
    allianceIndicatorTexture:SetTexture(ZO_GuildBrowser_GuildList_Keyboard:GetAllianceIcon(allianceId))
    allianceIndicatorTexture.tooltip = GetAllianceName(allianceId)

    -- update alliance rank indicator texture and tooltip
    local allianceRankIndicatorTexture = rowElements[GroupMenu.Constants.INDEX_ALLIANCERANK]:GetNamedChild('Texture')
    allianceRankIndicatorTexture:SetTexture(GetAvARankIcon(allianceRank))
    allianceRankIndicatorTexture.tooltip = allianceRankName

    -- update race, gender and social status text
    rowElements[GroupMenu.Constants.INDEX_RACE]:SetText(race)
    rowElements[GroupMenu.Constants.INDEX_GENDER]:SetText(gender)
    rowElements[GroupMenu.Constants.INDEX_SOCIAL]:SetText(socialStatus)

    -- update the visibility (width) of the columns
    GroupMenu.Interface.UpdateRowElementWidth(rowElements, false)

    -- update the crown column visibility
    if GroupMenu.ConfigData.GetColumnEnabled(GroupMenu.Constants.INDEX_CROWN) and unitData.leader then
        GroupMenu.Interface.UpdateControlHiddenStatus(rowElements[GroupMenu.Constants.INDEX_CROWN], false, true)
    end

    -- reset the colours and stuff
    local row = GroupMenu.Interface.GetListRow(index)
    if row then ZO_GroupListRow_OnMouseExit(row) end

end

function GroupMenu.Interface.UpdateHeaderRow()

    local headerElements = GroupMenu.Interface.GetHeaderRowElements()

    if GroupMenu.ConfigData.GetNameDisplayMode() == GroupMenu.Constants.MENU_NAME_DISPLAY_OPTION_ACCOUNT then
        headerElements[GroupMenu.Constants.INDEX_NAME]:SetText(GroupMenu.Strings.DisplayName)
    else
        headerElements[GroupMenu.Constants.INDEX_NAME]:SetText(GroupMenu.Strings.CharacterName)
    end

    GroupMenu.Interface.UpdateRowElementWidth(headerElements, true)

    GROUP_LIST:UpdateHeaders(GROUP_LIST.groupSize > 0)

end

function GroupMenu.Interface.UpdateRowElementWidth(rowElements, isHeaderRow)

    for key, control in pairs(rowElements) do
        if control ~= nil then
            if isHeaderRow and GroupMenu.Interface.DoesTableContainElement(GROUP_LIST.headers, control) == false then
                table.insert(GROUP_LIST.headers, control)
            end
            local controlWidth = GroupMenu.ConfigData.GetColumnWidth(key)
            control:SetWidth(controlWidth)
            GroupMenu.Interface.UpdateControlHiddenStatus(control, controlWidth < 2)
        end
    end

end

function GroupMenu.Interface.UpdateControlHiddenStatus(control, hidden, forceHiddenStatus)

    local setHidden = function(control, hidden, forceHiddenStatus)

        local _, point, relTo, relPoint, offsetX, offsetY = control:GetAnchor(0)
        local mouseEnabled = control:IsMouseEnabled()
        local hiddenStatus = control:IsHidden()

        control.originalMouseEnabled = control.originalMouseEnabled ~= nil and control.originalMouseEnabled or mouseEnabled
        control.originalOffsetX = control.originalOffsetX ~= nil and control.originalOffsetX or offsetX
        control.originalHiddenStatus = control.originalHiddenStatus ~= nil and control.originalHiddenStatus or hiddenStatus

        if hidden == true then
            control:SetAnchor(point, relTo, relPoint, 0)
            control:SetMouseEnabled(false)
            control:SetHidden(true)
        else
            if offsetX ~= control.originalOffsetX then
                control:SetAnchor(point, relTo, relPoint, control.originalOffsetX)
            end
            if mouseEnabled ~= control.originalMouseEnabled then
                control:SetMouseEnabled(control.originalMouseEnabled)
            end
            if forceHiddenStatus then
                control:SetHidden(hidden)
            elseif hiddenStatus ~= control.originalHiddenStatus then
                control:SetHidden(control.originalHiddenStatus)
            end
        end

    end

    for _, controlName in pairs(GroupMenu.Interface.Elements.PotentialColumnChildrenToToggle) do
        local childControl = control:GetNamedChild(controlName)
        if childControl then
            setHidden(childControl, hidden, forceHiddenStatus)
        end
    end

    setHidden(control, hidden, forceHiddenStatus)

end

function GroupMenu.Interface.UpdateGroupMenuSize(isMenuShown)

    -- default widths
    local menuWidthDefault = 930
    local backgroundWidthDefault = 1024

    -- the width of the left side of the menu, with the role selection, etc.
    local menuWidth = menuWidthDefault
    local backgroundWidth = backgroundWidthDefault

    if isMenuShown then

        local totalColumnWidth = GroupMenu.ConfigData.GetTotalColumnWidth()

        menuWidth = ZO_GroupMenu_KeyboardPreferredRoles:GetWidth() + totalColumnWidth + 40
        backgroundWidth = menuWidth + 200

    end

    local backgroundAnchorOffsetX = -35 - (menuWidth - menuWidthDefault)
    local backgroundAnchorOffsetY = -75

    local titleAnchorOffsetX = 30 - (menuWidth - menuWidthDefault)
    local titleAnchorOffsetY = -335

    local displayNameAnchorOffsetX = 0 - (menuWidth - menuWidthDefault)
    local displayNameAnchorOffsetY = 0

    local difficultySettingAnchorOffsetX = 0 - (menuWidth - menuWidthDefault) * 0.6
    local difficultySettingAnchorOffsetY = -10

    ZO_SharedRightBackgroundLeft:SetAnchor(TOPLEFT, ZO_SharedRightBackground, TOPLEFT, backgroundAnchorOffsetX, backgroundAnchorOffsetY)
    ZO_SharedRightBackgroundLeft:SetWidth(backgroundWidth)

    ZO_GroupListVeteranDifficultySettings:SetAnchor(BOTTOM, ZO_GroupList, TOP, difficultySettingAnchorOffsetX, difficultySettingAnchorOffsetY)

    ZO_SharedTitle:SetAnchor(RIGHT, GuiRoot, RIGHT, titleAnchorOffsetX, titleAnchorOffsetY)
    ZO_DisplayName:SetAnchor(TOPLEFT, ZO_KeyboardFriendsList, TOPLEFT, displayNameAnchorOffsetX, displayNameAnchorOffsetY)

    ZO_GroupMenu_Keyboard:SetWidth(menuWidth)

end

function GroupMenu.Interface.GroupListRowTooltipControl_OnMouseEnter(control)

    if control.tooltip then
        InitializeTooltip(InformationTooltip, control, BOTTOMLEFT, 0, 0, TOPLEFT)
        SetTooltipText(InformationTooltip, control.tooltip)
    end

    GroupMenu.Interface.GroupListRowLabel_OnMouseEnter(control)

end

function GroupMenu.Interface.GroupListRowLabel_OnMouseEnter(control)

    GROUP_LIST:EnterRow(control.row)

end
