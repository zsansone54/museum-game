extends Node

var game_data : Dictionary
var funds : float
var rep : int
var tools : Array
var areas : Array
var artifact_progress : Array[Dictionary] = []





func _ready() -> void:
	game_data = GameData.data()
	funds = game_data["initial values"]["starting_funds"]
	rep = game_data["initial values"]["starting_rep"]
	tools = game_data["tools"]
	areas = game_data["areas"]
	
	for area in areas:
		for artifact in area["artifacts"]:
			var progress_entry : Dictionary = {
				"artifact_id" : artifact["id"],
				"total_fragments" : artifact["total_fragments"],
				"fragments_found" : 0,
				"fragments_cleaned" : 0,
				"is_assembled" : false,
				"rep_reward" : artifact["rep_reward"]
			}
			
			artifact_progress.append(progress_entry)
			
			
	print(rep)
	print(artifact_progress[0])
	add_fragment(0)
	add_fragment(0)
	add_fragment(0)
	add_fragment(0)
	assemble_artifact(0)
	print(artifact_progress[0])
	clean_fragment(0)
	clean_fragment(0)
	clean_fragment(0)
	clean_fragment(0)
	print(artifact_progress[0])
	assemble_artifact(0)
	print(artifact_progress[0])
	print(rep)
	

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

#Increments found fragments by 1 for a given artifact id
func add_fragment(artifact_id: int) -> void:
	for progress_entry in artifact_progress:
		if progress_entry["artifact_id"] == artifact_id:
			if progress_entry["fragments_found"] < progress_entry["total_fragments"]:
				progress_entry["fragments_found"] += 1
			return

#Increments cleaned fragments by 1 for a given artifact id
#if there is an uncleaned found fragment
func clean_fragment(artifact_id: int) -> void:
	for progress_entry in artifact_progress:
		if progress_entry["artifact_id"] == artifact_id:
			if progress_entry["fragments_found"] > 0 \
			&& progress_entry["fragments_found"] > progress_entry["fragments_cleaned"]:
				progress_entry["fragments_cleaned"] += 1
			return

func assemble_artifact(artifact_id: int) -> void:
	for progress_entry in artifact_progress:
		if progress_entry["artifact_id"] == artifact_id:
			if !progress_entry["is_assembled"] \
			&& progress_entry["total_fragments"] == progress_entry["fragments_cleaned"]:
				progress_entry["is_assembled"] = true
				rep += progress_entry["rep_reward"]

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
