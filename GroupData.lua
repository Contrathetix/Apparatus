GroupMenu.GroupData = {}

GroupMenu.GroupData.UnitTable = {}
GroupMenu.GroupData.EventHandlers = {}

-- initialisation of the overall group member data thingy
function GroupMenu.GroupData.Initialize()

    local masterList = GroupMenu.GroupData.GetMasterList()

    for i=1, #masterList do
        GroupMenu.GroupData.AddUnit(masterList[i].displayName, masterList[i])
    end

    local groupEventHandlerMap = {
        [EVENT_GROUP_MEMBER_JOINED] = GroupMenu.GroupData.EventHandlers.EventGroupMemberJoined,
        [EVENT_GROUP_MEMBER_LEFT] = GroupMenu.GroupData.EventHandlers.EventGroupMemberLeft,
        [EVENT_LEADER_UPDATE] = GroupMenu.GroupData.EventHandlers.EventLeaderUpdate,
        [EVENT_ZONE_UPDATE] = GroupMenu.GroupData.EventHandlers.EventZoneUpdate
    }

    for eventCode, handler in pairs(groupEventHandlerMap) do
        EVENT_MANAGER:RegisterForEvent(GroupMenu.Info.AddOnName, eventCode, handler)
    end

end

-- add a unit to the tracking and cache system
function GroupMenu.GroupData.AddUnit(displayName, masterListData)

    if not masterListData then
        local masterList = GroupMenu.GroupData.GetMasterList()
        for i=1, #masterList do
            if masterList[i].displayName == displayName then
                masterListData = masterList[i]
                break
            end
        end
    end

    if not masterListData then return end

    local unitData = {}

    -- data that can be acquired directly
    unitData.unitTag = masterListData.unitTag
    unitData.displayName = displayName
    unitData.characterName = masterListData.characterName
    unitData.isOnline = masterListData.online
    unitData.isPlayer = masterListData.isPlayer
    unitData.isLeader = masterListData.leader
    unitData.zone = masterListData.formattedZone
    unitData.gender = GroupMenu.Strings['Gender'..masterListData.gender]
    unitData.genderIndex = masterListData.gender
    unitData.connectionStatus = unitData.IsOnline and PLAYER_STATUS_ONLINE or PLAYER_STATUS_OFFLINE
    unitData.level = masterListData.level
    unitData.championPoints = masterListData.championPoints
    unitData.championPointsRaw = GetUnitChampionPoints(masterListData.unitTag)
    unitData.role = GetGroupMemberSelectedRole(masterListData.unitTag)

    if unitData.isOnline == false then
        unitData.socialStatus = nil
    elseif masterListData.isPlayer then
        unitData.socialStatus = GroupMenu.Strings.SocialStatusSelf
    elseif IsUnitFriend(masterListData.unitTag) then
        unitData.socialStatus = GroupMenu.Strings.SocialStatusFriend
    elseif IsUnitIgnored(masterListData.unitTag) then
        unitData.socialStatus = GroupMenu.Strings.SocialStatusIgnored
    else
        unitData.socialStatus = GroupMenu.Strings.SocialStatusNeutral
    end

    -- data that is not readily available
    unitData.race = GetUnitRace(masterListData.unitTag)

    -- alliance and icon path
    unitData.allianceId = GetUnitAlliance(masterListData.unitTag)
    unitData.allianceName = GetAllianceName(unitData.allianceId)
    unitData.allianceIcon = ZO_GuildBrowser_GuildList_Keyboard:GetAllianceIcon(unitData.allianceId)

    -- alliance rank
    unitData.allianceRank = GetUnitAvARank(masterListData.unitTag)
    unitData.allianceRankName = GetAvARankName(masterListData.gender, unitData.allianceRank)
    unitData.allianceRankIcon = GetAvARankIcon(unitData.allianceRank)
    unitData.allianceRankLastUpdate = os.time()

    GroupMenu.GroupData.EventHandlers.SetUnitRegistrationState(masterListData.unitTag, true)

    GroupMenu.GroupData.UnitTable[displayName] = unitData

