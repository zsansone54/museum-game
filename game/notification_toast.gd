extends Control

@onready var message_label: Label = $MessageLabel

var notification_tween: Tween


func _ready() -> void:
	GameState.excavation_started.connect(_on_excavation_started)
	GameState.excavation_succeeded.connect(_on_excavation_succeeded)
	GameState.excavation_failed.connect(_on_excavation_failed)
	GameState.artifact_assembled.connect(_on_artifact_assembled)

	message_label.modulate.a = 0.0


func show_notification(message: String, color: Color) -> void:
	if notification_tween and notification_tween.is_valid():
		notification_tween.kill()

	message_label.text = message
	message_label.modulate = Color(color.r, color.g, color.b, 0.0)

	notification_tween = create_tween()
	notification_tween.tween_property(message_label, "modulate:a", 1.0, 0.15)
	notification_tween.tween_interval(2.0)
	notification_tween.tween_property(message_label, "modulate:a", 0.0, 0.35)


func _on_excavation_started(artifact_name: String) -> void:
	show_notification(
		"Now excavating: " + artifact_name,
		Color("#dce6ee")
	)


func _on_excavation_succeeded(
	artifact_name: String,
	fragments_found: int,
	total_fragments: int
) -> void:
	show_notification(
		"Fragment recovered! %s: %d / %d" % [
			artifact_name,
			fragments_found,
			total_fragments
		],
		Color("#8fd16a")
	)


func _on_excavation_failed(reward: float) -> void:
	show_notification(
		"Excavation failed — gained $%d" % int(reward),
		Color("#e6b85c")
	)


func _on_artifact_assembled(artifact_name: String, rep_reward: int) -> void:
	show_notification(
		"%s assembled! +%d Reputation" % [artifact_name, rep_reward],
		Color("#72c9e8")
	)
