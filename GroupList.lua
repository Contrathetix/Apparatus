GroupMenu.GroupList = {}

GroupMenu.GroupList.ChampionPointCap = 810
GroupMenu.GroupList.LevelToChampionPointThreshold = 50
GroupMenu.GroupList.Elements = {}
GroupMenu.GroupList.Elements.RowElements = {}
GroupMenu.GroupList.EventHandlers = {}
GroupMenu.GroupList.EventHandlers.GroupSceneName = 'groupMenuKeyboard'
GroupMenu.GroupList.PotentialChildControlsToToggle = {
    'Icon'
}


-- Initialisation to register for events, etc.

function GroupMenu.GroupList.Initialize()
    SCENE_MANAGER:GetScene(GroupMenu.GroupList.EventHandlers.GroupSceneName):RegisterCallback(
        'StateChange',
        GroupMenu.GroupList.EventHandlers.OnMenuSceneStateChange
    )
end


-- Event handlers for when the menu is opened/closed and stuff

function GroupMenu.GroupList.EventHandlers.OnMenuSceneStateChange(oldState, newState)
    if newState == SCENE_SHOWING and oldState == SCENE_HIDDEN then
        -- menu is about to be shown
        GroupMenu.GroupList.UpdateGroupMenuSize(true)
    elseif newState == SCENE_SHOWN then
        -- menu is shown to the user
        GroupMenu.GroupList.UpdateEntireMenu()
        GroupMenu.GroupData.SetDataChangeEventRegistrationState(true)
    elseif newState == SCENE_HIDDEN then
        -- menu is hidden
        GroupMenu.GroupData.SetDataChangeEventRegistrationState(false)
        GroupMenu.GroupList.UpdateGroupMenuSize(false)
    end
end

function GroupMenu.GroupList.EventHandlers.OnRowItemMouseEnter(control)
    if control.tooltip then
        InitializeTooltip(InformationTooltip, control, BOTTOMLEFT, 0, 0, TOPLEFT)
        SetTooltipText(InformationTooltip, control.tooltip)
    end
    if control.row then
        GROUP_LIST:EnterRow(control.row)
    end
end


--- Data update functions

function GroupMenu.GroupList.UpdateEntireMenu()
    GroupMenu.GroupList.UpdateHeaderRow()
    local masterList = GroupMenu.GroupData.GetMasterList()
    for i=1, #masterList do
        GroupMenu.GroupList.UpdateRowData(i, masterList[i])
    end
end

function GroupMenu.GroupList.UpdateRowData(index, masterListData)

    local rowElements = GroupMenu.GroupList.GetListRowElements(index)

    if rowElements == nil or masterListData == nil then return end

    for _, element in pairs(rowElements) do
        if element == nil then return end
    end

    local unitData = GroupMenu.GroupData.GetMemberData(masterListData.unitTag, masterListData)

    -- update the new name label text and tooltip
    if GroupMenu.ConfigData.GetNameDisplayMode() == GroupMenu.Constants.MENU_NAME_DISPLAY_OPTION_ACCOUNT then
        rowElements[GroupMenu.Constants.INDEX_NAME]:SetText(unitData.DisplayName)
        rowElements[GroupMenu.Constants.INDEX_NAME].tooltip = unitData.CharacterName
    else
        rowElements[GroupMenu.Constants.INDEX_NAME]:SetText(unitData.CharacterName)
        rowElements[GroupMenu.Constants.INDEX_NAME].tooltip = unitData.DisplayName
    end

    -- update the champion point label text
    rowElements[GroupMenu.Constants.INDEX_CP]:SetText(unitData.ChampionPoints)

    -- display champion points only up to cap or above the cap, depending on user choice
    if unitData.Level >= GroupMenu.GroupList.LevelToChampionPointThreshold then
        local championPointsToDisplay = unitData.ChampionPoints
        if GroupMenu.ConfigData.GetDisplayChampionPointsOverCap() == false then
            championPointsToDisplay = math.min(GroupMenu.GroupList.ChampionPointCap, championPointsToDisplay)
        end
        rowElements[GroupMenu.Constants.INDEX_LEVEL]:SetText(championPointsToDisplay)
    else
        rowElements[GroupMenu.Constants.INDEX_LEVEL]:SetText(unitData.Level)
    end

    if unitData.IsOnline == false then
        rowElements[GroupMenu.Constants.INDEX_LEVEL]:SetText(nil)
        rowElements[GroupMenu.Constants.INDEX_CP]:SetText(nil)
    end

    -- update the alliance indicator texture path and tooltip
    local allianceIndicatorTexture = rowElements[GroupMenu.Constants.INDEX_ALLIANCE]:GetNamedChild('Texture')
    allianceIndicatorTexture:SetTexture(unitData.AllianceIconPath)
    allianceIndicatorTexture.tooltip = unitData.AllianceName

    -- update alliance rank indicator texture and tooltip
    local allianceRankIndicatorTexture = rowElements[GroupMenu.Constants.INDEX_ALLIANCERANK]:GetNamedChild('Texture')
    allianceRankIndicatorTexture:SetTexture(unitData.AllianceRankIcon)
    allianceRankIndicatorTexture.tooltip = unitData.AllianceRankName

    -- update race, gender and social status text
    rowElements[GroupMenu.Constants.INDEX_RACE]:SetText(unitData.Race)
    rowElements[GroupMenu.Constants.INDEX_GENDER]:SetText(unitData.Gender)
    rowElements[GroupMenu.Constants.INDEX_SOCIAL]:SetText(unitData.SocialStatus)

    -- update the visibility (width) of the columns
    GroupMenu.GroupList.UpdateRowElementWidths(rowElements)
    GroupMenu.GroupList.UpdateRowElementVisibility(rowElements, unitData)

    -- reset the colours and stuff
    local row = GroupMenu.GroupList.GetListRow(index)
    if row then ZO_GroupListRow_OnMouseExit(row) end

