extends Node

static func data() -> Array:
	return [
		{
			"starting_funds" = 25,
			"starting_rep" = 0,
			"total_artifacts" = 6
		},
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
		{
			"id" : 0,
			"name" : "Zone 1",
			"unlock_required_rep" : 0,
			"attempt_duration" : 10,
			"success_chance" : 0.35,
			"failure_reward" : 5,
			"artifact_ids" : [0,1,2],
			"artifacts" : [
				{
					"id" : 0,
					"name" : "Zone 1 art 1",
					"area_id" : 0,
					"total_fragments" : 4,
					"required_tool" : [false, false],
					"rep_reward" : 10,
					"uncleaned_fragment_funds" : 5,
					"cleaned_framgent_funds" : 15,
					"completed_funds" : 100,
					"multiplier" : 1
				},
				{
					"id" : 1,
					"name" : "Zone 1 art 2",
					"area_id" : 0,
					"total_fragments" : 4,
					"required_tool" : [false, false],
					"rep_reward" : 25,
					"uncleaned_fragment_funds" : 20,
					"cleaned_framgent_funds" : 50,
					"completed_funds" : 1000,
					"multiplier" : 0.8
				},
				{
					"id" : 2,
					"name" : "Zone 1 art 3",
					"area_id" : 0,
					"total_fragments" : 4,
					"required_tool" : [true, false],
					"rep_reward" : 100,
					"uncleaned_fragment_funds" : 50,
					"cleaned_framgent_funds" : 100,
					"completed_funds" : 5000,
					"multiplier" : 0.5
				},
			],
			"upgrades" : [
				{
					"speed" : [
						{
							"name" : "speed",
							"max_level" : 10,
							"time_dec_per_level" : 2,
							"base_cost" : 10,
						}
					],
					"chance" : [
						{
							"name" : "chance",
							"max_level" : 10,
							"chance_inc_per_level" : 0.05,
							"base_cost" : 10,
						}
					]
				}
			]
		},
		{
			"id" : 0,
			"name" : "Zone 2",
			"unlock_required_rep" : 35,
			"attempt_duration" : 20,
			"success_chance" : 0.15,
			"failure_reward" : 20,
			"artifact_ids" : [3,4,5],
			"artifacts" : [
				{
					"id" : 3,
					"name" : "Zone 2 art 1",
					"area_id" : 1,
					"total_fragments" : 4,
					"required_tool" : [false, false],
					"rep_reward" : 40,
					"uncleaned_fragment_funds" : 35,
					"cleaned_framgent_funds" : 70,
					"completed_funds" : 2500,
					"multiplier" : 1
				},
				{
					"id" : 4,
					"name" : "Zone 2 art 2",
					"area_id" : 1,
					"total_fragments" : 4,
					"required_tool" : [true, false],
					"rep_reward" : 150,
					"uncleaned_fragment_funds" : 20,
					"cleaned_framgent_funds" : 50,
					"completed_funds" : 1000,
					"multiplier" : 0.8
				},
				{
					"id" : 5,
					"name" : "Zone 2 art 3",
					"area_id" : 1,
					"total_fragments" : 4,
					"required_tool" : [true, true],
					"rep_reward" : 300,
					"uncleaned_fragment_funds" : 150,
					"cleaned_framgent_funds" : 300,
					"completed_funds" : 10000,
					"multiplier" : 0.5
				},
			],
			"upgrades" : [
				{
					"speed" : [
						{
							"name" : "speed",
							"max_level" : 10,
							"time_dec_per_level" : 2,
							"base_cost" : 10,
						}
					],
					"chance" : [
						{
							"name" : "chance",
							"max_level" : 10,
							"chance_inc_per_level" : 0.05,
							"base_cost" : 10,
						}
					]
				}
			]
		},
	]
