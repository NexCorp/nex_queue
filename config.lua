Config = {}
Config.UseSteamID = false -- To be true you need nex_administration extension

----------------------------------------------------
--------        Intervals        -------------------
----------------------------------------------------

-- Waiting time for antispam / Waiting time for antispam 
Config.AntiSpamTimer = 2

-- Verification and allocation of a free place 
Config.TimerCheckPlaces = 3

-- Update of the message (emojis) and access to the free place for the lucky one 
Config.TimerRefreshClient = 3

-- Number of points updating 
Config.TimerUpdatePoints = 6

----------------------------------------------------
------------ Point names  ---------------------
----------------------------------------------------

-- Number of points earned for those who are waiting 
Config.AddPoints = 1

-- Number of points lost for those who entered the server
Config.RemovePoints = 1

-- Number of points earned for those who have 3 identical emojis (lottery) 
Config.LoterieBonusPoints = 25

-- Priority access
Config.Points = {
	-- {'steamID', points},
	-- More points its more fast
	-- Example
	--{'steam:123123123abcdf', 6000},
}


----------------------------------------------------
------------- Message texts  ------------------
----------------------------------------------------

Config.NoSteam = "Steam/Rockstar was not detected. Please (re) start Steam/Rockstar and FiveM, and try again. "

Config.EnRoute = "The plane will arrive in  "

Config.PointsRP = "Kilometers"

Config.Position = "Are you in position  "

Config.EmojiMsg = "If the emojis are frozen, restart your client : "

Config.EmojiBoost = "!!! Yeah!, " .. Config.LoterieBonusPoints .. " " .. Config.PointsRP .. " won !!!"

Config.PleaseWait_1 = "please wait "
Config.PleaseWait_2 = " seconds. The connection will start automatically !"


Config.Accident = "Whoops!, you just had an accident ... If it happens again, you can report it to support :) "


Config.Error = " ERROR: RESTART THE QUEUE SYSTEM AND CONTACT SUPPORT  "


Config.EmojiList = {
	'🐌', 
	'🐍',
	'🐎', 
	'🐑', 
	'🐒',
	'🐘', 
	'🐙', 
	'🐛',
	'🐜',
	'🐝',
	'🐞',
	'🐟',
	'🐠',
	'🐡',
	'🐢',
	'🐤',
	'🐦',
	'🐧',
	'🐩',
	'🐫',
	'🐬',
	'🐲',
	'🐳',
	'🐴',
	'🐅',
	'🐈',
	'🐉',
	'🐋',
	'🐀',
	'🐇',
	'🐏',
	'🐐',
	'🐓',
	'🐕',
	'🐖',
	'🐪',
	'🐆',
	'🐄',
	'🐃',
	'🐂',
	'🐁',
	'🔥'
}