end

function GroupMenu.GroupList.UpdateHeaderRow()

    local headerElements = GroupMenu.GroupList.GetHeaderRowElements()

    if headerElements == nil then return end

    for _, element in pairs(headerElements) do
        if element == nil then return end
    end

    if GroupMenu.ConfigData.GetNameDisplayMode() == GroupMenu.Constants.MENU_NAME_DISPLAY_OPTION_ACCOUNT then
        headerElements[GroupMenu.Constants.INDEX_NAME]:SetText(GroupMenu.Strings.DisplayName)
    else
        headerElements[GroupMenu.Constants.INDEX_NAME]:SetText(GroupMenu.Strings.CharacterName)
    end

    GroupMenu.GroupList.UpdateRowElementWidths(headerElements)
    GROUP_LIST:UpdateHeaders(GROUP_LIST.groupSize > 0)

end

function GroupMenu.GroupList.UpdateRowElementWidths(elements)
    local columnWidths = GroupMenu.ConfigData.GetColumnWidthAll()
    for index, width in pairs(columnWidths) do
        if elements[index] ~= nil then
            elements[index]:SetWidth(width)
        end
    end
end

function GroupMenu.GroupList.UpdateRowElementVisibility(elements, unitData)
    for index, element in pairs(elements) do
        local visible = GroupMenu.ConfigData.GetColumnEnabled(index)
        if index == GroupMenu.Constants.INDEX_CROWN then
            visible = visible and unitData.IsLeader
        elseif index == GroupMenu.Constants.INDEX_CLASS then
            visible = visible and unitData.IsOnline
        elseif index == GroupMenu.Constants.INDEX_CHAMPIONICON then
            visible = visible and unitData.IsOnline and unitData.Level >= GroupMenu.GroupList.LevelToChampionPointThreshold
        end
        GroupMenu.GroupList.SetElementVisibility(element, visible)
    end
end

function GroupMenu.GroupList.SetElementVisibility(element, visible)
    if element.originalStatus == nil then
        element.originalStatus = {
            mouseEnabled = element:IsMouseEnabled(),
            isHidden = element:IsHidden()
        }
    end
    for _, name in pairs(GroupMenu.GroupList.PotentialChildControlsToToggle) do
        local child = element:GetNamedChild(name)
        if child then
            GroupMenu.GroupList.SetElementVisibility(child, visible)
        end
    end
    local shouldBeHidden = visible == false
    if element:IsHidden() ~= shouldBeHidden then
        element:SetHidden(shouldBeHidden)
    end
    local shouldBeMouseEnabled = visible and element.originalStatus.mouseEnabled or false
    if element:IsMouseEnabled() ~= shouldBeMouseEnabled then
        element:SetMouseEnabled(shouldBeMouseEnabled)
    end
end


-- Functions to retrieve or generate menu elements

function GroupMenu.GroupList.GetHeaderRow()
    return ZO_GroupListHeaders, 'ZO_GroupListHeaders'
end

function GroupMenu.GroupList.GetListRow(index)
    local name = 'ZO_GroupListList1Row'..index
    return _G[name], name
end

function GroupMenu.GroupList.GetGenericRowElements(parent, namePrefix, templatePrefix, isHeaderRow)

    if parent == nil or namePrefix == nil or templatePrefix == nil then return nil end

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

function GroupMenu.GroupList.GetHeaderRowElements()

    if GroupMenu.GroupList.Elements.HeaderElements == nil then

        local headerRow, namePrefix = GroupMenu.GroupList.GetHeaderRow()
        local templatePrefix = 'GroupMenu_GroupListHeaders'
        local headerElements = GroupMenu.GroupList.GetGenericRowElements(headerRow, namePrefix, templatePrefix, true)

        if headerElements ~= nil then

            for _, element in pairs(headerElements) do
                if GroupMenu.Utilities.DoesTableContainValue(GROUP_LIST.headers, element) == false then
                    table.insert(GROUP_LIST.headers, element)
                end
            end

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

            GroupMenu.GroupList.Elements.HeaderElements = headerElements

        end

    end

    return GroupMenu.GroupList.Elements.HeaderElements

end

function GroupMenu.GroupList.GetListRowElements(index)

    if GroupMenu.GroupList.Elements.RowElements[index] == nil then

        local listRow, namePrefix = GroupMenu.GroupList.GetListRow(index)
        local templatePrefix = 'GroupMenu_GroupListRow'
        local rowElements = GroupMenu.GroupList.GetGenericRowElements(listRow, namePrefix, templatePrefix, false)

        -- hide the existing level label
        local originalLevelLabel = GroupMenu.GroupList.GetListRow(index):GetNamedChild('Level')
        originalLevelLabel:SetWidth(1)

        -- GroupMenu.Interface.UpdateControlHiddenStatus(originalLevelLabel, true)

        if rowElements ~= nil then

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

            GroupMenu.GroupList.Elements.RowElements[index] = rowElements

        end

    end

    return GroupMenu.GroupList.Elements.RowElements[index]

end


-- Miscellaneous functions

function GroupMenu.GroupList.UpdateGroupMenuSize(isMenuShown)

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
