local runFunc = {
	display = "RUN",
	displayCond = function(state)
		return true
	end,
	isMenu = false,
	exec = function(state)
		state:playPlayerAnim("run")
	end
}

local function runIfLowHP(index)
	return {
		index = index,
		display = "RUN",
		displayCond = function(state)
			return state.cranky.hp <= 1
		end,
		isMenu = false,
		exec = runFunc.exec
	}
end

local crankactions = {
{
	index = 1,
	display = "ATTACK",
	displayCond = function(state)
		return state.cranky.hp > 1
	end,
	isMenu = true,
	options = {
		{
			display = "BASIC",
			displayCond = function(state)
				return state.cranky.hp > 25
			end,
			selectEnemy = true,
			isMenu = false,
			exec = function(state)
				local randomnumber = math.random(20, 40)
				state.selectedEnemy.hp = state.selectedEnemy.hp - randomnumber
				state:playEnemyAnim(state.selectedEnemy, "hurt")
				state.text = "Cranky attacks " .. state.selectedEnemy.name .. " for " .. randomnumber .. " damage!"
			end
		},
		{
			display = "STRUGGLE",
			displayCond = function(state)
				return state.cranky.hp < 50
			end,
			selectEnemy = false,
			isMenu = false,
			exec = function(state)
				local text = ""
				local randomnumber = math.random(1, 10)
				for i = 1, # state.enemies do
					state.enemies[i].hp = state.enemies[i].hp - randomnumber
					state:playEnemyAnim(state.enemies[i], "hurt")
					text = text .. state.enemies[i].name .. " loss " .. randomnumber .. " health.\n"
					randomnumber = math.random(1, 10)
				end
				state.cranky.hp = state.cranky.hp - randomnumber
				text = text .. "Cranky loss " .. randomnumber .. " health.\n"
				state.text = text
				state:playPlayerAnim("hurt")
				state.cranky.cEmotion = "><"
			end
		}
	}
},
{
	index = 2,
	display = "SKILL",
	displayCond = function(state)
		return state.cranky.hp > 1
	end,
	isMenu = true,
	options = {
		{
			display = "HEAL",
			displayCond = function(state)
				return state.cranky.sp >= 40
			end,
			isMenu = false,
			exec = function(state)
				local rannum = math.random(20, 30)
				state.cranky.hp = helpers.clamp(state.cranky.hp + rannum, 0, state.cranky.maxhp)
				state.cranky.sp = helpers.clamp(state.cranky.sp - 40, 0, state.cranky.maxsp)
				te.playOne(sounds.heal,"static",'sfx',2)
				state.text = "Healed " .. rannum .. "."
			end
		}
	}
},
{
	index = 3,
	display = "DEFEND",
	displayCond = function(state)
		return state.cranky.hp > 1
	end,
	isMenu = true,
	options = {
		{
			display = "WAIT",
			displayCond = function(state)
				return true
			end,
			isMenu = false,
			exec = function(state)
				local list = {
					"for his amazon delivery",
					"for Hilda to respond to the message",
					"for Beck to respond to the message",
					"for absolutly no reason as he forgot what he was doing",
					"for his cornbread to made",
					"to ponders the meaning of life the universe and everything",
					"to eat some cornbread",
					"to do a jiggy",
					"to listen to the entire Beatblock OST"
				}
				
				state.text = "Cranky waits " .. list[math.random(1, #list)] .. " and gets reminded by the selectedEnemy that they are fighting."
			end
		}
	}
},
{
	index = 4,
	display = "ESCAPE",
	displayCond = function(state)
		return state.cranky.hp > 1
	end,
	isMenu = true,
	options = {
		runFunc
	}
}
}

table.insert(crankactions, runIfLowHP(1))
table.insert(crankactions, runIfLowHP(2))
table.insert(crankactions, runIfLowHP(3))
table.insert(crankactions, runIfLowHP(4))

return crankactions