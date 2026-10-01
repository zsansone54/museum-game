extends Control





#@onready var piece_label: Label = $PieceLabel
#@onready var clean_button: Button = $CleanButton
#@onready var buy_generator_button: Button = $BuyGeneratorButton
#@onready var finish_button: Button = $FinishButton
#@onready var display_dropdown: OptionButton = $DisplayDropdown
#
#func _ready() -> void:
	#clean_button.pressed.connect(_on_clean_pressed)
	#buy_generator_button.pressed.connect(_on_buy_generator_pressed)
	#finish_button.pressed.connect(_on_finish_pressed)
	#display_dropdown.item_selected.connect(_on_display_selected)
#
#func _process(_delta: float) -> void:
	#var zone = GameManager.zones[0]
	#var art = zone.artifacts[0]
	#
	#if art.finished and display_dropdown.item_count == 0:
		#display_dropdown.add_item("Empty (+0)")
		#display_dropdown.add_item("%s (+%.0f)" % [art.name, art.income])
		#
	#var current_income: float = art.income if art.on_display else 0.0
	#
	#piece_label.text = "%s pieces: %d / %d (cleaned: %d)   $%.1f   Rep: %d   Rate: %.0f   Income/sec: %.1f" % [
		#art.name, art.filled_pieces, art.total_pieces, art.cleaned_pieces,
		#GameManager.money, GameManager.rep, GameManager.zones[0].generator_rate, current_income
	#]
	#
	#buy_generator_button.text = "Buy Generator ($%.0f)" % zone.generator_cost
	#clean_button.text = "clean (%d / %d cleaned)" % [art.cleaned_pieces, art.filled_pieces]
	#finish_button.text = "Finish Artifact"
	#finish_button.visible = (art.cleaned_pieces >= art.total_pieces) and not art.finished
	#display_dropdown.visible = art.finished
#
#func _on_clean_pressed() -> void:
	#GameManager.clean_piece(0, 0)
#
#func _on_buy_generator_pressed() -> void:
	#GameManager.buy_generator(0)
#
#func _on_finish_pressed() -> void:
	#GameManager.finish_artifact(0, 0)
#
#func _on_display_selected(index: int) -> void:
	#GameManager.set_display_artifact(0, 0, index == 1)
