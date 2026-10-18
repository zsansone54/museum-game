extends Control

@onready var artifact_name_label: Label = $ArtifactPanel/MarginContainer/VBoxContainer/ArtifactNameLabel
@onready var fragment_progress_label: Label = $ArtifactPanel/MarginContainer/VBoxContainer/FragmentProgressLabel
@onready var clean_progress_label: Label = $ArtifactPanel/MarginContainer/VBoxContainer/CleaProgressLabel
@onready var clean_button: Button = $ArtifactPanel/MarginContainer/VBoxContainer/CleanButton
@onready var assemble_button: Button = $ArtifactPanel/MarginContainer/VBoxContainer/AssembleButton
@onready var close_button: Button = $ArtifactPanel/MarginContainer/VBoxContainer/CloseButton

var current_artifact_id := -1


func _ready() -> void:
	hide()

	clean_button.pressed.connect(_on_clean_button_pressed)
	assemble_button.pressed.connect(_on_assemble_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)


func open_menu(artifact_id: int) -> void:
	current_artifact_id = artifact_id
	refresh()
	show()


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
	hide()
