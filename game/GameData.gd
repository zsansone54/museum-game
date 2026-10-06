extends Node

static func data() -> Dictionary:
	return {
		"initial values" : {
			"starting_funds" : 25,
			"starting_rep" : 0,
			"total_artifacts" : 6
		},
		
		"tools" : [
			{
				"id" : 0,
				"name" : "Tool 1",
				"cost" : 300,
				"unlock_required_rep" : 75
			},
					{
				"id" : 1,
				"name" : "Tool 2",
				"cost" : 300,
				"unlock_required_rep" : 325
			},
		],
		
		"areas" : [
			{
				"id" : 0,
				"name" : "Zone 1",
				"unlock_required_rep" : 0,
				"success_chance" : 0.35,
				"failure_reward" : 5,
				"artifacts" : [
					{
						"id" : 0,
						"name" : "Zone 1 art 1",
						"total_fragments" : 4,
						"attempt_duration" : 10,
						"required_tool" : [],
						"rep_reward" : 10,
						"uncleaned_fragment_funds" : 5,
						"cleaned_fragment_funds" : 15,
						"completed_funds" : 100,
					},
					{
						"id" : 1,
						"name" : "Zone 1 art 2",
						"total_fragments" : 4,
						"attempt_duration" : 20,
						"required_tool" : [],
						"rep_reward" : 25,
						"uncleaned_fragment_funds" : 20,
						"cleaned_fragment_funds" : 50,
						"completed_funds" : 1000,
					},
					{
						"id" : 2,
						"name" : "Zone 1 art 3",
						"total_fragments" : 4,
						"attempt_duration" : 40,
						"required_tool" : [0],
						"rep_reward" : 100,
						"uncleaned_fragment_funds" : 50,
						"cleaned_fragment_funds" : 100,
						"completed_funds" : 5000,
					},
				],
				"speed_upgrade" : [
					{
						"name" : "speed",
						"max_level" : 10,
						"time_dec_per_level" : 2,
						"base_cost" : 10,
					}
				],
				"chance_upgrade" : [
					{
						"name" : "chance",
						"max_level" : 10,
						"chance_inc_per_level" : 0.05,
						"base_cost" : 10,
					}
				]
			},
			{
				"id" : 1,
				"name" : "Zone 2",
				"unlock_required_rep" : 35,
				"success_chance" : 0.15,
				"failure_reward" : 20,
				"artifacts" : [
					{
						"id" : 3,
						"name" : "Zone 2 art 1",
						"total_fragments" : 4,
						"attempt_duration" : 20,
						"required_tool" : [],
						"rep_reward" : 40,
						"uncleaned_fragment_funds" : 35,
						"cleaned_fragment_funds" : 70,
						"completed_funds" : 2500,
					},
					{
						"id" : 4,
						"name" : "Zone 2 art 2",
						"total_fragments" : 4,
						"attempt_duration" : 45,
						"required_tool" : [0],
						"rep_reward" : 150,
						"uncleaned_fragment_funds" : 20,
						"cleaned_fragment_funds" : 50,
						"completed_funds" : 1000,
					},
					{
						"id" : 5,
						"name" : "Zone 2 art 3",
						"total_fragments" : 4,
						"attempt_duration" : 80,
						"required_tool" : [1],
						"rep_reward" : 300,
						"uncleaned_fragment_funds" : 150,
						"cleaned_fragment_funds" : 300,
						"completed_funds" : 10000,
					},
				],
				"speed_upgrade" : [
					{
						"name" : "speed",
						"max_level" : 10,
						"time_dec_per_level" : 2,
						"base_cost" : 10,
					}
				],
				"chance_upgrade" : [
					{
						"name" : "chance",
						"max_level" : 10,
						"chance_inc_per_level" : 0.05,
						"base_cost" : 10,
					}
				]
			},
		]
	}
