extends TextureButton

const HOVER_SCALE := 0.88
const ANIMATION_TIME := 0.1

var default_scale: Vector2
var hover_tween: Tween


func _ready() -> void:
	default_scale = scale
	pivot_offset = size / 2.0

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	if disabled:
		return

	animate_scale(default_scale * HOVER_SCALE)


func _on_mouse_exited() -> void:
	animate_scale(default_scale)


func animate_scale(target_scale: Vector2) -> void:
	if hover_tween and hover_tween.is_valid():
		hover_tween.kill()

	hover_tween = create_tween()
	hover_tween.set_trans(Tween.TRANS_QUAD)
	hover_tween.set_ease(Tween.EASE_OUT)
	hover_tween.tween_property(self, "scale", target_scale, ANIMATION_TIME)
