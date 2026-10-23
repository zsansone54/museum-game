extends Control

signal completed

@onready var dimmer: ColorRect = $ColorRect
@onready var tutorial_panel: PanelContainer = $PanelContainer

@onready var title_label: Label = $PanelContainer/PanelMargin/Tutorial/TitleLabel
@onready var message_label: Label = $PanelContainer/PanelMargin/Tutorial/MessageContainer/MessageBox/MessageLabel
@onready var page_label: Label = $PanelContainer/PanelMargin/Tutorial/MessageContainer/MessageBox/PageLabel

@onready var back_button: Button = $PanelContainer/PanelMargin/Tutorial/ButtonRow/BackButton
@onready var skip_button: Button = $PanelContainer/PanelMargin/Tutorial/ButtonRow/SkipButton
@onready var next_button: Button = $PanelContainer/PanelMargin/Tutorial/ButtonRow/NextButton


const PAGES := [
	{
		"title": "Welcome, Curator!",
		"message": "Restore the museum by assembling every artifact across both excavation areas. Assemble all six artifacts to complete the collection."
	},
	{
		"title": "Excavate for Fragments",
		"message": "Use the left arrow to visit the excavation map. Select an unlocked site, then choose an artifact. Attempts happen automatically: successes recover fragments, while failures provide funding."
	},
	{
		"title": "Upgrade Your Team",
		"message": "Fragments generate donations over time. Spend funds on excavation speed and success chance, and purchase tools to access more difficult artifacts."
	},
	{
		"title": "Build the Collection",
		"message": "Once every fragment is recovered, return to its exhibit and assemble the artifact. Completed displays generate more donations and reputation, unlocking the second excavation area."
	}
]

var current_page := 0
var open_position: Vector2
var closed_position: Vector2
var panel_tween: Tween
var is_closing := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	tutorial_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	hide()

	back_button.pressed.connect(_on_back_button_pressed)
	skip_button.pressed.connect(finish_tutorial)
	next_button.pressed.connect(_on_next_button_pressed)

	await get_tree().process_frame

	update_panel_positions()
	tutorial_panel.position = closed_position


func open() -> void:
	current_page = 0
	is_closing = false

	update_page()

	# Let Exhibit 1 appear before the overlay opens.
	await get_tree().create_timer(0.2).timeout

	update_panel_positions()
	tutorial_panel.position = closed_position
	dimmer.color.a = 0.0

	show()
	AudioManager.play_panel_open()

	panel_tween = create_tween().set_parallel(true)

	panel_tween.tween_property(
		tutorial_panel,
		"position",
		open_position,
		0.25
	).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

	panel_tween.tween_property(dimmer, "color:a", 0.3, 0.2)

func update_page() -> void:
	var page: Dictionary = PAGES[current_page]

	title_label.text = page["title"]
	message_label.text = page["message"]
	page_label.text = "Page %d of %d" % [current_page + 1, PAGES.size()]

	back_button.disabled = current_page == 0

	if current_page == PAGES.size() - 1:
		next_button.text = "Begin!"
	else:
		next_button.text = "Next"


func _on_back_button_pressed() -> void:
	if current_page <= 0:
		return

	current_page -= 1
	update_page()


func _on_next_button_pressed() -> void:
	if current_page >= PAGES.size() - 1:
		finish_tutorial()
		return

	current_page += 1
	update_page()


func finish_tutorial() -> void:
	if is_closing:
		return

	is_closing = true
	GameState.complete_tutorial()

	AudioManager.play_panel_close()

	if panel_tween and panel_tween.is_valid():
		panel_tween.kill()

	panel_tween = create_tween().set_parallel(true)

	panel_tween.tween_property(
		tutorial_panel,
		"position",
		closed_position,
		0.2
	).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)

	panel_tween.tween_property(dimmer, "color:a", 0.0, 0.2)

	panel_tween.finished.connect(func() -> void:
		hide()
		completed.emit()
	)
	
func update_panel_positions() -> void:
	var viewport_size := get_viewport_rect().size

	open_position = (viewport_size - tutorial_panel.size) * 0.5
	closed_position = Vector2(
		open_position.x,
		viewport_size.y + 40.0
	)
