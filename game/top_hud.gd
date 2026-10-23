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

@onready var countdown_bar: TextureProgressBar = (
	$TextureRect/HBoxContainer/RepPlate2/MarginContainer/CountdownBar
)

@onready var remaining_time_label: Label = (
	$TextureRect/HBoxContainer/RepPlate2/MarginContainer/CountdownBar/RemainingTimeLabel
)

@onready var total_time_label: Label = (
	$TextureRect/HBoxContainer/RepPlate2/MarginContainer/CountdownBar/TotalTimeLabel
)

@onready var pause_button: TextureButton = (
	$TextureRect/HBoxContainer/PauseButton
)


func _ready() -> void:
	money_animation.play("spin")
	pause_button.pressed.connect(_on_pause_button_pressed)

	countdown_bar.min_value = 0.0
	countdown_bar.max_value = 1.0
	countdown_bar.step = 0.001
	countdown_bar.fill_mode = TextureProgressBar.FILL_LEFT_TO_RIGHT


	update_hud()


func _process(_delta: float) -> void:
	update_hud()


func update_hud() -> void:
	funds_label.text = "$%04d" % int(GameState.funds)

	income_label.text = "+ $%.2f / sec" % (
		GameState.get_total_donation_income_per_second()
	)

	rep_label.text = "%04d" % GameState.rep

	update_timer()


func update_timer() -> void:
	if GameState.active_artifact_id == -1:
		remaining_time_label.text = "--.-- s"
		total_time_label.text = "--.-- s"
		countdown_bar.value = 0.0
		return

	var artifact: Dictionary = GameState.get_artifact_data(
		GameState.active_artifact_id
	)

	var total_time: float = GameState.get_effective_attempt_duration(artifact)
	var remaining_time: float = max(GameState.excavation_countdown, 0.0)

	remaining_time_label.text = "%.2f s" % remaining_time
	total_time_label.text = "%.2f s" % total_time

	if total_time <= 0.0:
		countdown_bar.value = 0.0
		return

	# Starts empty and fills continuously as the excavation attempt progresses.
	var progress_ratio: float = clampf(
		1.0 - (remaining_time / total_time),
		0.0,
		1.0
	)

	countdown_bar.value = progress_ratio


func _on_pause_button_pressed() -> void:
	pause_requested.emit()
