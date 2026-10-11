extends Control

@onready var funds_label: Label = $Top/TopHudMargin/TopHud/FundsLabel
@onready var rep_label: Label = $Top/TopHudMargin/TopHud/RepLabel
@onready var countdown_label: Label = $Top/TopHudMargin/TopHud/CountdownLabel

func _process(_delta: float) -> void:
	update_hud()

func update_hud() -> void:
	funds_label.text = "$%d" % int(GameState.funds)
	rep_label.text = "%d Rep" % GameState.rep
	
	if GameState.active_artifact_id == -1:
		countdown_label.text = "--.-- / --.-- s"
	else:
		var artifact: Dictionary = GameState.get_artifact_data(
			GameState.active_artifact_id
		)
		var total_time: float = GameState.get_effective_attempt_duration(artifact)
		
		countdown_label.text = "%.2f / %.2f s" % [
			max(GameState.excavation_countdown, 0.0),
			total_time
		]
