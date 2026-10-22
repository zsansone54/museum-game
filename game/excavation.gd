extends Control

@onready var funds_label: Label = $Top/TopHudMargin/TopHud/FundsLabel
@onready var rep_label: Label = $Top/TopHudMargin/TopHud/RepLabel
@onready var countdown_label: Label = $Top/TopHudMargin/TopHud/CountdownLabel
@onready var income_label: Label = $Top/TopHudMargin/TopHud/IncomeLabel

@onready var pause_button: Button = $Top/TopHudMargin/TopHud/PauseButton
@onready var back_button: TextureButton = $RightButton
@onready var area_1_button: Button = $Area1Button
@onready var area_2_button: Button = $Area2Button
@onready var tools_button: Button = $ToolsButton

@onready var site_panel: Control = $SitePanel
@onready var site_name_label: Label = (
	$SitePanel/OuterPanel/MarginContainer/VBoxContainer/HeaderPanel/MarginContainer/SiteNameLabel
)
@onready var artifact_buttons: Array[Button] = [
	$SitePanel/OuterPanel/MarginContainer/VBoxContainer/Artifact1Button,
	$SitePanel/OuterPanel/MarginContainer/VBoxContainer/Artifact2Button,
	$SitePanel/OuterPanel/MarginContainer/VBoxContainer/Artifact3Button
]
@onready var speed_upgrade_button: Button = (
	$SitePanel/OuterPanel/MarginContainer/VBoxContainer/UpgradeRow/SpeedUpgradeButton
)
@onready var chance_upgrade_button: Button = (
	$SitePanel/OuterPanel/MarginContainer/VBoxContainer/UpgradeRow/ChanceUpgradeButton
)
@onready var site_close_button: TextureButton = $SitePanel/SiteCloseButton

@onready var equipment_panel: Control = $EquipmentPanel2
@onready var tool_buttons: Array[Button] = [
	$EquipmentPanel2/OuterPanel/MarginContainer/VBoxContainer/Tool1Button,
	$EquipmentPanel2/OuterPanel/MarginContainer/VBoxContainer/Tool2Button
]
@onready var equipment_close_button: TextureButton = (
	$EquipmentPanel2/EquipmentClosePanel
)

var current_site_artifacts: Array = []
var current_site_area: Dictionary = {}

var equipment_panel_open_position: Vector2
var equipment_panel_closed_position: Vector2
var equipment_panel_tween: Tween

var site_panel_open_position: Vector2
var site_panel_closed_position: Vector2
var site_panel_tween: Tween


func _ready() -> void:
	$PauseMenu.action_selected.connect(_on_pause_menu_action_selected)
	$SettingsMenu.closed.connect(_on_settings_menu_closed)

	pause_button.pressed.connect(_on_pause_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)

	area_1_button.pressed.connect(_on_area_1_button_pressed)
	area_2_button.pressed.connect(_on_area_2_button_pressed)
	tools_button.pressed.connect(_on_tools_button_pressed)

	artifact_buttons[0].pressed.connect(_on_artifact_1_button_pressed)
	artifact_buttons[1].pressed.connect(_on_artifact_2_button_pressed)
	artifact_buttons[2].pressed.connect(_on_artifact_3_button_pressed)

	speed_upgrade_button.pressed.connect(_on_speed_upgrade_button_pressed)
	chance_upgrade_button.pressed.connect(_on_chance_upgrade_button_pressed)
	site_close_button.pressed.connect(_on_site_close_button_pressed)

	tool_buttons[0].pressed.connect(_on_tool_1_button_pressed)
	tool_buttons[1].pressed.connect(_on_tool_2_button_pressed)
	equipment_close_button.pressed.connect(_on_equipment_close_button_pressed)

	site_panel.hide()
	equipment_panel.hide()

	update_hud()

	await get_tree().process_frame

	equipment_panel_open_position = equipment_panel.position
	equipment_panel_closed_position = (
		equipment_panel_open_position
		+ Vector2(0, equipment_panel.size.y + 40)
	)
	equipment_panel.position = equipment_panel_closed_position

	site_panel_open_position = site_panel.position
	site_panel_closed_position = (
		site_panel_open_position
		+ Vector2(0, site_panel.size.y + 40)
	)
	site_panel.position = site_panel_closed_position


