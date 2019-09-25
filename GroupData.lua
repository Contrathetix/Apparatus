GroupMenu.GroupData = {}

-- the cache stores some data to avoid calling functions all the time, using the
-- character name as unique key, because apparently one user can have multiple
-- characters in a group at the same time
GroupMenu.GroupData.Cache = {}

function GroupMenu.GroupData.GetMasterList()
    return GROUP_LIST_MANAGER.masterList
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

function GroupMenu.GroupData.GetUnitCache(masterListData)

    local unitCache = GroupMenu.GroupData.Cache[masterListData.characterName]
    local cacheAge = GroupMenu.Constants.GROUP_MEMBER_CACHE_UPDATE_INTERVAL_SECONDS + 1

    if unitCache then
        cacheAge = os.difftime(os.time(), unitCache.lastCacheUpdateTime)
    end

    if cacheAge >= GroupMenu.Constants.GROUP_MEMBER_CACHE_UPDATE_INTERVAL_SECONDS then

        local allianceId = GetUnitAlliance(masterListData.unitTag)
        local allianceRank = GetUnitAvARank(masterListData.unitTag)

        unitCache = {
            allianceId = allianceId,
            allianceName = GetAllianceName(allianceId),
            allianceIcon = ZO_GuildBrowser_GuildList_Keyboard:GetAllianceIcon(allianceId),
            allianceRank = allianceRank,
            allianceRankName = GetAvARankName(masterListData.gender, allianceRank),
            allianceRankIcon = GetAvARankIcon(allianceRank),
            race = GetUnitRace(masterListData.unitTag),
            championPointsRaw = GetUnitChampionPoints(masterListData.unitTag)
        }

        if masterListData.online == false then
            unitCache.socialStatus = nil
        elseif masterListData.isPlayer then
            unitCache.socialStatus = GroupMenu.Strings.SocialStatusSelf
        elseif IsUnitFriend(masterListData.unitTag) then
            unitCache.socialStatus = GroupMenu.Strings.SocialStatusFriend
        elseif IsUnitIgnored(masterListData.unitTag) then
            unitCache.socialStatus = GroupMenu.Strings.SocialStatusIgnored
        else
            unitCache.socialStatus = GroupMenu.Strings.SocialStatusNeutral
        end

        unitCache.lastCacheUpdateTime = os.time()

        GroupMenu.GroupData.Cache[masterListData.characterName] = unitCache

    end

    return unitCache

end

function GroupMenu.GroupData.GetUnitData(masterListData)

    local unitData = {}
    local unitCache = GroupMenu.GroupData.GetUnitCache(masterListData)

    -- data that can be acquired directly
    unitData.unitTag = masterListData.unitTag
    unitData.displayName = masterListData.displayName
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

    -- data from the cache, should be data that does not change too often
    unitData.race = unitCache.race
    unitData.allianceId = unitCache.allianceId
    unitData.allianceName = unitCache.allianceName
    unitData.allianceIcon = unitCache.allianceIcon
    unitData.allianceRank = unitCache.allianceRank
    unitData.allianceRankName = unitCache.allianceRankName
    unitData.allianceRankIcon = unitCache.allianceRankIcon
    unitData.championPointsRaw = unitCache.championPointsRaw
    unitData.socialStatus = unitCache.socialStatus

    return unitData

end
