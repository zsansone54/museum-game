extends CanvasLayer

const SLIDE_TIME := 0.22

var overlay: ColorRect
var is_transitioning := false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS

	overlay = ColorRect.new()
	overlay.color = Color("#2B1F12")
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	add_child(overlay)

	await get_tree().process_frame

	var screen_width := get_viewport().get_visible_rect().size.x
	overlay.position = Vector2(screen_width, 0)


func change_scene(scene_path: String) -> void:
	if is_transitioning:
		return

	is_transitioning = true

	var screen_width := get_viewport().get_visible_rect().size.x

	# Start just beyond the right edge of the screen.
	overlay.position = Vector2(screen_width, 0)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)

	# Slide across from right to left, covering the current scene.
	tween.tween_property(
		overlay,
		"position",
		Vector2.ZERO,
		SLIDE_TIME
	)

	# Change scenes while the screen is fully covered.
	tween.tween_callback(func() -> void:
		get_tree().change_scene_to_file(scene_path)
	)

	# Continue moving left to reveal the new scene.
	tween.tween_property(
		overlay,
		"position",
		Vector2(-screen_width, 0),
		SLIDE_TIME
	)

	tween.tween_callback(func() -> void:
		overlay.position = Vector2(screen_width, 0)
		is_transitioning = false
	)
