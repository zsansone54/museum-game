extends Node

var game_data : Dictionary
var funds : float
var rep : int
var tools : Array
var areas : Array
var artifact_progress : Array[Dictionary] = []
var active_area_id : int = -1
var active_artifact_id : int = -1
var time_remaining : float = -1





func _ready() -> void:
	game_data = GameData.data()
	funds = game_data["initial values"]["starting_funds"]
	rep = game_data["initial values"]["starting_rep"]
	tools = game_data["tools"]
	areas = game_data["areas"]
	
	set_artifact_progress()
	print(artifact_progress[0])
	add_fragment(get_artifact_progres(0))
	clean_fragment(get_artifact_progres(0))
	add_fragment(get_artifact_progres(0))
	clean_fragment(get_artifact_progres(0))
	add_fragment(get_artifact_progres(0))
	clean_fragment(get_artifact_progres(0))
	add_fragment(get_artifact_progres(0))
	clean_fragment(get_artifact_progres(0))
	assemble_artifact(get_artifact_progres(0))
	print(artifact_progress[0])
	print(rep)
	print(get_artifact_data(0))
	

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

func set_artifact_progress() -> void:
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

func get_artifact_progres(artifact_id: int) -> Dictionary:
	var artifact = {}
	for progress_entry in artifact_progress:
		if progress_entry["artifact_id"] == artifact_id:
			artifact = progress_entry
			
	return artifact

func get_artifact_data(artifact_id: int) -> Dictionary:
	var data = {}
	for area in areas: 
		for artifact in area["artifacts"]:
			if artifact["id"] == artifact_id:
				data = artifact
	return data

#Increments found fragments by 1 for a given artifact id
func add_fragment(artifact: Dictionary) -> void:
	if artifact["fragments_found"] < artifact["total_fragments"]:
		artifact["fragments_found"] += 1
	return

#Increments cleaned fragments by 1 for a given artifact id
#if there is an uncleaned found fragment
func clean_fragment(artifact: Dictionary) -> void:
	if artifact["fragments_found"] > 0 \
	&& artifact["fragments_found"] > artifact["fragments_cleaned"]:
		artifact["fragments_cleaned"] += 1
	return


func assemble_artifact(artifact: Dictionary) -> void:
	if !artifact["is_assembled"] \
	&& artifact["total_fragments"] == artifact["fragments_cleaned"]:
		artifact["is_assembled"] = true
		rep += artifact["rep_reward"]
	return

func select_excavation_target(area_id, artifact_id) -> void:
	
