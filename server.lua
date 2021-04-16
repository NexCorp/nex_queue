local players = {} -- {id, points, source}
local waiting = {} -- {id}
local connecting = {} -- {id}

local prePoints = Config.Points;
local EmojiList = Config.EmojiList

Citizen.CreateThread(function()
	CheckWhitelistUsers()
end)

Citizen.CreateThread(function()
	local maxServerSlots = GetConvarInt('sv_maxclients', 128)
	
	while true do
		Citizen.Wait(Config.TimerCheckPlaces * 1000)

		CheckConnecting()

		if #waiting > 0 and #connecting + #GetPlayers() < maxServerSlots then
			ConnectFirst()
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		UpdatePoints()
		Citizen.Wait(Config.TimerUpdatePoints * 1000)
	end
end)


RegisterServerEvent("nex_queue:playerKicked")
RegisterServerEvent("nex_queue:playerConnected")
RegisterServerEvent('QueueNex:RefreshList', function() CheckWhitelistUsers() end) -- Used in nex_admin

AddEventHandler("playerConnecting", function(name, reject, def)
	local source	= source
	local userId = (Config.UseSteamID and GetSteamID(source) or GetLicenseID(source)) 

	if not userId then
		reject(Config.NoSteam)
		CancelEvent()
		return
	end

	if not Rocade(userId, def, source) then
		CancelEvent()
	end
end)

AddEventHandler("nex_queue:playerKicked", function(src, points)
	local sid = (Config.UseSteamID and GetSteamID(src) or GetLicenseID(src)) 

	Purge(sid)

	for i,p in ipairs(prePoints) do
		if p[1] == sid then
			p[2] = p[2] - points
			return
		end
	end

	local initialPoints = GetInitialPoints(sid)

	table.insert(prePoints, {sid, initialPoints - points})
end)

AddEventHandler("nexQueue:playerConnected", function()
	local sid = (Config.UseSteamID and GetSteamID(source) or GetLicenseID(source)) 

	Purge(sid)
end)

AddEventHandler("playerDropped", function(reason)
	local steamID = (Config.UseSteamID and GetSteamID(source) or GetLicenseID(source)) 

	Purge(steamID)
end)

function Rocade(userId, def, source)
	def.defer()

	AntiSpam(def)

	Purge(userId)

	AddPlayer(userId, source)

	table.insert(waiting, userId)

	local stop = false
	repeat

		for i,p in ipairs(connecting) do
			if p == userId then
				stop = true
				break
			end
		end

		for j,sid in ipairs(waiting) do
			for i,p in ipairs(players) do
				if sid == p[1] and p[1] == userId and (GetPlayerPing(p[3]) == 0) then
					Purge(userId)
					def.done(Config.Accident)
					return false
				end
			end
		end

		def.update(GetMessage(userId))

		Citizen.Wait(Config.TimerRefreshClient * 1000)

	until stop
	
	def.done()
	return true
end

function CheckWhitelistUsers()
	-- VIPS
	MySQL.Async.fetchAll("SELECT users_characters.isVip, users_identifiers.steam FROM users_characters INNER JOIN users_identifiers ON users_characters.identifier = users_identifiers.identifier WHERE users_characters.isVip > 0", {}, function(vipUsers)
		for k, v in pairs(vipUsers) do
			local data = {steamid = v.steam, points = 5000 }
			table.insert(prePoints, data)
		end
	end)

	-- STAFF
	MySQL.Async.fetchAll("SELECT users.group, users_identifiers.steam FROM users INNER JOIN users_identifiers ON users.identifier = users_identifiers.identifier WHERE users.group = 'admin'", {}, function(vipUsers)
		for k, v in pairs(vipUsers) do
			local data = {steamid = v.steam, points = 8000 }
			table.insert(prePoints, data)
		end
	end)
end

function CheckConnecting()
	for i,sid in ipairs(connecting) do
		for j,p in ipairs(players) do
			if p[1] == sid and (GetPlayerPing(p[3]) == 500) then
				table.remove(connecting, i)
				break
			end
		end
	end
