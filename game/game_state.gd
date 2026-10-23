extends Node

signal excavation_started(artifact_name: String)
signal excavation_succeeded(
	artifact_name: String,
	fragments_found: int,
	total_fragments: int
)
signal excavation_failed(reward: float)
signal artifact_assembled(artifact_name: String, rep_reward: int)
signal game_completed

var game_data: Dictionary
var funds: float
var rep: int
var tools: Array
var areas: Array

var artifact_progress: Array[Dictionary] = []

var active_area_id: int = -1
var active_artifact_id: int = -1
var excavation_countdown: float = -1.0

var area_speed_upgrades: Array[int] = [0, 0]
var area_chance_upgrades: Array[int] = [0, 0]

var rng := RandomNumberGenerator.new()

var tutorial_completed := false

const SAVE_PATH := "user://museum_game_save.json"



func _ready() -> void:
	game_data = GameData.data()

	funds = game_data["initial values"]["starting_funds"]
	rep = game_data["initial values"]["starting_rep"]
	tools = game_data["tools"]
	areas = game_data["areas"]

	set_artifact_progress()
	rng.randomize()
	
	if has_save_file():
		load_game()
		
	rep = 0



func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()


func _process(delta: float) -> void:
	if excavation_countdown != -1.0:
		excavation_countdown -= delta

		if excavation_countdown <= 0.0:
			excavation_attempt_result()

	update_donation_income(delta)


func get_artifact_income_breakdown(artifact: Dictionary) -> Dictionary:
	var progress: Dictionary = get_artifact_progress(artifact["id"])
	var fragment_income: float = 0.0
	var assembled_income: float = 0.0

	if progress["is_assembled"]:
		assembled_income = artifact["completed_funds"]
	else:
		fragment_income = (
			progress["fragments_found"]
			* artifact["fragment_funds_ps"]
		)

	return {
		"fragments": fragment_income,
		"assembled": assembled_income
	}


func get_total_donation_income_per_second() -> float:
	var total_income: float = 0.0

	for area in areas:
		for artifact in area["artifacts"]:
			var income: Dictionary = get_artifact_income_breakdown(artifact)
			total_income += income["fragments"] + income["assembled"]

	return total_income


func update_donation_income(delta: float) -> void:
	funds += get_total_donation_income_per_second() * delta


func set_artifact_progress() -> void:
	for area in areas:
		for artifact in area["artifacts"]:
			artifact_progress.append({
				"artifact_id": artifact["id"],
				"fragments_found": 0,
				"is_assembled": false
			})


func get_artifact_progress(artifact_id: int) -> Dictionary:
	for progress_entry in artifact_progress:
		if progress_entry["artifact_id"] == artifact_id:
			return progress_entry

	return {}


func get_artifact_data(artifact_id: int) -> Dictionary:
	for area in areas:
		for artifact in area["artifacts"]:
			if artifact["id"] == artifact_id:
				return artifact

	return {}


func get_area_data(area_id: int) -> Dictionary:
	for area in areas:
		if area["id"] == area_id:
			return area

	return {}


func get_effective_attempt_duration(artifact: Dictionary) -> float:
	var area: Dictionary = get_area_data(artifact["area"])
	var upgrade: Dictionary = area["speed_upgrade"]
	var level: int = area_speed_upgrades[area["id"]]

	var reduction_per_level: float = round(
		artifact["attempt_duration"]
		* upgrade["time_reduction_percent"]
	)

	return max(
		upgrade["minimum_duration"],
		artifact["attempt_duration"] - reduction_per_level * level
	)


func get_effective_success_chance(artifact: Dictionary) -> float:
	var area: Dictionary = get_area_data(artifact["area"])

	return min(
		90.0,
		artifact["success_chance"]
		+ area["chance_upgrade"]["chance_inc_per_level"]
		* area_chance_upgrades[area["id"]]
	)


func get_upgrade_cost(upgrade: Dictionary, current_level: int) -> float:
	return (
		upgrade["base_cost"]
		+ upgrade["cost_increase_per_level"] * current_level
	)


func add_fragment(artifact: Dictionary) -> void:
	var progress: Dictionary = get_artifact_progress(artifact["id"])

	if progress["fragments_found"] < artifact["total_fragments"]:
		progress["fragments_found"] += 1


func assemble_artifact(artifact: Dictionary) -> void:
	var progress: Dictionary = get_artifact_progress(artifact["id"])

	if (
		!progress["is_assembled"]
		&& progress["fragments_found"] >= artifact["total_fragments"]
	):
		progress["is_assembled"] = true
		rep += artifact["rep_reward"]

		artifact_assembled.emit(
			artifact["name"],
			artifact["rep_reward"]
		)

		save_game()

		if check_win_condition():
			game_completed.emit()


func select_excavation_target(artifact: Dictionary) -> void:
	var progress: Dictionary = get_artifact_progress(artifact["id"])

	if (
		progress["fragments_found"] >= artifact["total_fragments"]
		|| progress["is_assembled"]
		|| !has_required_tools(artifact)
		|| !is_area_unlocked(get_area_data(artifact["area"]))
	):
		return

	active_area_id = artifact["area"]
	active_artifact_id = artifact["id"]
	excavation_countdown = get_effective_attempt_duration(artifact)

	save_game()
	excavation_started.emit(artifact["name"])


