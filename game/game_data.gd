extends Node


func data() -> Dictionary:
	return {
		"initial values": {
			"starting_funds": 0,
			"starting_rep": 0,
			"total_artifacts": 6
		},

		"tools": [
			{
				"id": 0,
				"name": "Tool 1",
				"cost": 350,
				"unlock_required_rep": 75,
				"is_purchased": false
			},
			{
				"id": 1,
				"name": "Tool 2",
				"cost": 6000,
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
						"id": 0,
						"area": 0,
						"name": "Zone 1 art 1",
						"total_fragments": 4,
						"attempt_duration": 12,
						"required_tool": [],
						"rep_reward": 10,
						"fragment_funds_ps": 1.5,
						"completed_funds": 10.0,
						"success_chance": 40,
						"failure_reward": 10
					},
					{
						"id": 1,
						"area": 0,
						"name": "Zone 1 art 2",
						"total_fragments": 4,
						"attempt_duration": 20,
						"required_tool": [],
						"rep_reward": 25,
						"fragment_funds_ps": 2.5,
						"completed_funds": 20.0,
						"success_chance": 25,
						"failure_reward": 20
					},
					{
						"id": 2,
						"area": 0,
						"name": "Zone 1 art 3",
						"total_fragments": 4,
						"attempt_duration": 40,
						"required_tool": [0],
						"rep_reward": 100,
						"fragment_funds_ps": 5.0,
						"completed_funds": 40.0,
						"success_chance": 10,
						"failure_reward": 45
					}
				],
				"speed_upgrade": {
					"name": "speed",
					"max_level": 10,
					"time_reduction_percent": 0.1,
					"minimum_duration": 2.0,
					"base_cost": 25,
					"cost_increase_per_level": 25
				},
				"chance_upgrade": {
					"name": "chance",
					"max_level": 10,
					"chance_inc_per_level": 5,
					"base_cost": 25,
					"cost_increase_per_level": 25
				}
			},
			{
				"id": 1,
				"name": "Zone 2",
				"unlock_required_rep": 35,
				"artifacts": [
					{
						"id": 3,
						"area": 1,
						"name": "Zone 2 art 1",
						"total_fragments": 4,
						"attempt_duration": 20,
						"required_tool": [],
						"rep_reward": 40,
						"fragment_funds_ps": 3.0,
						"completed_funds": 35.0,
						"success_chance": 20,
						"failure_reward": 40
					},
					{
						"id": 4,
						"area": 1,
						"name": "Zone 2 art 2",
						"total_fragments": 4,
						"attempt_duration": 50,
						"required_tool": [0],
						"rep_reward": 150,
						"fragment_funds_ps": 5.0,
						"completed_funds": 70.0,
						"success_chance": 10,
						"failure_reward": 80
					},
					{
						"id": 5,
						"area": 1,
						"name": "Zone 2 art 3",
						"total_fragments": 4,
						"attempt_duration": 80,
						"required_tool": [1],
						"rep_reward": 300,
						"fragment_funds_ps": 8.0,
						"completed_funds": 150.0,
						"success_chance": 5,
						"failure_reward": 160
					}
				],
				"speed_upgrade": {
					"name": "speed",
					"max_level": 10,
					"time_reduction_percent": 0.1,
					"minimum_duration": 2.0,
					"base_cost": 150,
					"cost_increase_per_level": 150
				},
				"chance_upgrade": {
					"name": "chance",
					"max_level": 10,
					"chance_inc_per_level": 5,
					"base_cost": 150,
					"cost_increase_per_level": 150
				}
			}
		]
	}
