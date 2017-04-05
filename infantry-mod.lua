-- OpenRA: Red Alert - InfantryMod v1.0.0-beta.1
-- Created by xy - March 2017
-- Check for new releases on https://github.com/xy2z/OpenRA.InfantryMod
--
-- Feel free to make your own InfantryMod map,
-- just add the rules.yaml and infantry-mod.lua files to your map.


-- Variables
points_to_win = 0
count_tick = 0
players = nil
teams = {}
objective_oil = {}
count_players = 0
count_teams = 0
game_completed = false

Team1ID = nil
Team1Players = {}
team1_controls = 0
team1_points = 0.0

Team2ID = nil
Team2Players = {}
team2_controls = 0
team2_points = 0.0

-- Variables for Oil derricks
all_oil_derricks = { Actor11, Actor15, Actor18, Actor19, Actor20, Actor32, Actor38 }
count_oil_derricks = 0
for key, oil in pairs(all_oil_derricks) do
	count_oil_derricks = count_oil_derricks + 1
end

-- Custom functions
function set_winner_team(team_id)
	Media.DisplayMessage("Congratulations to Team " .. Team2ID)
	if team_id == Team1ID then
		winner_team_players = Team1Players
	else
		winner_team_players = Team2Players
	end

	-- Go through all players in the team.
	for key, player in pairs(players) do
		if not player.IsNonCombatant then
			-- Actual player (not a creep/neutral)
			-- if player.Team == team_id then
			if winner_team_players[player.InternalName] then
				-- Media.DisplayMessage("Debug: Mission COMPLETED for: " .. player.Name .. " (Team " .. player.Team .. ") (objective_oil ID: " .. objective_oil[player.InternalName] .. ")")
				player.MarkCompletedObjective(objective_oil[player.InternalName])
			else
			 	-- Mission failed.
				-- Media.DisplayMessage("Debug: Mission failed for: " .. player.Name .. " (Team " .. player.Team .. ") (objective_oil ID: " .. objective_oil[player.InternalName] .. ")")
				player.MarkFailedObjective(objective_oil[player.InternalName])
			end
		end
	end
end


function round_decimals(number, digits)
	shift = 10 ^ digits
	return math.floor( number * shift + 0.5 ) / shift
end


