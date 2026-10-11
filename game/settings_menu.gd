extends Control

@onready var settings_panel: PanelContainer = $SettingsPanel
@onready var dimmer: ColorRect = $Dimmer
@onready var resolution_dropdown: OptionButton = $SettingsPanel/PanelMargin/SettingsBox/DisplaySection/DisplayControls/ResolutionDropdown
@onready var fullscreen_check_box: CheckBox = $SettingsPanel/PanelMargin/SettingsBox/DisplaySection/DisplayControls/FullscreenCheckbox
@onready var sfx_slider: HSlider = $SettingsPanel/PanelMargin/SettingsBox/SfxSection/SfxControls/SfxSlider
@onready var sfx_mute_check_box: CheckBox = $SettingsPanel/PanelMargin/SettingsBox/SfxSection/SfxControls/SfxMuteCheckbox
@onready var music_slider: HSlider = $SettingsPanel/PanelMargin/SettingsBox/MusicSection/MusicControls/MusicSlider
@onready var music_mute_check_box: CheckBox = $SettingsPanel/PanelMargin/SettingsBox/MusicSection/MusicControls/MusicMuteCheckBox

var open_position: Vector2
var closed_position: Vector2
var saved_resolution_index: int
var saved_fullscreen: bool
var saved_sfx_volume: float
var saved_sfx_muted: bool
var saved_music_volume: float
var saved_music_muted: bool

const RESOLUTIONS = [
	Vector2i(1920, 1080),
	Vector2i(1600, 900),
	Vector2i(1280, 720)
]

const SETTINGS_PATH := "user://museum_settings.json"

func _ready() -> void:
	open_position = settings_panel.position
	closed_position = open_position + Vector2(0, settings_panel.size.y + 20)
	load_settings()
	remember_current_settings()
	hide()

func open() -> void:
	show()
	settings_panel.position = closed_position
	dimmer.color.a = 0.0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(settings_panel, "position", open_position, 0.35)\
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(dimmer, "color:a", 0.3, 0.2)

func close() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(settings_panel, "position", closed_position, 0.3)\
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	tween.tween_property(dimmer, "color:a", 0.0, 0.2)
	tween.chain().tween_callback(hide)

func create_settings_data() -> Dictionary:
	return {
		"resolution_index" : resolution_dropdown.selected,
		"fullscreen" : fullscreen_check_box.button_pressed,
		"sfx_volume" : sfx_slider.value,
		"sfx_muted" : sfx_mute_check_box.button_pressed,
		"music_volume" : music_slider.value,
		"music_muted" : music_mute_check_box.button_pressed
	}

func save_settings() -> bool:
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	
	if file == null:
		push_error("Could not open the settings file.")
		return false
	
	var settings_json: String = JSON.stringify(create_settings_data())
	file.store_string(settings_json)
	file.close()
	
	return true

func load_settings() -> bool:
	if !FileAccess.file_exists(SETTINGS_PATH):
		return false
	
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	
	if file == null:
		push_error("Could not open the settings file.")
		return false
	
	var settings_json: String = file.get_as_text()
	file.close()
	
	var json := JSON.new()
	
	if json.parse(settings_json) != OK:
		push_error("Could not read the settings file.")
		return false
	
	var settings_data = json.data
	
	if !(settings_data is Dictionary):
		push_error("Settings data is not a dictionary.")
		return false
	
	resolution_dropdown.select(
		int(settings_data.get("resolution_index", resolution_dropdown.selected))
	)
	fullscreen_check_box.button_pressed = settings_data.get(
		"fullscreen", fullscreen_check_box.button_pressed
	)
	sfx_slider.value = float(settings_data.get("sfx_volume", sfx_slider.value))
	sfx_mute_check_box.button_pressed = settings_data.get(
		"sfx_muted", sfx_mute_check_box.button_pressed
	)
	music_slider.value = float(settings_data.get("music_volume", music_slider.value))
	music_mute_check_box.button_pressed = settings_data.get(
		"music_muted", music_mute_check_box.button_pressed
	)
	
	apply_display_settings()
	return true

func remember_current_settings() -> void:
	saved_resolution_index = resolution_dropdown.selected
	saved_fullscreen = fullscreen_check_box.button_pressed
	saved_sfx_volume = sfx_slider.value
	saved_sfx_muted = sfx_mute_check_box.button_pressed
	saved_music_volume = music_slider.value
	saved_music_muted = music_mute_check_box.button_pressed

func restore_saved_settings() -> void:
	resolution_dropdown.select(saved_resolution_index)
	fullscreen_check_box.button_pressed = saved_fullscreen
	sfx_slider.value = saved_sfx_volume
	sfx_mute_check_box.button_pressed = saved_sfx_muted
	music_slider.value = saved_music_volume
	music_mute_check_box.button_pressed = saved_music_muted

func apply_display_settings() -> void:
	if fullscreen_check_box.button_pressed:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED
		
		if resolution_dropdown.selected >= 0:
			get_window().size = RESOLUTIONS[resolution_dropdown.selected]

func _on_save_button_pressed() -> void:
	apply_display_settings()
	remember_current_settings()
	save_settings()
	print(save_settings())
	close()

func _on_cancel_button_pressed() -> void:
	restore_saved_settings()
	close()
