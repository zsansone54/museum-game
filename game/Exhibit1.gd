extends Control

@onready var top_hud: TopHud = $TopHud


func _ready() -> void:
	top_hud.pause_requested.connect(_on_pause_button_pressed)

	$PauseMenu.action_selected.connect(_on_pause_menu_action_selected)
	$SettingsMenu.closed.connect(_on_settings_menu_closed)

	$LeftButton.pressed.connect(_on_left_button_pressed)
	$RightButton.pressed.connect(_on_right_button_pressed)

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
		GameState.get_artifact_data(0)["name"]
	$ArtifactMargin/Gallery/Artifact2/Display/ArtifactName.text = \
		GameState.get_artifact_data(1)["name"]
	$ArtifactMargin/Gallery/Artifact3/Display/ArtifactName.text = \
		GameState.get_artifact_data(2)["name"]


func _on_artifact_1_inspect_button_pressed() -> void:
	$ArtifactMenu.open_menu(0)


func _on_artifact_2_inspect_button_pressed() -> void:
	$ArtifactMenu.open_menu(1)


func _on_artifact_3_inspect_button_pressed() -> void:
	$ArtifactMenu.open_menu(2)


func _on_right_button_pressed() -> void:
	SceneTransition.change_scene("res://Exhibit2.tscn", true)


func _on_left_button_pressed() -> void:
	SceneTransition.change_scene("res://Excavation.tscn", true)


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