-- Welcome message + Triggers
WorldLoaded = function()
	players = Player.GetPlayers(nil)

	-- Briefing
	Media.DisplayMessage("Welcome Commanders!")
	Media.DisplayMessage("Get points by capturing and controlling oil derricks.")

	-- Media.DisplayMessage("Debug: Found " .. count_oil_derricks .. " oil derricks")

	-- Count players. Because if there's only 2 players teams doesn't need to be set.
	for key, player in pairs(players) do
		if not player.IsNonCombatant then
			-- Add primary objective
			objective_oil[player.InternalName] = player.AddPrimaryObjective("Capture oil derricks and get points to win.")

			-- Count total players
			count_players = count_players + 1
		end
	end

	-- Set teams.
	if count_players == 2 then
		-- Teams doesn't matter if there's only 2 players (so players doesn't have to select team)
		Team1ID = 1
		Team2ID = 2
		count_teams = 2
		local i = 0
		for key, player in pairs(players) do
			if not player.IsNonCombatant then
				i = i + 1
				if i == 1 then
					-- Media.DisplayMessage("1v1: Added player to team1: " .. player.Name .. " / " .. player.InternalName)
					Team1Players[player.InternalName] = player
				else
					-- Media.DisplayMessage("1v1: Added player to team2: " .. player.Name .. " / " .. player.InternalName)
					Team2Players[player.InternalName] = player
				end
			end
		end
	else
		-- More than 2 players.
		for key, player in pairs(players) do
			if not player.IsNonCombatant then
				-- Media.DisplayMessage("Debug: Objective added for " .. player.Name .. " id: " .. objective_oil[player.InternalName] .. " (InternalName: " .. player.InternalName .. ")")

				if player.Team == 0 then
					Media.DisplayMessage("Warning: Player is not assigned to any team: " .. player.Name)
				end

				-- Add the team to teams array/table.
				if teams[player.Team] == nil then
					count_teams = count_teams + 1
					teams[player.Team] = 1

					-- Set Team ID's
					if Team1ID == nil then
						Team1ID = player.Team
						Media.DisplayMessage("Debug: Set Team1ID to " .. player.Team)
					else
						Team2ID = player.Team
						Media.DisplayMessage("Debug: Set Team2ID to " .. player.Team)
					end
				end

				-- Add team players
				if player.Team == Team1ID then
					Team1Players[player.InternalName] = player
					Media.DisplayMessage("Debug: Team1Players: " .. player.Name)
				elseif player.Team == Team2ID then
					Team2Players[player.InternalName] = player
					Media.DisplayMessage("Debug: Team2Players: " .. player.Name)
				end
			end
		end

		-- Check there's exactly 2 teams.
		if not count_teams == 2 then
			Media.DisplayMessage("Warning: There should be exactly 2 teams for this map to work. There's " .. count_teams .. " teams.")
		end

		-- Fix if no teams are set (so script doesn't crash)
		if Team1ID == nil then
			Media.DisplayMessage("Debug: Set Team1ID to 1 (was nil)")
			Team1ID = 1
		end
		if Team2ID == nil then
			Media.DisplayMessage("Debug: Set Team1ID to 2 (was nil)")
			Team2ID = 2
		end
	end

	-- Show how many points it takes to win.
	points_to_win = count_players * 15
	if count_players == 2 then
		Media.DisplayMessage("The first player that gets " .. points_to_win .. " points wins! ")
	else
		Media.DisplayMessage("The first team that gets " .. points_to_win .. " points wins! ")
	end

	Media.DisplayMessage("Debug: Team1 ID: " .. Team1ID)
	Media.DisplayMessage("Debug: Team2 ID: " .. Team2ID)

	-- Triggers for oil derricks
	for key, actor in pairs(all_oil_derricks) do
		Trigger.OnCapture(actor, function(self, captor, oldOwner, newOwner)
			if newOwner.Team == 0 then
				Media.DisplayMessage(newOwner.Name .. " captured an oil derrick!")
			else
				Media.DisplayMessage(newOwner.Name .. " (Team " .. newOwner.Team .. ") captured an oil derrick!")
			end

			-- if newOwner.Team == Team1ID then
			if Team1Players[newOwner.InternalName] then
				-- Team 1
				team1_controls = team1_controls + 1
				if Team2Players[oldOwner.InternalName] then
					team2_controls = team2_controls - 1
				end
			else
				-- Team 2
				team2_controls = team2_controls + 1
				if Team1Players[oldOwner.InternalName] then
					team1_controls = team1_controls - 1
				end
			end
		end)

		Trigger.OnKilled(actor, function(self, killer)
			if game_completed then
				do return end
			end
			Media.DisplayMessage("An oil derrick has been destroyed!")
			-- Minus 1 control point for the team who controlled the oil derrick.
			-- if self.Owner.Team == Team1ID then
			if Team1Players[self.Owner.InternalName] then
				-- Team 1 lost an oil derrick.
				team1_controls = team1_controls - 1
			else
				-- Team 2 lost an oil derrick.
				team2_controls = team2_controls - 1
			end
		end)

	end

	-- If all oil derricks are killed. Team with most points wins.
	Trigger.OnAllKilled(all_oil_derricks, function()
		Media.DisplayMessage("All oil derricks have been destroyed! Team with most points wins.")
		if team1_points == team2_points then
			Media.DisplayMessage("It's a draw! Points are equal.")
			-- Kill team that doesn't exist so all other teams wins. TODO: Test!
			-- kill_team(99)
		elseif team1_points > team2_points then
			-- Media.DisplayMessage("Team " .. Team1ID .. " wins with " .. team1_points .. " points! Congratulations!")
			set_winner_team(Team1ID)
		else
			-- Media.DisplayMessage("Team " .. Team2ID .. " wins with " .. team2_points .. " points! Congratulations!")
			set_winner_team(Team2ID)
		end

	end)

end


-- Count points for controlled oil derricks.
-- Show points status.
Tick = function()
	-- Count points for captured oil derricks.
	count_tick = count_tick + 1
	if count_tick == 500 then
		count_tick = 0 -- Reset tick counter

		-- team1_points = team1_points + team1_controls
		-- team2_points = team2_points + team2_controls

		-- Count points: Loop through all oil derricks to see who controls it.

		-- Utils.Do(all_oil_derricks, function(actor)
		-- 	if not actor.IsDead and not actor.Owner.IsNonCombatant then
		-- 		-- Media.DisplayMessage("Tick: Oil derrick belongs to " .. actor.Owner.Name .. " - Team " .. actor.Owner.Team)
		-- 		-- if actor.Owner.Team == Team1ID then
		-- 		if Team1Players[actor.Owner.InternalName] then
		-- 			-- Team 1
		-- 			team1_points = team1_points + 1
		-- 		else
		-- 			-- Team 2
		-- 			team2_points = team2_points + 1
		-- 		end
		-- 	end
		-- end)

		-- Give points
		team1_points = team1_points + round_decimals(round_decimals(team1_controls / count_oil_derricks, 1) * 1.5, 1)
		team2_points = team2_points + round_decimals(round_decimals(team2_controls / count_oil_derricks, 1) * 1.5, 1)

		-- Check if we have a winner.
		if team1_points >= points_to_win then
			-- Media.DisplayMessage("Congratulations to Team " .. Team1ID .. "!")
			set_winner_team(Team1ID)
		elseif team2_points >= points_to_win then
			-- Media.DisplayMessage("Congratulations to Team " .. Team2ID .. "!")
			set_winner_team(Team2ID)
		end

		-- Show status
		if team1_points > 0 or team2_points > 0 then
			if count_players == 2 then
				-- Get player names.
				local team1player_name
				local team2player_name = 0
				for key, player in pairs(Team1Players) do
					team1player_name = player.Name
					-- Media.DisplayMessage("Debug: Get player1 name: " .. team1player_name)
				end
				for key, player in pairs(Team2Players) do
					team2player_name = player.Name
					-- Media.DisplayMessage("Debug: Get player2 name: " .. team2player_name)
				end
				Media.DisplayMessage("STATUS: " .. team1player_name .. ": " .. team1_points .. "/" .. points_to_win .. " points | " .. team2player_name .. ": " .. team2_points .. "/" .. points_to_win .. " points.")
			else
				-- Teams (over 2 players)
				Media.DisplayMessage("STATUS: Team " .. Team1ID .. ": " .. team1_points .. "/" .. points_to_win .. " points | Team " .. Team2ID .. ": " .. team2_points .. "/" .. points_to_win .. " points.")
			end
		end

	end
end
