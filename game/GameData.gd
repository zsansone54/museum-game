extends Node

static func build_zones() -> Array:
	return [
		{
			"name": "Zone 1",
			"generator_rate": 0.0,
			"generator_cost": 10.0,
			"piece_bank": 0.0,
			"artifacts": [
				{
					"name": "Test",
					"total_pieces": 4,
					"filled_pieces": 0,
					"cleaned_pieces": 0,
					"income": 1,
					"finished": false,
					"on_display": false,
				},
			]
		},
	]
