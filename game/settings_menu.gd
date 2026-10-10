extends Control

@onready var settings_panel: PanelContainer = $SettingsPanel
@onready var dimmer: ColorRect = $Dimmer

var open_position: Vector2
var closed_position: Vector2

func _ready() -> void:
	open_position = settings_panel.position
	closed_position = open_position + Vector2(0, settings_panel.size.y + 20)
	hide()

func open() -> void:
	show()
	settings_panel.position = closed_position
	var tween = create_tween().set_parallel(true)
	tween.tween_property(settings_panel, "position", open_position, 0.35)\
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(dimmer, "color:a", 0.65, 0.2)

func close() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(settings_panel, "position", closed_position, 0.3)\
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	tween.tween_property(dimmer, "color:a", 0.0, 0.2)
	tween.chain().tween_callback(hide)


func _on_close_button_pressed() -> void:
	close()
