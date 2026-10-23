extends Control

@onready var version_label: Label = $VersionLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	version_label.text = "v%s" % GameData.data().get("game_version", "0.0.0")


func _on_start_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Exhibit1.tscn")


func _on_settings_button_pressed() -> void:
	$SettingsMenu.open()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
