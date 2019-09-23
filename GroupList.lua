GroupMenu.GroupList = {}

GroupMenu.GroupList.EventHandlers = {}

GroupMenu.GroupList.Elements = {}
GroupMenu.GroupList.Elements.HeaderElements = nil
GroupMenu.GroupList.Elements.RowElements = {}
GroupMenu.GroupList.Elements.ChildControlsToToggle = {
    'Icon'
}

-- register for events upon init, to update the menu layout and displayed data when appropriate
function GroupMenu.GroupList.Initialize()
    SCENE_MANAGER:GetScene(GroupMenu.Constants.GROUP_MENU_SCENE_NAME):RegisterCallback(
        'StateChange', GroupMenu.GroupList.EventHandlers.EventMenuSceneStateChange
    )
end

-- used to enable or disable registration, because only needs to update on changes if the player
-- has the menu open at the moment, otherwise is not needed
function GroupMenu.GroupList.EventHandlers.SetGroupUpdateEventRegistrationState(shouldBeRegistered)
    local eventCode = EVENT_GROUP_UPDATE
    local handler = GroupMenu.GroupList.EventHandlers.EventGroupUpdate
    if shouldBeRegistered then
        EVENT_MANAGER:RegisterForEvent(GroupMenu.Info.AddOnName, eventCode, handler)
    else
        EVENT_MANAGER:UnregisterForEvent(GroupMenu.Info.AddOnName, eventCode)
    end
end

-- fired when the manu scene state changes, using it to track the menu hidden/shown state
function GroupMenu.GroupList.EventHandlers.EventMenuSceneStateChange(oldState, newState)
    if newState == SCENE_SHOWING and oldState == SCENE_HIDDEN then
        -- menu is about to be shown
        GroupMenu.GroupList.UpdateMenuSize(true)
    elseif newState == SCENE_SHOWN then
        -- menu is shown to the user
        GroupMenu.GroupList.UpdateMenu()
        GroupMenu.GroupList.EventHandlers.SetGroupUpdateEventRegistrationState(true)
    elseif newState == SCENE_HIDDEN then
        -- menu is hidden
        GroupMenu.GroupList.EventHandlers.SetGroupUpdateEventRegistrationState(false)
        GroupMenu.GroupList.UpdateMenuSize(false)
    end
end

-- generic handler for when mouse enters a row item, checking for a potential tooltip text and then
-- updating the menu visuals accordingly through the original GROUP_LIST
function GroupMenu.GroupList.EventHandlers.EventRowItemMouseEnter(control)
    if control.tooltip then
        InitializeTooltip(InformationTooltip, control, BOTTOMLEFT, 0, 0, TOPLEFT)
        SetTooltipText(InformationTooltip, control.tooltip)
    end
    if control.row then
        GROUP_LIST:EnterRow(control.row)
    end
end

-- EVENT_GROUP_UPDATE (number eventCode)
function GroupMenu.GroupList.EventHandlers.EventGroupUpdate(_)

    zo_callLater(GroupMenu.GroupList.UpdateMenu, GroupMenu.Constants.GROUP_UPDATE_EVENT_MENU_UPDATE_DELAY)

end

-- update the menu data, and only data, nothing else, no layout, etc.
function GroupMenu.GroupList.UpdateMenu()

    if GroupMenu.GroupData.GetGroupSize() < 1 then return end

    GroupMenu.GroupList.UpdateMenuHeaders()

    local masterList = GroupMenu.GroupData.GetMasterList()

    for i=1, #masterList do
        GroupMenu.GroupList.UpdateMenuRow(i, masterList[i].displayName)
    end

end

function GroupMenu.GroupList.UpdateMenuHeaders(updateLayout)

    local headerElements = GroupMenu.GroupList.GetHeaderRowElements()

    if not headerElements then return end

    if GroupMenu.ConfigData.GetNameDisplayMode() == GroupMenu.Constants.MENU_NAME_DISPLAY_OPTION_ACCOUNT then
        headerElements[GroupMenu.Constants.KEY_NAME]:SetText(GroupMenu.Strings.DisplayName)
    else
        headerElements[GroupMenu.Constants.KEY_NAME]:SetText(GroupMenu.Strings.CharacterName)
    end

    GroupMenu.GroupList.UpdateMenuRowLayout(headerElements)

    GROUP_LIST:UpdateHeaders(GroupMenu.GroupData.GetGroupSize() > 0)

end

