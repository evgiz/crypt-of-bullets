require "tablesaveload"

local save = {
	0,
	1,
	1,
	1,
}

save_Highscore = 0

local saveName = "cryptofbullets.save"

function loadGame()
	local save = table.load(saveName)

	if save ~= nil then
		applySave(save)
	else
		saveGame()
	end
end

function applySave(save)
	save_Highscore = save[1]

	for i=1,tablelength(paletteList) do
		paletteList[i].open = save[i+1]==1
	end
end

function saveGame()
	save[1] = save_Highscore

	for i=1,tablelength(paletteList) do
		if paletteList[i].open then
			save[i+1] = 1
		else
			save[i+1] = 0
		end
	end

	table.save(save, saveName)
end
