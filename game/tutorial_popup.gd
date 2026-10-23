extends Control

signal completed

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


func _ready() -> void:
	hide()

	back_button.pressed.connect(_on_back_button_pressed)
	skip_button.pressed.connect(finish_tutorial)
	next_button.pressed.connect(_on_next_button_pressed)


func open() -> void:
	current_page = 0
	show()
	update_page()


func update_page() -> void:
	var page: Dictionary = PAGES[current_page]

	title_label.text = page["title"]
	message_label.text = page["message"]
	page_label.text = "Page %d of %d" % [current_page + 1, PAGES.size()]

	back_button.disabled = current_page == 0

	if current_page == PAGES.size() - 1:
		next_button.text = "Begin Curating"
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
	GameState.complete_tutorial()
	hide()
	completed.emit()
