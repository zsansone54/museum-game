extends Node

const MUSIC_BUS: StringName = &"Music"
const SFX_BUS: StringName = &"SFX"

const DEFAULT_MUSIC_VOLUME := 60.0
const DEFAULT_SFX_VOLUME := 75.0

@onready var music_player: AudioStreamPlayer = $"."


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	set_music_volume(DEFAULT_MUSIC_VOLUME)
	set_music_muted(false)
	set_sfx_volume(DEFAULT_SFX_VOLUME)
	set_sfx_muted(false)

	if music_player.stream == null:
		push_warning("MusicPlayer does not have a music stream assigned.")
		return

	music_player.finished.connect(_on_music_finished)
	music_player.play()


func _on_music_finished() -> void:
	music_player.play()


func set_music_volume(volume_percent: float) -> void:
	_set_bus_volume(MUSIC_BUS, volume_percent)


func set_sfx_volume(volume_percent: float) -> void:
	_set_bus_volume(SFX_BUS, volume_percent)


func set_music_muted(is_muted: bool) -> void:
	_set_bus_muted(MUSIC_BUS, is_muted)


func set_sfx_muted(is_muted: bool) -> void:
	_set_bus_muted(SFX_BUS, is_muted)


func _set_bus_volume(bus_name: StringName, volume_percent: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)

	if bus_index == -1:
		push_warning("Audio bus not found: " + str(bus_name))
		return

	var linear_volume := clampf(volume_percent / 100.0, 0.001, 1.0)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_volume))


func _set_bus_muted(bus_name: StringName, is_muted: bool) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)

	if bus_index == -1:
		push_warning("Audio bus not found: " + str(bus_name))
		return

	AudioServer.set_bus_mute(bus_index, is_muted)
