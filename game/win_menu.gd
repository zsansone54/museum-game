extends Control

@onready var dimmer: ColorRect = $Dimmer
@onready var center_container: CenterContainer = $CenterContainer

@onready var title_label: Label = (
	$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
)
@onready var message_label: Label = (
	$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MessageLabel
)
@onready var main_menu_button: Button = (
	$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MainMenuButton
)

var open_position: Vector2
var closed_position: Vector2
var menu_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	GameState.game_completed.connect(_on_game_completed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)

	hide()

	await get_tree().process_frame

	open_position = center_container.position
	closed_position = open_position + Vector2(0, size.y + 40)
	center_container.position = closed_position
	dimmer.color.a = 0.0


func open_menu() -> void:
	if menu_tween and menu_tween.is_valid():
		menu_tween.kill()

	title_label.text = "Museum Complete!"
	message_label.text = (
		"Every artifact has been restored and displayed."
	)
	main_menu_button.text = "Return to Main Menu"

	show()
	center_container.position = closed_position
	dimmer.color.a = 0.0

	menu_tween = create_tween().set_parallel(true)

	menu_tween.tween_property(
		center_container,
		"position",
		open_position,
		0.35
	).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

	menu_tween.tween_property(
		dimmer,
		"color:a",
		0.7,
		0.2
	)


func close_to_main_menu() -> void:
	if menu_tween and menu_tween.is_valid():
		menu_tween.kill()

	menu_tween = create_tween().set_parallel(true)

	menu_tween.tween_property(
		center_container,
		"position",
		closed_position,
		0.3
	).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)

	menu_tween.tween_property(
		dimmer,
		"color:a",
		0.0,
		0.2
	)

	menu_tween.finished.connect(func() -> void:
		GameState.save_game()
		get_tree().paused = false
		get_tree().change_scene_to_file("res://MainMenu.tscn")
	)


func _on_game_completed() -> void:
	open_menu()
	get_tree().paused = true


func _on_main_menu_button_pressed() -> void:
	close_to_main_menu()
