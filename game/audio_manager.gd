extends Node

const MUSIC_BUS: StringName = &"Music"
const SFX_BUS: StringName = &"SFX"

const DEFAULT_MUSIC_VOLUME := 60.0
const DEFAULT_SFX_VOLUME := 75.0
const MUSIC_LOOP_FADE_TIME := 0.6

const BUTTON_CLICK_SOUND = preload(
	"res://assets/audio/sfx/kenney_interface-sounds/Audio/click_005.ogg"
)

const PANEL_OPEN_SOUND = preload(
	"res://assets/audio/sfx/kenney_interface-sounds/Audio/maximize_008.ogg"
)

const PANEL_CLOSE_SOUND = preload(
	"res://assets/audio/sfx/kenney_interface-sounds/Audio/minimize_008.ogg"
)

const EXCAVATION_SUCCESS_SOUND = preload(
	"res://assets/audio/sfx/kenney_interface-sounds/Audio/confirmation_002.ogg"
)

const EXCAVATION_FAILURE_SOUND = preload(
	"res://assets/audio/sfx/kenney_interface-sounds/Audio/error_003.ogg"
)

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var ui_player: AudioStreamPlayer = $UiPlayer
@onready var panel_player: AudioStreamPlayer = $PanelPlayer
@onready var event_player: AudioStreamPlayer = $EventPlayer
@onready var purchase_player: AudioStreamPlayer = $PurchasePlayer
@onready var transition_player: AudioStreamPlayer = $TransitionPlayer

var music_loop_timer: SceneTreeTimer
var music_fade_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	set_music_volume(DEFAULT_MUSIC_VOLUME)
	set_music_muted(false)
	set_sfx_volume(DEFAULT_SFX_VOLUME)
	set_sfx_muted(false)

	start_music()

	get_tree().node_added.connect(_on_node_added)
	call_deferred("_connect_existing_buttons")

	GameState.excavation_succeeded.connect(_on_excavation_succeeded)
	GameState.excavation_failed.connect(_on_excavation_failed)


func start_music() -> void:
	if music_player.stream == null:
		push_warning("MusicPlayer does not have a music stream assigned.")
		return

	if !music_player.finished.is_connected(_on_music_finished):
		music_player.finished.connect(_on_music_finished)

	music_player.volume_db = 0.0
	music_player.play()
	schedule_music_loop_fade()


func schedule_music_loop_fade() -> void:
	if music_player.stream == null:
		return

	var stream_length := music_player.stream.get_length()
	var fade_start_time := maxf(0.1, stream_length - MUSIC_LOOP_FADE_TIME)

	music_loop_timer = get_tree().create_timer(fade_start_time)
	music_loop_timer.timeout.connect(fade_music_out)


func fade_music_out() -> void:
	if music_fade_tween and music_fade_tween.is_valid():
		music_fade_tween.kill()

	music_fade_tween = create_tween()
	music_fade_tween.tween_property(
		music_player,
		"volume_db",
		-60.0,
		MUSIC_LOOP_FADE_TIME
	)


func _on_music_finished() -> void:
	music_player.volume_db = -60.0
	music_player.play()

	if music_fade_tween and music_fade_tween.is_valid():
		music_fade_tween.kill()

	music_fade_tween = create_tween()
	music_fade_tween.tween_property(
		music_player,
		"volume_db",
		0.0,
		MUSIC_LOOP_FADE_TIME
	)

	schedule_music_loop_fade()


func _connect_existing_buttons() -> void:
	_connect_buttons_in_node(get_tree().root)


func _connect_buttons_in_node(node: Node) -> void:
	if node is BaseButton:
		_connect_button(node)

	for child in node.get_children():
		_connect_buttons_in_node(child)


func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		call_deferred("_connect_button", node)


func _connect_button(button: BaseButton) -> void:
	if !is_instance_valid(button):
		return

	if !button.pressed.is_connected(play_button_click):
		button.pressed.connect(play_button_click)


func _on_excavation_succeeded(
	_artifact_name: String,
	_fragments_found: int,
	_total_fragments: int
) -> void:
	play_excavation_success()


func _on_excavation_failed(_reward: float) -> void:
	play_excavation_failure()


func play_button_click() -> void:
	_play_sound(ui_player, BUTTON_CLICK_SOUND)


func play_panel_open() -> void:
	_play_sound(panel_player, PANEL_OPEN_SOUND)


func play_panel_close() -> void:
	_play_sound(panel_player, PANEL_CLOSE_SOUND)


func play_excavation_success() -> void:
	_play_sound(event_player, EXCAVATION_SUCCESS_SOUND)


func play_excavation_failure() -> void:
	_play_sound(event_player, EXCAVATION_FAILURE_SOUND)


func play_purchase() -> void:
	purchase_player.play()


func play_scene_transition() -> void:
	transition_player.play()


func _play_sound(player: AudioStreamPlayer, sound: AudioStream) -> void:
	player.stream = sound
	player.play()


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
