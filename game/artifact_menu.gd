extends Control

@onready var artifact_panel: PanelContainer = $ArtifactPanel
@onready var dimmer: ColorRect = $Dimmer
@onready var artifact_name_label: Label = $ArtifactPanel/MarginContainer/VBoxContainer/ArtifactNameLabel
@onready var fragment_progress_label: Label = $ArtifactPanel/MarginContainer/VBoxContainer/FragmentProgressLabel
@onready var clean_progress_label: Label = $ArtifactPanel/MarginContainer/VBoxContainer/CleaProgressLabel
@onready var clean_button: Button = $ArtifactPanel/MarginContainer/VBoxContainer/CleanButton
@onready var assemble_button: Button = $ArtifactPanel/MarginContainer/VBoxContainer/AssembleButton
@onready var close_button: Button = $ArtifactPanel/MarginContainer/VBoxContainer/CloseButton

var current_artifact_id := -1
var open_position: Vector2
var closed_position: Vector2
var is_closing := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

	await get_tree().process_frame

	open_position = artifact_panel.position
	closed_position = open_position + Vector2(0, artifact_panel.size.y + 20)
	artifact_panel.position = closed_position

	clean_button.pressed.connect(_on_clean_button_pressed)
	assemble_button.pressed.connect(_on_assemble_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)


func open_menu(artifact_id: int) -> void:
	current_artifact_id = artifact_id
	is_closing = false
	refresh()

	show()
	artifact_panel.position = closed_position
	dimmer.color.a = 0.0

	var tween := create_tween().set_parallel(true)
	tween.tween_property(artifact_panel, "position", open_position, 0.35) \
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(dimmer, "color:a", 0.6, 0.2)


func close_menu() -> void:
	if is_closing:
		return

	is_closing = true

	var tween := create_tween().set_parallel(true)
	tween.tween_property(artifact_panel, "position", closed_position, 0.3) \
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
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
	clean_progress_label.text = "Fragments cleaned: %d / %d" % [
		progress["fragments_cleaned"],
		artifact["total_fragments"]
	]

	clean_button.text = "Clean Fragment"
	assemble_button.text = "Assemble Artifact"
	close_button.text = "Close"

	clean_button.disabled = (
		progress["is_assembled"]
		or progress["fragments_cleaned"] >= progress["fragments_found"]
	)

	assemble_button.disabled = (
		progress["is_assembled"]
		or progress["fragments_cleaned"] < artifact["total_fragments"]
	)

	if progress["is_assembled"]:
		assemble_button.text = "Artifact Assembled"


func _on_clean_button_pressed() -> void:
	var artifact: Dictionary = GameState.get_artifact_data(current_artifact_id)
	GameState.clean_fragment(artifact)
	refresh()


func _on_assemble_button_pressed() -> void:
	var artifact: Dictionary = GameState.get_artifact_data(current_artifact_id)
	GameState.assemble_artifact(artifact)
	refresh()


func _on_close_button_pressed() -> void:
	close_menu()
