extends Control

@onready var funds_label: Label = $Top/TopHudMargin/TopHud/FundsLabel
@onready var rep_label: Label = $Top/TopHudMargin/TopHud/RepLabel
@onready var countdown_label: Label = $Top/TopHudMargin/TopHud/CountdownLabel


func _ready() -> void:
	$PauseMenu.action_selected.connect(_on_pause_menu_action_selected)
	$SettingsMenu.closed.connect(_on_settings_menu_closed)

	$ArtifactMargin/Gallery/Artifact1/Display/InspectButton.pressed.connect(
		_on_artifact_1_inspect_button_pressed
	)
	$ArtifactMargin/Gallery/Artifact2/Display/InspectButton.pressed.connect(
		_on_artifact_2_inspect_button_pressed
	)
	$ArtifactMargin/Gallery/Artifact3/Display/InspectButton.pressed.connect(
		_on_artifact_3_inspect_button_pressed
	)


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


func _on_artifact_1_inspect_button_pressed() -> void:
	$ArtifactMenu.open_menu(0)


func _on_artifact_2_inspect_button_pressed() -> void:
	$ArtifactMenu.open_menu(1)


func _on_artifact_3_inspect_button_pressed() -> void:
	$ArtifactMenu.open_menu(2)


func _on_pause_menu_action_selected(action: String) -> void:
	match action:
		"resume":
			get_tree().paused = false

		"settings":
			$SettingsMenu.open()

		"exit":
			GameState.save_game()
			get_tree().paused = false
			get_tree().change_scene_to_file("res://MainMenu.tscn")


func _on_settings_menu_closed() -> void:
	$PauseMenu.open()


func _on_pause_button_pressed() -> void:
	$PauseMenu.open()
