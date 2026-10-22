class_name TopHud
extends Control

signal pause_requested

@onready var funds_label: Label = (
	$TextureRect/HBoxContainer/FundsPlate/MarginContainer/FundsGroup/FundsText/FundsLabel
)

@onready var income_label: Label = (
	$TextureRect/HBoxContainer/FundsPlate/MarginContainer/FundsGroup/FundsText/IncomeLabel
)

@onready var rep_label: Label = $TextureRect/HBoxContainer/RepLabel
@onready var pause_button: TextureButton = $TextureRect/HBoxContainer/PauseButton

# These are optional for now. They will begin working once you add the
# named labels/progress bar inside TimerGroup later.
@onready var remaining_time_label := get_node_or_null(
	"TextureRect/HBoxContainer/TimerGroup/RemainingTimeLabel"
) as Label

@onready var total_time_label := get_node_or_null(
	"TextureRect/HBoxContainer/TimerGroup/TotalTimeLabel"
) as Label

@onready var countdown_bar := get_node_or_null(
	"TextureRect/HBoxContainer/TimerGroup/CountdownBar"
) as TextureProgressBar


func _ready() -> void:
	pause_button.pressed.connect(_on_pause_button_pressed)
	update_hud()


func _process(_delta: float) -> void:
	update_hud()


func update_hud() -> void:
	funds_label.text = "$%d" % int(GameState.funds)

	income_label.text = "+ $%.2f / sec" % (
		GameState.get_total_donation_income_per_second()
	)

	rep_label.text = "%d Rep" % GameState.rep

	update_timer()


func update_timer() -> void:
	if GameState.active_artifact_id == -1:
		if remaining_time_label != null:
			remaining_time_label.text = "--.-- s"

		if total_time_label != null:
			total_time_label.text = "--.-- s"

		if countdown_bar != null:
			countdown_bar.value = 0.0

		return

	var artifact: Dictionary = GameState.get_artifact_data(
		GameState.active_artifact_id
	)

	var total_time: float = GameState.get_effective_attempt_duration(artifact)
	var remaining_time: float = max(GameState.excavation_countdown, 0.0)

	if remaining_time_label != null:
		remaining_time_label.text = "%.2f s" % remaining_time

	if total_time_label != null:
		total_time_label.text = "%.2f s" % total_time

	if countdown_bar != null:
		countdown_bar.max_value = total_time
		countdown_bar.value = remaining_time


func _on_pause_button_pressed() -> void:
	pause_requested.emit()