function GroupMenu.GroupList.UpdateMenuRow(index, displayName)

    local rowElements = GroupMenu.GroupList.GetListRowElements(index)
    local unitData = GroupMenu.GroupData.GetUnitData(displayName)

    if not rowElements or not unitData then return end

    -- update the new name label text and tooltip
    if GroupMenu.ConfigData.GetNameDisplayMode() == GroupMenu.Constants.MENU_NAME_DISPLAY_OPTION_ACCOUNT then
        rowElements[GroupMenu.Constants.KEY_NAME]:SetText(unitData.displayName)
        rowElements[GroupMenu.Constants.KEY_NAME].tooltip = unitData.characterName
    else
        rowElements[GroupMenu.Constants.KEY_NAME]:SetText(unitData.characterName)
        rowElements[GroupMenu.Constants.KEY_NAME].tooltip = unitData.displayName
    end

    -- update the champion point label text
    rowElements[GroupMenu.Constants.KEY_CP]:SetText(unitData.championPoints)

    -- display champion points only up to cap or above the cap, depending on user choice
    if unitData.level >= GroupMenu.Constants.MAX_LEVEL then
        if GroupMenu.ConfigData.GetDisplayChampionPointsOverCap() then
            rowElements[GroupMenu.Constants.KEY_LEVEL]:SetText(unitData.championPointsRaw)
        else
            rowElements[GroupMenu.Constants.KEY_LEVEL]:SetText(unitData.championPoints)
        end
    else
        rowElements[GroupMenu.Constants.KEY_LEVEL]:SetText(unitData.level)
    end

    if not unitData.isOnline then
        rowElements[GroupMenu.Constants.KEY_LEVEL]:SetText(nil)
        rowElements[GroupMenu.Constants.KEY_CP]:SetText(nil)
    end

    -- update the alliance indicator texture path and tooltip
    local allianceIndicatorTexture = rowElements[GroupMenu.Constants.KEY_ALLIANCE]:GetNamedChild('Texture')
    allianceIndicatorTexture:SetTexture(unitData.allianceIcon)
    allianceIndicatorTexture.tooltip = unitData.allianceName

    -- update alliance rank indicator texture and tooltip
    local allianceRankIndicatorTexture = rowElements[GroupMenu.Constants.KEY_ALLIANCERANK]:GetNamedChild('Texture')
    allianceRankIndicatorTexture:SetTexture(unitData.allianceRankIcon)
    allianceRankIndicatorTexture.tooltip = unitData.allianceRankName

    -- update race, gender and social status text
    rowElements[GroupMenu.Constants.KEY_RACE]:SetText(unitData.race)
    rowElements[GroupMenu.Constants.KEY_GENDER]:SetText(unitData.gender)
    rowElements[GroupMenu.Constants.KEY_SOCIAL]:SetText(unitData.socialStatus)

    -- update row layout
    GroupMenu.GroupList.UpdateMenuRowLayout(rowElements, unitData)

    -- reset the hover effect to 'no mouse over'
    local row = GroupMenu.GroupList.GetListRow(index)
    if row then
        ZO_GroupListRow_OnMouseExit(row)
    end

end

-- update the layout of a row, that is,
function GroupMenu.GroupList.UpdateMenuRowLayout(rowElements, unitData)

    local columnWidthTable = GroupMenu.ConfigData.GetColumnWidthTable()
    local columnEnabledTable = GroupMenu.ConfigData.GetColumnEnabledTable()

    for key, element in pairs(rowElements) do

        local visible = columnEnabledTable[key]
        local targetWidth = 1

        if unitData then
            if key == GroupMenu.Constants.KEY_CROWN then
                visible = visible and unitData.isLeader
            --elseif index == GroupMenu.Constants.KEY_CLASS then
            --    visible = visible and unitData.isOnline
            elseif key == GroupMenu.Constants.KEY_CHAMPIONICON then
                visible = visible and unitData.isOnline and unitData.level >= GroupMenu.Constants.MAX_LEVEL
            end
        end

        GroupMenu.GroupList.SetElementVisibility(element, visible)

        if visible or (key == GroupMenu.Constants.KEY_CROWN and columnEnabledTable[key]) then
            targetWidth = columnWidthTable[key]
        end

        element:SetWidth(targetWidth)

    end

end

-- update the visibility of an item, mostly just one element on a row
function GroupMenu.GroupList.SetElementVisibility(element, shouldBeVisible)

    if element.originalStatus == nil then
        element.originalStatus = {
            mouseEnabled = element:IsMouseEnabled(),
            isHidden = element:IsHidden()
        }
    end

    for _, name in pairs(GroupMenu.GroupList.Elements.ChildControlsToToggle) do
        local child = element:GetNamedChild(name)
        if child then
            GroupMenu.GroupList.SetElementVisibility(child, shouldBeVisible)
        end
    end

    local shouldBeHidden = shouldBeVisible == false

    if element:IsHidden() ~= shouldBeHidden then
        element:SetHidden(shouldBeHidden)
    end

    local shouldBeMouseEnabled = shouldBeVisible and element.originalStatus.mouseEnabled or false

    if element:IsMouseEnabled() ~= shouldBeMouseEnabled then
        element:SetMouseEnabled(shouldBeMouseEnabled)
    end

end