func excavation_attempt_result() -> void:
	if active_artifact_id == -1:
		return

	var active_artifact: Dictionary = get_artifact_data(active_artifact_id)
	var active_artifact_progress: Dictionary = get_artifact_progress(
		active_artifact_id
	)

	if !has_required_tools(active_artifact):
		active_area_id = -1
		active_artifact_id = -1
		excavation_countdown = -1.0
		return

	var roll: int = rng.randi_range(1, 100)
	var success_chance: float = get_effective_success_chance(active_artifact)

	if roll <= success_chance:
		add_fragment(active_artifact)

		excavation_succeeded.emit(
			active_artifact["name"],
			active_artifact_progress["fragments_found"],
			active_artifact["total_fragments"]
		)

		if (
			active_artifact_progress["fragments_found"]
			>= active_artifact["total_fragments"]
		):
			active_area_id = -1
			active_artifact_id = -1
			excavation_countdown = -1.0
			save_game()
			return
	else:
		funds += active_artifact["failure_reward"]
		excavation_failed.emit(active_artifact["failure_reward"])

	excavation_countdown = get_effective_attempt_duration(active_artifact)
	save_game()


func buy_tool(tool_id: int) -> void:
	if (
		tool_id >= 0
		&& tool_id < tools.size()
		&& !tools[tool_id]["is_purchased"]
		&& rep >= tools[tool_id]["unlock_required_rep"]
		&& funds >= tools[tool_id]["cost"]
	):
		funds -= tools[tool_id]["cost"]
		tools[tool_id]["is_purchased"] = true
		save_game()


func buy_speed_upgrade(area: Dictionary) -> void:
	var upgrade: Dictionary = area["speed_upgrade"]
	var upgrade_count: int = area_speed_upgrades[area["id"]]
	var cost: float = get_upgrade_cost(upgrade, upgrade_count)

	if upgrade_count >= upgrade["max_level"] || funds < cost:
		return

	funds -= cost
	area_speed_upgrades[area["id"]] += 1

	if active_area_id == area["id"] && active_artifact_id != -1:
		var active_artifact: Dictionary = get_artifact_data(active_artifact_id)

		excavation_countdown = min(
			excavation_countdown,
			get_effective_attempt_duration(active_artifact)
		)

	save_game()


func buy_chance_upgrade(area: Dictionary) -> void:
	var upgrade: Dictionary = area["chance_upgrade"]
	var upgrade_count: int = area_chance_upgrades[area["id"]]
	var cost: float = get_upgrade_cost(upgrade, upgrade_count)

	if upgrade_count >= upgrade["max_level"] || funds < cost:
		return

	funds -= cost
	area_chance_upgrades[area["id"]] += 1
	save_game()


func has_required_tools(artifact: Dictionary) -> bool:
	for tool_id: int in artifact["required_tool"]:
		if !tools[tool_id]["is_purchased"]:
			return false

	return true


func is_area_unlocked(area: Dictionary) -> bool:
	return rep >= area["unlock_required_rep"]


func check_win_condition() -> bool:
	for progress in artifact_progress:
		if !progress["is_assembled"]:
			return false

	return true


func create_save_data() -> Dictionary:
	var purchased_tools: Array[bool] = []

	for tool in tools:
		purchased_tools.append(tool["is_purchased"])

	return {
		"save_version": 1,
		"funds": funds,
		"rep": rep,
		"artifact_progress": artifact_progress,
		"purchased_tools": purchased_tools,
		"speed_upgrades": area_speed_upgrades,
		"chance_upgrades": area_chance_upgrades,
		"active_area_id": active_area_id,
		"active_artifact_id": active_artifact_id,
		"excavation_countdown": excavation_countdown,
		"tutorial_completed": tutorial_completed
	}


func save_game() -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		push_error("Could not open the save file.")
		return false

	file.store_string(JSON.stringify(create_save_data()))
	file.close()

	return true


func load_game() -> bool:
	if !has_save_file():
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		push_error("Could not open the save file.")
		return false

	var save_json: String = file.get_as_text()
	file.close()

	var json := JSON.new()

	if json.parse(save_json) != OK:
		push_error("Could not read the save file.")
		return false

	var save_data = json.data

	if !(save_data is Dictionary):
		push_error("Save data is not a dictionary.")
		return false

	funds = float(save_data.get("funds", funds))
	rep = int(save_data.get("rep", rep))

	var saved_progress = save_data.get("artifact_progress", [])

	if saved_progress is Array:
		artifact_progress.clear()

		for entry in saved_progress:
			if entry is Dictionary:
				artifact_progress.append(entry)

	var saved_purchased_tools = save_data.get("purchased_tools", [])

	if saved_purchased_tools is Array:
		for index in range(min(tools.size(), saved_purchased_tools.size())):
			tools[index]["is_purchased"] = bool(
				saved_purchased_tools[index]
			)

	var saved_speed_upgrades = save_data.get("speed_upgrades", [])

	if saved_speed_upgrades is Array:
		for index in range(
			min(area_speed_upgrades.size(), saved_speed_upgrades.size())
		):
			area_speed_upgrades[index] = int(saved_speed_upgrades[index])

	var saved_chance_upgrades = save_data.get("chance_upgrades", [])

	if saved_chance_upgrades is Array:
		for index in range(
			min(area_chance_upgrades.size(), saved_chance_upgrades.size())
		):
			area_chance_upgrades[index] = int(saved_chance_upgrades[index])

	active_area_id = int(save_data.get("active_area_id", -1))
	active_artifact_id = int(save_data.get("active_artifact_id", -1))
	excavation_countdown = float(save_data.get("excavation_countdown", -1.0))
	tutorial_completed = bool(save_data.get("tutorial_completed", false))
	return true

func complete_tutorial() -> void:
	tutorial_completed = true
	save_game()

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