end

-- remove unit from the tracking and cache system
function GroupMenu.GroupData.RemoveUnit(displayName)
    GroupMenu.GroupData.UnitTable[displayName] = nil
end

-- get the unit tag for a given display name
function GroupMenu.GroupData.GetUnitTag(displayName)
    local masterList = GroupMenu.GroupData.GetMasterList()
    for i=1, #masterList do
        if masterList[i].displayName == displayName then
            return masterList[i].unitTag
        end
    end
    return nil
end

-- get the display name based on unitTag
function GroupMenu.GroupData.GetUnitDisplayName(unitTag)
    local masterList = GroupMenu.GroupData.GetMasterList()
    for i=1, #masterList do
        if masterList[i].unitTag == unitTag then
            return masterList[i].displayName
        end
    end
    return nil
end

-- get the group size, need this because sometimes the variable in group list manager
-- is not there, when the menu has not yet been opened, for some reason
function GroupMenu.GroupData.GetGroupSize()
    if GROUP_LIST.groupSize then
        return GROUP_LIST.groupSize
    else
        return 0
    end
end

-- function to get the masterList, so in case it changes, does not need to edit every part
function GroupMenu.GroupData.GetMasterList()
    return GROUP_LIST_MANAGER.masterList
end

-- update unit tags, because they are not tied to the actual individual player/character,
-- but are instead 'group1', 'group2', 'group3', etc.
function GroupMenu.GroupData.UpdateUnitTags()
    local masterList = GroupMenu.GroupData.GetMasterList()
    for i=1, #masterList do
        local unitData = GroupMenu.GroupData.UnitTable[masterList[i].displayName]
        if unitData then
            unitData.unitTag = masterList[i].unitTag
        end
    end
end

-- get effective champion points, considering the usable cap
function GroupMenu.GroupData.GetEffectiveChampionPoints(championPoints)
    if championPoints >= GroupMenu.Constants.MAX_CP then
        return GroupMenu.Constants.MAX_CP
    else
        return championPoints
    end
end

-- fetch data from the masterlist
function GroupMenu.GroupData.GetUnitMasterListData(displayName)
    local masterList = GroupMenu.GroupData.GetMasterList()
    for i=1, #masterList do
        if masterList[i].displayName == displayName then
            return masterList[i]
        end
    end
end

-- fetch unit data, and update alliance rank if deemed relevant
function GroupMenu.GroupData.GetUnitData(displayName)

    local unitData = GroupMenu.GroupData.UnitTable[displayName]
    local allianceRankAge = os.difftime(os.time(), unitData.allianceRankLastUpdate)

    if allianceRankAge >= GroupMenu.Constants.MINIMUM_ALLIANCE_RANK_UPDATE_INTERVAL_SECONDS then
        local allianceRank = GetUnitAvARank(unitData.unitTag)
        if allianceRank ~= unitData.allianceRank then
            unitData.allianceRank = allianceRank
            unitData.allianceRankName = GetAvARankName(unitData.gender, unitData.allianceRank)
            unitData.allianceRankIcon = GetAvARankIcon(unitData.allianceRank)
        end
        unitData.allianceRankLastUpdate = os.time()
    end

    local masterListData = GroupMenu.GroupData.GetUnitMasterListData(displayName)
    unitData.isLeader = masterListData.leader

    return unitData

end

-- toggle the registration state for events for a single unit
function GroupMenu.GroupData.EventHandlers.SetUnitRegistrationState(unitTag, shouldBeRegistered)

    -- the esoui wiki seems to suggest that, to register filters per unitTag, need to use a
    -- separate namespace for each registration, so will do that maybe and hope it works
    local unitEventNamespace = GroupMenu.Info.AddOnName..'UnitEvent_'..unitTag

    local unitHandlerMap = {
        [EVENT_CHAMPION_POINT_UPDATE] = GroupMenu.GroupData.EventHandlers.EventChampionPointUpdate,
        [EVENT_LEVEL_UPDATE] = GroupMenu.GroupData.EventHandlers.EventLevelUpdate,
        [EVENT_GROUP_MEMBER_ROLE_CHANGED] = GroupMenu.GroupData.EventHandlers.EventGroupMemberRoleChanged
    }

    for eventCode, handler in pairs(unitHandlerMap) do
        if shouldBeRegistered then
            EVENT_MANAGER:RegisterForEvent(unitEventNamespace, eventCode, handler)
            EVENT_MANAGER:AddFilterForEvent(unitEventNamespace, eventCode, REGISTER_FILTER_UNIT_TAG, unitTag)
        else
            EVENT_MANAGER:UnregisterForEvent(unitEventNamespace, eventCode)
        end
    end