func _process(_delta: float) -> void:
	update_hud()

	if site_panel.visible and not current_site_area.is_empty():
		refresh_site_panel()

	if equipment_panel.visible:
		refresh_tool_buttons()


func update_hud() -> void:
	funds_label.text = "$%d" % int(GameState.funds)

	income_label.text = "+$%.2f / sec" % (
		GameState.get_total_donation_income_per_second()
	)

	rep_label.text = "%d Rep" % GameState.rep

	if GameState.active_artifact_id == -1:
		countdown_label.text = "--.-- / --.-- s"
	else:
		var artifact: Dictionary = GameState.get_artifact_data(
			GameState.active_artifact_id
		)

		var total_time: float = GameState.get_effective_attempt_duration(
			artifact
		)

		countdown_label.text = "%.2f / %.2f s" % [
			max(GameState.excavation_countdown, 0.0),
			total_time
		]


func open_site(area_id: int) -> void:
	if (
		site_panel.visible
		and not current_site_area.is_empty()
		and current_site_area["id"] == area_id
	):
		close_site_panel()
		return

	current_site_area = GameState.get_area_data(area_id)

	if current_site_area.is_empty():
		return

	current_site_artifacts = current_site_area["artifacts"]

	refresh_site_panel()

	if site_panel_tween and site_panel_tween.is_valid():
		site_panel_tween.kill()

	site_panel.position = site_panel_closed_position
	site_panel.show()

	site_panel_tween = create_tween()
	site_panel_tween.set_trans(Tween.TRANS_QUAD)
	site_panel_tween.set_ease(Tween.EASE_OUT)

	site_panel_tween.tween_property(
		site_panel,
		"position",
		site_panel_open_position,
		0.1
	)


func close_site_panel() -> void:
	if site_panel_tween and site_panel_tween.is_valid():
		site_panel_tween.kill()

	site_panel_tween = create_tween()
	site_panel_tween.set_trans(Tween.TRANS_QUAD)
	site_panel_tween.set_ease(Tween.EASE_IN)

	site_panel_tween.tween_property(
		site_panel,
		"position",
		site_panel_closed_position,
		0.1
	)

	site_panel_tween.tween_callback(site_panel.hide)


func refresh_site_panel() -> void:
	if current_site_area.is_empty():
		return

	var is_unlocked: bool = GameState.is_area_unlocked(current_site_area)

	if not is_unlocked:
		site_name_label.text = "%s\nRequires %d Reputation" % [
			current_site_area["name"],
			current_site_area["unlock_required_rep"]
		]

		for button in artifact_buttons:
			button.text = "Locked Artifact"
			button.disabled = true
			button.tooltip_text = "Requires %d Reputation" % (
				current_site_area["unlock_required_rep"]
			)

		speed_upgrade_button.text = "Speed\nLocked"
		speed_upgrade_button.disabled = true
		speed_upgrade_button.tooltip_text = "Unlock this site first"

		chance_upgrade_button.text = "Chance\nLocked"
		chance_upgrade_button.disabled = true
		chance_upgrade_button.tooltip_text = "Unlock this site first"

		return

	site_name_label.text = current_site_area["name"]

	refresh_artifact_buttons()
	refresh_upgrade_buttons()


