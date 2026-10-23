class_name TopHud
extends Control

signal pause_requested

@onready var money_animation: AnimatedSprite2D = (
	$TextureRect/HBoxContainer/FundsPlate/MarginContainer/FundsGroup/MoneyIcon/AnimatedSprite2D
)

@onready var funds_label: Label = (
	$TextureRect/HBoxContainer/FundsPlate/MarginContainer/FundsGroup/FundsText/FundsLabel
)

@onready var income_label: Label = (
	$TextureRect/HBoxContainer/FundsPlate/MarginContainer/FundsGroup/FundsText/IncomeLabel
)

@onready var rep_label: Label = (
	$TextureRect/HBoxContainer/RepPlate/MarginContainer/RepGroup/RepLabel
)

@onready var countdown_bar: Control = (
	$TextureRect/HBoxContainer/CountdownBar
)

@onready var yellow_bar: HBoxContainer = (
	$TextureRect/HBoxContainer/CountdownBar/YellowBar
)

@onready var remaining_time_label: Label = (
	$TextureRect/HBoxContainer/CountdownBar/RemainingTimeLabel
)

@onready var total_time_label: Label = (
	$TextureRect/HBoxContainer/CountdownBar/TotalTimeLabel
)

@onready var pause_button: TextureButton = (
	$TextureRect/HBoxContainer/PauseButton
)

@onready var yellow_left: TextureRect = (
	$TextureRect/HBoxContainer/CountdownBar/YellowBar/YellowLeft
)

@onready var yellow_right: TextureRect = (
	$TextureRect/HBoxContainer/CountdownBar/YellowBar/YellowRight
)

func _ready() -> void:
	money_animation.play("spin")
	pause_button.pressed.connect(_on_pause_button_pressed)

	await get_tree().process_frame
	update_hud()


func _process(_delta: float) -> void:
	update_hud()


func update_hud() -> void:
	funds_label.text = "$%d" % int(GameState.funds)

	income_label.text = "+ $%.2f / sec" % (
		GameState.get_total_donation_income_per_second()
	)

	rep_label.text = "%04d" % GameState.rep

	update_timer()


func update_timer() -> void:
	if GameState.active_artifact_id == -1:
		remaining_time_label.text = "--.-- s"
		total_time_label.text = "--.-- s"

		yellow_bar.hide()
		return

	var artifact: Dictionary = GameState.get_artifact_data(
		GameState.active_artifact_id
	)

	var total_time: float = GameState.get_effective_attempt_duration(artifact)
	var remaining_time: float = max(GameState.excavation_countdown, 0.0)

	remaining_time_label.text = "%.2f s" % remaining_time
	total_time_label.text = "%.2f s" % total_time

	if total_time <= 0.0:
		yellow_bar.hide()
		return

	var progress_ratio: float = clampf(
		1.0 - (remaining_time / total_time),
		0.0,
		1.0
	)

	var filled_width: float = countdown_bar.size.x * progress_ratio
	var has_progress: bool = filled_width > 0.5

	yellow_bar.visible = has_progress

	var show_end_caps: bool = filled_width >= 64.0
	var progress_ratio: float = clampf(
	1.0 - (remaining_time / total_time),
	0.0,
	1.0
)

var filled_width: float = countdown_bar.size.x * progress_ratio
var has_progress: bool = filled_width > 0.5

yellow_bar.visible = has_progress

# A short fill cannot fit both 32-pixel end caps.
# Let the yellow middle grow immediately, then add caps once it is wide enough.
var show_end_caps: bool = filled_width >= 64.0
yellow_left.visible = show_end_caps
yellow_right.visible = show_end_caps

yellow_bar.position = Vector2.ZERO
yellow_bar.size = Vector2(
	filled_width,
	countdown_bar.size.y
)_left.visible = show_end_caps
	red_right.visible = show_end_caps

	red_bar.position = Vector2.ZERO
	red_bar.size = Vector2(
		filled_width,
		countdown_bar.size.y
	)


func _on_pause_button_pressed() -> void:
	pause_requested.emit()
