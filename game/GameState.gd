extends Node

var game_data : Dictionary
var funds : float
var rep : int
var tools : Array
var areas : Array
var artifact_progress : Array[Dictionary] = []
var active_area_id : int = -1
var active_artifact_id : int = -1
var excavation_countdown : float = -1
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	game_data = GameData.data()
	funds = game_data["initial values"]["starting_funds"]
	rep = game_data["initial values"]["starting_rep"]
	tools = game_data["tools"]
	areas = game_data["areas"]
	set_artifact_progress()
	rng.randomize()
	
	var area0 = get_aera_data(0)
	var area1 = get_aera_data(1)
	print(is_area_unlocked(area0))
	print(is_area_unlocked(area1))
	rep = 35
	print(is_area_unlocked(area1))

func _process(delta : float) -> void:
	if excavation_countdown != -1:
		excavation_countdown -= delta
		if excavation_countdown <= 0:
			excavation_attempt_result()
			
	update_donation_income(delta)

func update_donation_income(delta : float) -> void:
	var add : float = 0
	for area in areas:
		for artifact in area["artifacts"]:
			var progress = get_artifact_progress(artifact["id"])
			if !progress["is_assembled"]:
				add += (progress["fragments_found"] - progress["fragments_cleaned"]) \
				* artifact["uncleaned_fragment_funds_ps"] * delta
				add += progress["fragments_cleaned"] * \
				artifact["cleaned_fragment_funds_ps"] * delta
			else:
				add += artifact["completed_funds"] * delta
	funds += add

func set_artifact_progress() -> void:
	for area in areas:
		for artifact in area["artifacts"]:
			var progress_entry : Dictionary = {
				"artifact_id" : artifact["id"],
				"fragments_found" : 0,
				"fragments_cleaned" : 0,
				"is_assembled" : false,
			}
			artifact_progress.append(progress_entry)


func get_artifact_progress(artifact_id : int) -> Dictionary:
	var artifact = {}
	for progress_entry in artifact_progress:
		if progress_entry["artifact_id"] == artifact_id:
			artifact = progress_entry
	return artifact

func get_artifact_data(artifact_id : int) -> Dictionary:
	var data = {}
	for area in areas: 
		for artifact in area["artifacts"]:
			if artifact["id"] == artifact_id:
				data = artifact
	return data

func get_aera_data(area_id : int) -> Dictionary:
	var data ={}
	for area in areas:
		if area["id"] == area_id:
			data = area
	return data

#Increments found fragments by 1 for a given artifact id
func add_fragment(artifact : Dictionary) -> void:
	if artifact["fragments_found"] < artifact["total_fragments"]:
		artifact["fragments_found"] += 1
	return

#Increments cleaned fragments by 1 for a given artifact id
#if there is an uncleaned found fragment
func clean_fragment(artifact : Dictionary) -> void:
	var progress = get_artifact_progress(artifact["id"])
	if progress["fragments_found"] > 0 \
	&& progress["fragments_found"] > progress["fragments_cleaned"]:
		progress["fragments_cleaned"] += 1
	return

func assemble_artifact(artifact : Dictionary) -> void:
	var progress = get_artifact_progress(artifact["id"])
	if !progress["is_assembled"] \
	&& artifact["total_fragments"] <= progress["fragments_cleaned"]:
		progress["is_assembled"] = true
		rep += artifact["rep_reward"]
	return

func select_excavation_target(artifact : Dictionary) -> void:
	var progress = get_artifact_progress(artifact["id"])
	if progress["fragments_found"] >= artifact["total_fragments"] \
	|| progress["is_assembled"] || !has_required_tools(artifact) \
	|| !is_area_unlocked(get_aera_data(artifact["id"])):
		print("no no")
		return
	active_area_id = artifact["area"]
	active_artifact_id = artifact["id"]
	excavation_countdown = artifact["attempt_duration"]

func excavation_attempt_result() -> void:
	var active_artifact = get_artifact_data(active_artifact_id)
	if active_artifact_id != -1 \
	&& has_required_tools(active_artifact):
		var rand = rng.randi_range(1, 100)
		if rand > (100 - active_artifact["success_chance"]):
			add_fragment(active_artifact)
			if active_artifact["fragments_found"] \
			>= active_artifact["total_fragments"]:
				active_area_id = -1
				active_artifact_id = -1
				excavation_countdown = -1
				return
		else:
			funds += active_artifact["failure_reward"]
		excavation_countdown = active_artifact["attempt_duration"]

func buy_tool(tool_id : int) -> void:
	if tool_id >= 0 && tool_id < tools.size() \
	&& !tools[tool_id]["is_purchased"] \
	&& rep >= tools[tool_id]["unlock_required_rep"] \
	&& funds >= tools[tool_id]["cost"]:
		funds -= tools[tool_id]["cost"]
		tools[tool_id]["is_purchased"] = true

func has_required_tools(artifact : Dictionary) -> bool:
	var tools_owned : bool = true
	for tool : int in artifact["required_tool"]:
		if !tools[tool]["is_purchased"]:
			tools_owned = false
	return tools_owned

func is_area_unlocked(area : Dictionary) -> bool:
	var area_unlocked = false
	if area["unlock_required_rep"] <= rep:
		area_unlocked = true
	return area_unlocked
	
