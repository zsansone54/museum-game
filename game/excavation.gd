extends Control

@onready var funds_label: Label = $Top/TopHudMargin/TopHud/FundsLabel
@onready var rep_label: Label = $Top/TopHudMargin/TopHud/RepLabel
@onready var countdown_label: Label = $Top/TopHudMargin/TopHud/CountdownLabel

@onready var back_button: Button = $BackButton
@onready var area_1_button: Button = $MapArea/Area1Button
@onready var area_2_button: Button = $MapArea/Area2Button
@onready var pause_button: Button = $Top/TopHudMargin/TopHud/PauseButton

@onready var site_panel: PanelContainer = $SitePanel
@onready var site_name_label: Label = $SitePanel/MarginContainer/VBoxContainer/SiteNameLabel
@onready var artifact_buttons: Array[Button] = [
	$SitePanel/MarginContainer/VBoxContainer/Artifact1Button,
	$SitePanel/MarginContainer/VBoxContainer/Artifact2Button,
	$SitePanel/MarginContainer/VBoxContainer/Artifact3Button
]
@onready var close_button: Button = $SitePanel/MarginContainer/VBoxContainer/CloseButton

var current_site_artifacts: Array = []


func _ready() -> void:
	$PauseMenu.action_selected.connect(_on_pause_menu_action_selected)
	$SettingsMenu.closed.connect(_on_settings_menu_closed)
	pause_button.pressed.connect(_on_pause_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	area_1_button.pressed.connect(_on_area_1_button_pressed)
	area_2_button.pressed.connect(_on_area_2_button_pressed)

	artifact_buttons[0].pressed.connect(_on_artifact_1_button_pressed)
	artifact_buttons[1].pressed.connect(_on_artifact_2_button_pressed)
	artifact_buttons[2].pressed.connect(_on_artifact_3_button_pressed)

	close_button.pressed.connect(_on_close_button_pressed)

	site_panel.hide()
	update_hud()


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


func open_site(area_id: int) -> void:
	var area: Dictionary = GameState.get_area_data(area_id)
	var is_unlocked: bool = GameState.is_area_unlocked(area)

	current_site_artifacts = area["artifacts"]
	site_panel.show()

	if !is_unlocked:
		site_name_label.text = "%s\nRequires %d Reputation" % [
			area["name"],
			area["unlock_required_rep"]
		]

		for button in artifact_buttons:
			button.disabled = true

		return

	site_name_label.text = area["name"]

	for index in range(artifact_buttons.size()):
		var artifact: Dictionary = current_site_artifacts[index]
		var progress: Dictionary = GameState.get_artifact_progress(artifact["id"])

		artifact_buttons[index].text = artifact["name"]
		artifact_buttons[index].disabled = (
			progress["is_assembled"]
			or progress["fragments_found"] >= artifact["total_fragments"]
			or !GameState.has_required_tools(artifact)
		)


func select_site_artifact(index: int) -> void:
	var artifact: Dictionary = current_site_artifacts[index]
	GameState.select_excavation_target(artifact)
	site_panel.hide()


func _on_area_1_button_pressed() -> void:
	open_site(0)


func _on_area_2_button_pressed() -> void:
	open_site(1)


func _on_artifact_1_button_pressed() -> void:
	select_site_artifact(0)


func _on_artifact_2_button_pressed() -> void:
	select_site_artifact(1)


func _on_artifact_3_button_pressed() -> void:
	select_site_artifact(2)


func _on_close_button_pressed() -> void:
	site_panel.hide()


func _on_back_button_pressed() -> void:
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
