extends Control

signal action_selected(action: String)

@onready var pause_panel: PanelContainer = $PausePanel
@onready var dimmer: ColorRect = $Dimmer

var open_position: Vector2
var closed_position: Vector2
var is_closing := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	open_position = pause_panel.position
	closed_position = open_position + Vector2(0, pause_panel.size.y + 20)
	pause_panel.position = closed_position
	hide()

func open() -> void:
	is_closing = false
	get_tree().paused = true

	show()
	pause_panel.position = closed_position
	dimmer.color.a = 0.0

	var tween := create_tween().set_parallel(true)
	tween.tween_property(pause_panel, "position", open_position, 0.35) \
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(dimmer, "color:a", 0.3, 0.2)

func close_with_action(action: String) -> void:
	if is_closing:
		return

	is_closing = true

	var tween := create_tween().set_parallel(true)
	tween.tween_property(pause_panel, "position", closed_position, 0.3) \
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	tween.tween_property(dimmer, "color:a", 0.0, 0.2)

	tween.finished.connect(func() -> void:
		hide()
		action_selected.emit(action)
	)

func _on_resume_button_pressed() -> void:
	close_with_action("resume")

func _on_settings_button_pressed() -> void:
	close_with_action("settings")

func _on_exit_button_pressed() -> void:
	close_with_action("exit")