end

function ConnectFirst()
	if #waiting == 0 then return end

	local maxPoint = 0
	local maxSid = waiting[1][1]
	local maxWaitId = 1

	for i,sid in ipairs(waiting) do
		local points = GetPoints(sid)
		if points > maxPoint then
			maxPoint = points
			maxSid = sid
			maxWaitId = i
		end
	end
	
	table.remove(waiting, maxWaitId)
	table.insert(connecting, maxSid)
end

function GetPoints(steamID)
	for i,p in ipairs(players) do
		if p[1] == steamID then
			return p[2]
		end
	end
end

function UpdatePoints()
	for i,p in ipairs(players) do

		local found = false

		for j,sid in ipairs(waiting) do
			if p[1] == sid then
				p[2] = p[2] + Config.AddPoints
				found = true
				break
			end
		end

		if not found then
			for j,sid in ipairs(connecting) do
				if p[1] == sid then
					found = true
					break
				end
			end
		
			if not found then
				p[2] = p[2] - Config.RemovePoints
				if p[2] < GetInitialPoints(p[1]) - Config.RemovePoints then
					Purge(p[1])
					table.remove(players, i)
				end
			end
		end

	end
end

function AddPlayer(steamID, source)
	for i,p in ipairs(players) do
		if steamID == p[1] then
			players[i] = {p[1], p[2], source}
			return
		end
	end

	local initialPoints = GetInitialPoints(steamID)
	table.insert(players, {steamID, initialPoints, source})
end

function GetInitialPoints(steamID)
	local points = Config.RemovePoints + 1

	for n,p in ipairs(prePoints) do
		if p[1] == steamID then
			points = p[2]
			break
		end
	end

	return points
end

function GetPlace(steamID)
	local points = GetPoints(steamID)
	local place = 1

	for i,sid in ipairs(waiting) do
		for j,p in ipairs(players) do
			if p[1] == sid and p[2] > points then
				place = place + 1
			end
		end
	end
	
	return place
end

function GetMessage(steamID)
	local msg = ""

	if GetPoints(steamID) ~= nil then
		msg = Config.EnRoute .. " " .. GetPoints(steamID) .." " .. Config.PointsRP ..".\n"

		msg = msg .. Config.Position .. GetPlace(steamID) .. "/".. #waiting .. " " .. ".\n"

		msg = msg .. "[ " .. Config.EmojiMsg

		local e1 = RandomEmojiList()
		local e2 = RandomEmojiList()
		local e3 = RandomEmojiList()
		local emojis = e1 .. e2 .. e3

		if( e1 == e2 and e2 == e3 ) then
			emojis = emojis .. Config.EmojiBoost
			LoterieBoost(steamID)
		end

		msg = msg .. emojis .. " ]"
	else
		msg = Config.Error
	end

	return msg
end

function LoterieBoost(steamID)
	for i,p in ipairs(players) do
		if p[1] == steamID then
			p[2] = p[2] + Config.LoterieBonusPoints
			return
		end
	end
end

function Purge(steamID)
	for n,sid in ipairs(connecting) do
		if sid == steamID then
			table.remove(connecting, n)
		end
	end

	for n,sid in ipairs(waiting) do
		if sid == steamID then
			table.remove(waiting, n)
		end
	end
end

function AntiSpam(def)
	for i=Config.AntiSpamTimer,0,-1 do
		def.update(Config.PleaseWait_1 .. i .. Config.PleaseWait_2)
		Citizen.Wait(1000)
	end
end

function RandomEmojiList()
	randomEmoji = EmojiList[math.random(#EmojiList)]
	return randomEmoji
end

function GetSteamID(src)
	local sid = GetPlayerIdentifiers(src)[1] or false

	if (sid == false or sid:sub(1,5) ~= "steam") then
		return false
	end

	return sid
end

function GetLicenseID(src)
	local identifier = false
	for k,v in ipairs(GetPlayerIdentifiers(playerId)) do
		if string.match(v, 'license:') then
			identifier = string.sub(v, 9)
			break
		end
	end
	return identifier
end