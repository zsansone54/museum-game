extends Control

@onready var top_hud: TopHud = $TopHud
@onready var lock_overlay: Control = $LockOverlay
@onready var tutorial_popup: Control = $TutorialPopup

@onready var requirement_label: Label = (
	$LockOverlay/CenterContainer/VBoxContainer/RequirementLabel
)

var tutorial_opened_from_pause := false


func _ready() -> void:
	top_hud.pause_requested.connect(_on_pause_button_pressed)

	$PauseMenu.action_selected.connect(_on_pause_menu_action_selected)
	$SettingsMenu.closed.connect(_on_settings_menu_closed)
	tutorial_popup.completed.connect(_on_tutorial_completed)

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


func _process(_delta: float) -> void:
	update_lock_state()


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
	SceneTransition.change_scene("res://Exhibit1.tscn", true)


func _on_pause_menu_action_selected(action: String) -> void:
	match action:
		"resume":
			get_tree().paused = false

		"settings":
			$SettingsMenu.open()

		"tutorial":
			tutorial_opened_from_pause = true
			tutorial_popup.open()

		"exit":
			GameState.save_game()
			get_tree().paused = false
			get_tree().change_scene_to_file("res://MainMenu.tscn")


func _on_settings_menu_closed() -> void:
	$PauseMenu.open()


func _on_tutorial_completed() -> void:
	if tutorial_opened_from_pause:
		tutorial_opened_from_pause = false
		$PauseMenu.open()


func _on_pause_button_pressed() -> void:
	$PauseMenu.open()