func refresh_artifact_buttons() -> void:
	for index in range(artifact_buttons.size()):
		var artifact: Dictionary = current_site_artifacts[index]
		var progress: Dictionary = GameState.get_artifact_progress(
			artifact["id"]
		)

		var button: Button = artifact_buttons[index]

		button.text = "%s\nSuccess Chance: %.0f%%" % [
			artifact["name"],
			GameState.get_effective_success_chance(artifact)
		]

		button.tooltip_text = ""

		if not GameState.has_required_tools(artifact):
			var missing_tools: PackedStringArray = []

			for tool_id in artifact["required_tool"]:
				if not GameState.tools[tool_id]["is_purchased"]:
					missing_tools.append(GameState.tools[tool_id]["name"])

			button.disabled = true
			button.tooltip_text = "Requires: " + ", ".join(missing_tools)

		elif progress["is_assembled"]:
			button.disabled = true
			button.tooltip_text = "Artifact already assembled"

		elif progress["fragments_found"] >= artifact["total_fragments"]:
			button.disabled = true
			button.tooltip_text = (
				"All fragments found — assemble it in the museum"
			)

		else:
			button.disabled = false


func refresh_upgrade_buttons() -> void:
	var area_id: int = current_site_area["id"]

	var speed_upgrade: Dictionary = current_site_area["speed_upgrade"]
	var speed_level: int = GameState.area_speed_upgrades[area_id]
	var speed_cost: float = get_upgrade_cost(speed_upgrade, speed_level)

	var chance_upgrade: Dictionary = current_site_area["chance_upgrade"]
	var chance_level: int = GameState.area_chance_upgrades[area_id]
	var chance_cost: float = get_upgrade_cost(chance_upgrade, chance_level)

	update_upgrade_button(
		speed_upgrade_button,
		"Speed",
		speed_upgrade,
		speed_level,
		speed_cost
	)

	update_upgrade_button(
		chance_upgrade_button,
		"Chance",
		chance_upgrade,
		chance_level,
		chance_cost
	)


func get_upgrade_cost(upgrade: Dictionary, current_level: int) -> float:
	return (
		upgrade["base_cost"]
		+ upgrade["cost_increase_per_level"] * current_level
	)


func update_upgrade_button(
	button: Button,
	upgrade_name: String,
	upgrade: Dictionary,
	current_level: int,
	cost: float
) -> void:
	var max_level: int = upgrade["max_level"]

	button.tooltip_text = ""

	if current_level >= max_level:
		button.text = "%s\nLv. %d / %d\nMAX" % [
			upgrade_name,
			current_level,
			max_level
		]

		button.disabled = true
		button.tooltip_text = "This upgrade is already at its maximum level"

	elif GameState.funds < cost:
		button.text = "%s\nLv. %d / %d\n$%d" % [
			upgrade_name,
			current_level,
			max_level,
			int(cost)
		]

		button.disabled = true
		button.tooltip_text = "Requires $%d" % int(cost)

	else:
		button.text = "%s\nLv. %d / %d\n$%d" % [
			upgrade_name,
			current_level,
			max_level,
			int(cost)
		]

		button.disabled = false
		button.tooltip_text = "Purchase this upgrade"


func select_site_artifact(index: int) -> void:
	var artifact: Dictionary = current_site_artifacts[index]

	GameState.select_excavation_target(artifact)
	close_site_panel()


func open_equipment_panel() -> void:
	if equipment_panel.visible:
		close_equipment_panel()
		return

	refresh_tool_buttons()

	if equipment_panel_tween and equipment_panel_tween.is_valid():
		equipment_panel_tween.kill()

	equipment_panel.position = equipment_panel_closed_position
	equipment_panel.show()

	equipment_panel_tween = create_tween()
	equipment_panel_tween.set_trans(Tween.TRANS_QUAD)
	equipment_panel_tween.set_ease(Tween.EASE_OUT)

	equipment_panel_tween.tween_property(
		equipment_panel,
		"position",
		equipment_panel_open_position,
		0.1
	)


