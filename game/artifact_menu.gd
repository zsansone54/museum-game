extends Control

@onready var artifact_panel: PanelContainer = $ArtifactPanel
@onready var dimmer: ColorRect = $Dimmer
@onready var artifact_name_label: Label = (
	$"ArtifactPanel/MarginContainer/VBoxContainer/Header Panel/VBoxContainer/ArtifactNameLabel"
)
@onready var fragment_progress_label: Label = (
	$"ArtifactPanel/MarginContainer/VBoxContainer/Header Panel/VBoxContainer/FragmentProgressLabel"
)
@onready var fragment_income_label: Label = (
	$"ArtifactPanel/MarginContainer/VBoxContainer/Header Panel/VBoxContainer/FragmentIncomeLabel"
)
@onready var assembled_income_label: Label = (
	$"ArtifactPanel/MarginContainer/VBoxContainer/Header Panel/VBoxContainer/AssembledIncomeLabel"
)
@onready var assemble_button: Button = (
	$ArtifactPanel/MarginContainer/VBoxContainer/AssembleButton
)
@onready var close_button: TextureButton = $SiteCloseButton

var current_artifact_id := -1
var open_position: Vector2
var closed_position: Vector2
var close_open_position: Vector2
var close_closed_position: Vector2
var is_closing := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

	await get_tree().process_frame

	open_position = artifact_panel.position
	closed_position = open_position + Vector2(0, artifact_panel.size.y + 20)

	var close_offset := Vector2(
		artifact_panel.size.x - close_button.size.x * 0.55,
		-close_button.size.y * 0.35
	)

	close_open_position = open_position + close_offset
	close_closed_position = closed_position + close_offset

	artifact_panel.position = closed_position
	close_button.position = close_closed_position

	assemble_button.pressed.connect(_on_assemble_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)


func _process(_delta: float) -> void:
	if visible and current_artifact_id != -1:
		refresh()


func open_menu(artifact_id: int) -> void:
	current_artifact_id = artifact_id
	is_closing = false
	refresh()

	show()
	artifact_panel.position = closed_position
	close_button.position = close_closed_position
	dimmer.color.a = 0.0

	var tween := create_tween().set_parallel(true)

	tween.tween_property(
		artifact_panel,
		"position",
		open_position,
		0.35
	).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		close_button,
		"position",
		close_open_position,
		0.35
	).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

	tween.tween_property(dimmer, "color:a", 0.6, 0.2)


func close_menu() -> void:
	if is_closing:
		return

	is_closing = true

	var tween := create_tween().set_parallel(true)

	tween.tween_property(
		artifact_panel,
		"position",
		closed_position,
		0.3
	).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)

	tween.tween_property(
		close_button,
		"position",
		close_closed_position,
		0.3
	).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)

	tween.tween_property(dimmer, "color:a", 0.0, 0.2)

	tween.finished.connect(func() -> void:
		hide()
	)


func refresh() -> void:
	var artifact: Dictionary = GameState.get_artifact_data(current_artifact_id)
	var progress: Dictionary = GameState.get_artifact_progress(current_artifact_id)

	artifact_name_label.text = artifact["name"]

	fragment_progress_label.text = "Fragments found: %d / %d" % [
		progress["fragments_found"],
		artifact["total_fragments"]
	]

	var income: Dictionary = GameState.get_artifact_income_breakdown(artifact)

	fragment_income_label.text = (
		"Recovered fragments: $%.2f / sec" % income["fragments"]
	)

	assembled_income_label.text = (
		"Completed exhibit: $%.2f / sec" % income["assembled"]
	)

	assemble_button.text = "Assemble Artifact"
	assemble_button.disabled = (
		progress["is_assembled"]
		or progress["fragments_found"] < artifact["total_fragments"]
	)

	if progress["is_assembled"]:
		assemble_button.text = "Artifact Assembled"


func _on_assemble_button_pressed() -> void:
	var artifact: Dictionary = GameState.get_artifact_data(current_artifact_id)
	GameState.assemble_artifact(artifact)
	refresh()


func _on_close_button_pressed() -> void:
	close_menu()