end

-- EVENT_GROUP_MEMBER_JOINED (number eventCode, string memberCharacterName, string memberDisplayName, boolean isLocalPlayer)
function GroupMenu.GroupData.EventHandlers.EventGroupMemberJoined(_, _, memberDisplayName, _)

    local unitTag = GroupMenu.GroupData.GetUnitTag(memberDisplayName)
    GroupMenu.GroupData.UpdateUnitTags()
    GroupMenu.GroupData.AddUnit(memberDisplayName)

end

-- EVENT_GROUP_MEMBER_LEFT (number eventCode, string memberCharacterName, GroupLeaveReason reason, boolean isLocalPlayer, boolean isLeader, string memberDisplayName, boolean actionRequiredVote)
function GroupMenu.GroupData.EventHandlers.EventGroupMemberLeft(_, _, _, _, _, memberDisplayName, _)

    local unitTag = GroupMenu.GroupData.GetUnitTag(memberDisplayName)
    GroupMenu.GroupData.RemoveUnit(memberDisplayName)
    GroupMenu.GroupData.UpdateUnitTags()

end

-- EVENT_ZONE_UPDATE (number eventCode, string unitTag, string newZoneName)
function GroupMenu.GroupData.EventHandlers.EventZoneUpdate(_, unitTag, newZoneName)

    local displayName = GroupMenu.GroupData.GetUnitDisplayName(unitTag)
    GroupMenu.GroupData.UnitTable[displayName].zone = newZoneName

end

-- EVENT_LEADER_UPDATE (number eventCode, string leaderTag)
function GroupMenu.GroupData.EventHandlers.EventLeaderUpdate(_, leaderTag)

    for _, unitData in pairs(GroupMenu.GroupData.UnitTable) do
        unitData.isLeader = unitData.unitTag == leaderTag
    end

end

-- EVENT_CHAMPION_POINT_UPDATE (number eventCode, string unitTag, number oldChampionPoints, number currentChampionPoints)
function GroupMenu.GroupData.EventHandlers.EventChampionPointUpdate(_, unitTag, _, currentChampionPoints)

    local displayName = GroupMenu.GroupData.GetUnitDisplayName(unitTag)
    local effectiveChampionPoints = GroupMenu.GroupData.GetEffectiveChampionPoints(currentChampionPoints)
    GroupMenu.GroupData.UnitTable[displayName].championPoints = effectiveChampionPoints
    GroupMenu.GroupData.UnitTable[displayName].championPointsRaw = currentChampionPoints

end

-- EVENT_LEVEL_UPDATE (number eventCode, string unitTag, number level)
function GroupMenu.GroupData.EventHandlers.EventLevelUpdate(_, unitTag, level)

    local displayName = GroupMenu.GroupData.GetUnitDisplayName(unitTag)
    GroupMenu.GroupData.UnitTable[displayName].level = level

end

--  EVENT_GROUP_MEMBER_ROLE_CHANGED (number eventCode, string unitTag, number LFGRole assignedRole)
function GroupMenu.GroupData.EventHandlers.EventGroupMemberRoleChanged(_, unitTag, assignedRole)

    local displayName = GroupMenu.GroupData.GetUnitDisplayName(unitTag)

    if GroupMenu.GroupData.UnitTable[displayName] then
        GroupMenu.GroupData.UnitTable[displayName].role = assignedRole
    end

end