func close_equipment_panel() -> void:
	if equipment_panel_tween and equipment_panel_tween.is_valid():
		equipment_panel_tween.kill()

	equipment_panel_tween = create_tween()
	equipment_panel_tween.set_trans(Tween.TRANS_QUAD)
	equipment_panel_tween.set_ease(Tween.EASE_IN)

	equipment_panel_tween.tween_property(
		equipment_panel,
		"position",
		equipment_panel_closed_position,
		0.1
	)

	equipment_panel_tween.tween_callback(equipment_panel.hide)


func refresh_tool_buttons() -> void:
	for tool_id in range(tool_buttons.size()):
		var button: Button = tool_buttons[tool_id]

		if tool_id >= GameState.tools.size():
			button.hide()
			continue

		button.show()

		var tool: Dictionary = GameState.tools[tool_id]
		var tool_name: String = tool["name"]
		var tool_cost: int = int(tool["cost"])
		var required_rep: int = tool["unlock_required_rep"]

		button.tooltip_text = ""

		if tool["is_purchased"]:
			button.text = "%s\nOwned" % tool_name
			button.disabled = true
			button.tooltip_text = "Already purchased"

		elif GameState.rep < required_rep:
			button.text = "%s\nCost: $%d | Requires: %d Rep" % [
				tool_name,
				tool_cost,
				required_rep
			]

			button.disabled = true
			button.tooltip_text = "Requires %d Reputation" % required_rep

		elif GameState.funds < tool_cost:
			button.text = "%s\nCost: $%d | Requires: %d Rep" % [
				tool_name,
				tool_cost,
				required_rep
			]

			button.disabled = true
			button.tooltip_text = "Requires $%d" % tool_cost

		else:
			button.text = "%s\nCost: $%d | Requires: %d Rep\nPurchase" % [
				tool_name,
				tool_cost,
				required_rep
			]

			button.disabled = false
			button.tooltip_text = "Purchase " + tool_name


func purchase_tool(tool_id: int) -> void:
	if tool_id < 0 or tool_id >= GameState.tools.size():
		return

	var was_purchased: bool = GameState.tools[tool_id]["is_purchased"]

	GameState.buy_tool(tool_id)

	if not was_purchased and GameState.tools[tool_id]["is_purchased"]:
		GameState.save_game()

	refresh_tool_buttons()


func purchase_speed_upgrade() -> void:
	if current_site_area.is_empty():
		return

	var area_id: int = current_site_area["id"]
	var old_level: int = GameState.area_speed_upgrades[area_id]

	GameState.buy_speed_upgrade(current_site_area)

	if GameState.area_speed_upgrades[area_id] > old_level:
		GameState.save_game()

	refresh_site_panel()


func purchase_chance_upgrade() -> void:
	if current_site_area.is_empty():
		return

	var area_id: int = current_site_area["id"]
	var old_level: int = GameState.area_chance_upgrades[area_id]

	GameState.buy_chance_upgrade(current_site_area)

	if GameState.area_chance_upgrades[area_id] > old_level:
		GameState.save_game()

	refresh_site_panel()


func _on_area_1_button_pressed() -> void:
	open_site(0)


func _on_area_2_button_pressed() -> void:
	open_site(1)


func _on_tools_button_pressed() -> void:
	open_equipment_panel()


func _on_artifact_1_button_pressed() -> void:
	select_site_artifact(0)


func _on_artifact_2_button_pressed() -> void:
	select_site_artifact(1)


func _on_artifact_3_button_pressed() -> void:
	select_site_artifact(2)


func _on_speed_upgrade_button_pressed() -> void:
	purchase_speed_upgrade()


func _on_chance_upgrade_button_pressed() -> void:
	purchase_chance_upgrade()


func _on_site_close_button_pressed() -> void:
	close_site_panel()


func _on_tool_1_button_pressed() -> void:
	purchase_tool(0)


func _on_tool_2_button_pressed() -> void:
	purchase_tool(1)


func _on_equipment_close_button_pressed() -> void:
	close_equipment_panel()


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
