extends Control

@onready var funds_label: Label = $Top/TopHudMargin/TopHud/FundsLabel
@onready var rep_label: Label = $Top/TopHudMargin/TopHud/RepLabel
@onready var countdown_label: Label = $Top/TopHudMargin/TopHud/CountdownLabel
@onready var lock_overlay: Control = $LockOverlay
@onready var requirement_label: Label = $LockOverlay/CenterContainer/VBoxContainer/RequirementLabel


func _ready() -> void:
	$PauseMenu.action_selected.connect(_on_pause_menu_action_selected)
	$SettingsMenu.closed.connect(_on_settings_menu_closed)

	$LeftButton.pressed.connect(_on_left_button_pressed)

	$ArtifactMargin/Gallery/Artifact1/Display/InspectButton.pressed.connect(
		_on_artifact_1_inspect_button_pressed
	)
	$ArtifactMargin/Gallery/Artifact2/Display/InspectButton.pressed.connect(
		_on_artifact_2_inspect_button_pressed
	)
	$ArtifactMargin/Gallery/Artifact3/Display/InspectButton.pressed.connect(
		_on_artifact_3_inspect_button_pressed
	)

	$ArtifactMargin/Gallery/Artifact1/Display/ArtifactName.text = \
		GameState.get_artifact_data(3)["name"]
	$ArtifactMargin/Gallery/Artifact2/Display/ArtifactName.text = \
		GameState.get_artifact_data(4)["name"]
	$ArtifactMargin/Gallery/Artifact3/Display/ArtifactName.text = \
		GameState.get_artifact_data(5)["name"]

	update_lock_state()
	update_hud()


func _process(_delta: float) -> void:
	update_hud()
	update_lock_state()


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


func update_lock_state() -> void:
	var area: Dictionary = GameState.get_area_data(1)
	var is_unlocked: bool = GameState.is_area_unlocked(area)

	lock_overlay.visible = !is_unlocked
	requirement_label.text = "Requires %d Reputation" % area["unlock_required_rep"]


func _on_artifact_1_inspect_button_pressed() -> void:
	$ArtifactMenu.open_menu(3)


func _on_artifact_2_inspect_button_pressed() -> void:
	$ArtifactMenu.open_menu(4)


func _on_artifact_3_inspect_button_pressed() -> void:
	$ArtifactMenu.open_menu(5)


func _on_left_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Exhibit1.tscn")


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
