extends Control

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Exhibit1.tscn")

func _on_settings_button_pressed() -> void:
	$SettingsMenu.open()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