-- update the menu size, by moving element anchors and adjusting background widths and such
function GroupMenu.GroupList.UpdateMenuSize(shouldBeExtended)

    -- default widths
    local menuWidthDefault = 930
    local backgroundWidthDefault = 1024

    -- the width of the left side of the menu, with the role selection, etc.
    local menuWidth = menuWidthDefault
    local backgroundWidth = backgroundWidthDefault

    if shouldBeExtended then
        local totalColumnWidth = GroupMenu.ConfigData.GetColumnWidthTotal()
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

    local rowElements = {
        [GroupMenu.Constants.KEY_CROWN] = isHeaderRow and CreateControlFromVirtual(namePrefix..'Leader', parent, templatePrefix..'Leader') or parent:GetNamedChild('Leader'),
        [GroupMenu.Constants.KEY_NAME_ORIGINAL] = parent:GetNamedChild('CharacterName'),
        [GroupMenu.Constants.KEY_INDEX] = CreateControlFromVirtual(namePrefix..'MemberIndex', parent, templatePrefix..'MemberIndex'),
        [GroupMenu.Constants.KEY_NAME] = CreateControlFromVirtual(namePrefix..'Name', parent, templatePrefix..'Name'),
        [GroupMenu.Constants.KEY_ZONE] = parent:GetNamedChild('Zone'),
        [GroupMenu.Constants.KEY_CLASS] = parent:GetNamedChild('Class'),
        [GroupMenu.Constants.KEY_LEVEL] = isHeaderRow and parent:GetNamedChild('Level') or CreateControlFromVirtual(namePrefix..'CustomLevel', parent, templatePrefix..'CustomLevel'),
        [GroupMenu.Constants.KEY_CHAMPIONICON] = parent:GetNamedChild('Champion'),
        [GroupMenu.Constants.KEY_ROLE] = parent:GetNamedChild('Role'),
        [GroupMenu.Constants.KEY_CP] = CreateControlFromVirtual(namePrefix..'ChampionPoints', parent, templatePrefix..'ChampionPoints'),
        [GroupMenu.Constants.KEY_ALLIANCE] = CreateControlFromVirtual(namePrefix..'Alliance', parent, templatePrefix..'Alliance'),
        [GroupMenu.Constants.KEY_ALLIANCERANK] = CreateControlFromVirtual(namePrefix..'AllianceRank', parent, templatePrefix..'AllianceRank'),
        [GroupMenu.Constants.KEY_RACE] = CreateControlFromVirtual(namePrefix..'Race', parent, templatePrefix..'Race'),
        [GroupMenu.Constants.KEY_GENDER] = CreateControlFromVirtual(namePrefix..'Gender', parent, templatePrefix..'Gender'),
        [GroupMenu.Constants.KEY_SOCIAL] = CreateControlFromVirtual(namePrefix..'Social', parent, templatePrefix..'Social')
    }

    for _, element in pairs(rowElements) do
        if element == nil then return nil end
    end

    return rowElements

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
            headerElements[GroupMenu.Constants.KEY_ZONE]:SetAnchor(
                LEFT,
                headerElements[GroupMenu.Constants.KEY_NAME],
                RIGHT,
                ZO_KEYBOARD_GROUP_LIST_PADDING_X
            )

            -- insert the new leader header label
            headerElements[GroupMenu.Constants.KEY_NAME_ORIGINAL]:SetAnchor(
                LEFT,
                headerElements[GroupMenu.Constants.KEY_CROWN],
                RIGHT,
                0
            )

            -- update the offset between the index and new name label, so it looks better
            headerElements[GroupMenu.Constants.KEY_NAME]:SetAnchor(
                LEFT,
                headerElements[GroupMenu.Constants.KEY_INDEX],
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
        originalLevelLabel:SetHidden(true)

        if rowElements ~= nil then

            -- update the zone anchor to account for the new name column
            rowElements[GroupMenu.Constants.KEY_ZONE]:SetAnchor(
                LEFT,
                rowElements[GroupMenu.Constants.KEY_NAME],
                RIGHT,
                ZO_KEYBOARD_GROUP_LIST_PADDING_X
            )

            -- anchor the role container to the new level container
            rowElements[GroupMenu.Constants.KEY_ROLE]:SetAnchor(
                LEFT,
                rowElements[GroupMenu.Constants.KEY_LEVEL],
                RIGHT,
                ZO_KEYBOARD_GROUP_LIST_PADDING_X
            )

            -- update the offset between the index and new name label, so it looks better
            rowElements[GroupMenu.Constants.KEY_NAME]:SetAnchor(
                LEFT,
                rowElements[GroupMenu.Constants.KEY_INDEX],
                RIGHT,
                ZO_KEYBOARD_GROUP_LIST_PADDING_X * 3
            )

            -- set the index column number
            rowElements[GroupMenu.Constants.KEY_INDEX]:SetText(index..'.')

            GroupMenu.GroupList.Elements.RowElements[index] = rowElements

        end

    end

    return GroupMenu.GroupList.Elements.RowElements[index]

end
