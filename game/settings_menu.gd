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

func _ready() -> void:
	open_position = settings_panel.position
	closed_position = open_position + Vector2(0, settings_panel.size.y + 20)
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
	close()

func _on_cancel_button_pressed() -> void:
	restore_saved_settings()
	close()
