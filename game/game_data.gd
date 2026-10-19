extends Node

func data() -> Dictionary:
	return {
		"initial values": {
			"starting_funds": 50,
			"starting_rep": 0,
			"total_artifacts": 6
		},

		"tools": [
			{
				"id": 0,
				"name": "Tool 1",
				"cost": 600,
				"unlock_required_rep": 75,
				"is_purchased": false
			},
			{
				"id": 1,
				"name": "Tool 2",
				"cost": 8000,
				"unlock_required_rep": 325,
				"is_purchased": false
			}
		],

		"areas": [
			{
				"id": 0,
				"name": "Zone 1",
				"unlock_required_rep": 0,
				"artifacts": [
					{
						"id": 0, "area": 0, "name": "Zone 1 art 1",
						"total_fragments": 4, "attempt_duration": 10,
						"required_tool": [], "rep_reward": 10,
						"uncleaned_fragment_funds_ps": 0.0,
						"cleaned_fragment_funds_ps": 0.5,
						"completed_funds": 4.0,
						"success_chance": 40, "failure_reward": 10
					},
					{
						"id": 1, "area": 0, "name": "Zone 1 art 2",
						"total_fragments": 4, "attempt_duration": 20,
						"required_tool": [], "rep_reward": 25,
						"uncleaned_fragment_funds_ps": 0.0,
						"cleaned_fragment_funds_ps": 1.25,
						"completed_funds": 10.0,
						"success_chance": 25, "failure_reward": 20
					},
					{
						"id": 2, "area": 0, "name": "Zone 1 art 3",
						"total_fragments": 4, "attempt_duration": 40,
						"required_tool": [0], "rep_reward": 100,
						"uncleaned_fragment_funds_ps": 0.0,
						"cleaned_fragment_funds_ps": 3.0,
						"completed_funds": 25.0,
						"success_chance": 10, "failure_reward": 45
					}
				],
				"speed_upgrade": {
					"name": "speed", "max_level": 10,
					"time_multiplier_per_level": 0.82,
					"base_cost": 75, "cost_multiplier": 1.6
				},
				"chance_upgrade": {
					"name": "chance", "max_level": 10,
					"chance_inc_per_level": 8,
					"base_cost": 75, "cost_multiplier": 1.6
				}
			},
			{
				"id": 1,
				"name": "Zone 2",
				"unlock_required_rep": 35,
				"artifacts": [
					{
						"id": 3, "area": 1, "name": "Zone 2 art 1",
						"total_fragments": 4, "attempt_duration": 20,
						"required_tool": [], "rep_reward": 40,
						"uncleaned_fragment_funds_ps": 0.0,
						"cleaned_fragment_funds_ps": 3.0,
						"completed_funds": 35.0,
						"success_chance": 20, "failure_reward": 40
					},
					{
						"id": 4, "area": 1, "name": "Zone 2 art 2",
						"total_fragments": 4, "attempt_duration": 45,
						"required_tool": [0], "rep_reward": 150,
						"uncleaned_fragment_funds_ps": 0.0,
						"cleaned_fragment_funds_ps": 5.0,
						"completed_funds": 70.0,
						"success_chance": 10, "failure_reward": 80
					},
					{
						"id": 5, "area": 1, "name": "Zone 2 art 3",
						"total_fragments": 4, "attempt_duration": 80,
						"required_tool": [1], "rep_reward": 300,
						"uncleaned_fragment_funds_ps": 0.0,
						"cleaned_fragment_funds_ps": 8.0,
						"completed_funds": 150.0,
						"success_chance": 5, "failure_reward": 160
					}
				],
				"speed_upgrade": {
					"name": "speed", "max_level": 10,
					"time_multiplier_per_level": 0.82,
					"base_cost": 200, "cost_multiplier": 1.6
				},
				"chance_upgrade": {
					"name": "chance", "max_level": 10,
					"chance_inc_per_level": 8,
					"base_cost": 200, "cost_multiplier": 1.6
				}
			}
		]
	}
