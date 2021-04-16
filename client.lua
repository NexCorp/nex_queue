local connected = false

AddEventHandler("playerSpawned", function()
	if not connected then
		TriggerServerEvent("nexQueue:playerConnected")
		connected = true
	end
end)