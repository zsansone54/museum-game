extends Node

var game_data : Dictionary
var funds : float
var starting_rep : int
var tools : Array[Dictionary]
var areas : Array[Dictionary]





func _ready() -> void:
	game_data = GameData.data()
	funds = game_data["initial values"]["starting_funds"]
	starting_rep = game_data["initial values"]["starting_rep"]
	tools = game_data["tools"]
	areas = game_data["areas"]

#func _process(delta: float) -> void:
	#for zone in zones:
		#zone.piece_bank += zone.generator_rate * delta
#
		#var target = _first_open_artifact(zone)
		#while target != null and zone.piece_bank >= 1.0:
			#zone.piece_bank -= 1.0
			#target.filled_pieces += 1
			#if target.filled_pieces >= target.total_pieces:
				#target = _first_open_artifact(zone)
#
		#for art in zone.artifacts:
			#if art.on_display:
				#money += art.income * delta
#
#func _first_open_artifact(zone: Dictionary):
	#for art in zone.artifacts:
		#if art.filled_pieces < art.total_pieces:
			#return art
	#return null
#
#func clean_piece(zone_index: int, art_index: int) -> void:
	#var art = zones[zone_index].artifacts[art_index]
	#if art.cleaned_pieces >= art.filled_pieces:
		#return
	#art.cleaned_pieces += 1
#
#func buy_generator(zone_index: int) -> void:
	#var zone = zones[zone_index]
	#if money < zone.generator_cost:
		#return
	#money -= zone.generator_cost
	#zone.generator_rate += 1.0
#
#func finish_artifact(zone_index: int, art_index: int) -> void:
	#var art = zones[zone_index].artifacts[art_index]
	#if art.cleaned_pieces < art.total_pieces:
		#return
	#art.finished = true
	#rep += 1
#
#func set_display_artifact(zone_index: int, art_index: int, displayed: bool) -> void:
	#var art = zones[zone_index].artifacts[art_index]
	#if displayed and not art.finished:
		#return
	#art.on_display = displayed
