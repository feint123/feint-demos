class_name GodotEssentialsPluginAchievements extends Node

signal achievement_unlocked(name: String, achievement: Dictionary)
signal achievement_updated(name: String, achievement: Dictionary)
signal achievement_reset(name: String, achievement: Dictionary)
signal all_achievements_unlocked

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var SETTINGS_PATH = "{project_name}/config/achievements".format({"project_name": ProjectSettings.get_setting("application/config/name")})

var current_achievements: Dictionary = {}
var unlocked_achievements: Dictionary = {}
var achievements_keys: PackedStringArray = []

## Basic achievement dictionary structure
# "achievement-name": {
#		"name": "MY achievement",
#		"description": "This is my awesome achievement",
#		"is_secret": false,
#		"count_goal": 25,
#		"current_progress": 0.0,
#		"icon_path": "res://assets/icon/my-achievement.png",
#		"unlocked": false,
#		"active": true
#	}

func _ready():
	http_request.request_completed.connect(_on_request_completed)
	achievement_updated.connect(_on_achievement_updated)
	achievement_unlocked.connect(_on_achievement_updated)
	
	_create_save_directory(ProjectSettings.get_setting(SETTINGS_PATH + "/save_directory"))
	_prepare_achievements()


func get_achievement(name: String) -> Dictionary:
	if current_achievements.has(name):
		return current_achievements[name]
	
	return {}

func update_achievement(name: String, data: Dictionary) -> void:
	if current_achievements.has(name):
		current_achievements[name].merge(data, true)
		
		achievement_updated.emit(name, data)
		

func unlock_achievement(name: String) -> void:
	if current_achievements.has(name):
		var achievement: Dictionary = current_achievements[name]
		if not achievement["unlocked"]:
			achievement["unlocked"] = true
			unlocked_achievements[name] = achievement
			achievement_unlocked.emit(name, achievement)


func reset_achievement(name: String, data: Dictionary = {}) -> void:
	if current_achievements.has(name):
		current_achievements[name].merge(data, true)
		current_achievements[name]["unlocked"] = false
		current_achievements[name]["current_progress"] = 0.0
		
		if unlocked_achievements.has(name):
			unlocked_achievements.erase(name)
			
		achievement_reset.emit(name, current_achievements[name])
		achievement_updated.emit(name, current_achievements[name])

func _read_from_local_source() -> void:
	var local_source_file = _local_source_file_path()

	if FileAccess.file_exists(local_source_file):
		var content = JSON.parse_string(FileAccess.get_file_as_string(local_source_file))
		if content == null:
			push_error("GodotEssentials2DPlugin: Failed reading achievement file {path}".format({"path": local_source_file}))
			return
			
		current_achievements = content
		achievements_keys = current_achievements.keys()
		

func _read_from_remote_source() -> void:
	if GodotEssentialsHelpers.is_valid_url(_remote_source_url()):
		http_request.request(_remote_source_url())
		await http_request.request_completed


func _create_save_directory(path: String) -> void:
	DirAccess.make_dir_absolute(path)


func _prepare_achievements() -> void:
	_read_from_local_source()
	_read_from_remote_source()
	_sync_achievements_with_encrypted_saved_file()


func _sync_achievements_with_encrypted_saved_file() -> void:
	var saved_file_path = _encrypted_save_file_path()
	
	if FileAccess.file_exists(saved_file_path):
		var content = FileAccess.open_encrypted_with_pass(saved_file_path, FileAccess.READ, _get_password())
		if content == null:
			push_error("GodotEssentials2DPlugin: Failed reading saved achievement file {path} with error {error}".format({"path": saved_file_path, "error": FileAccess.get_open_error()}))
			return
			
		var achievements = JSON.parse_string(content.get_as_text())
		if achievements:
			current_achievements.merge(achievements, true)


func _check_if_all_achievements_are_unlocked() -> bool:
	var all_unlocked = unlocked_achievements.size() == current_achievements.size()
	
	if all_unlocked:
		all_achievements_unlocked.emit()
		
	return all_unlocked


func _update_encrypted_save_file() -> void:
	if current_achievements.is_empty():
		return
	
	var saved_file_path = _encrypted_save_file_path()

	var file = FileAccess.open_encrypted_with_pass(saved_file_path, FileAccess.WRITE, _get_password())
	if file == null:
		push_error("GodotEssentials2DPlugin: Failed writing saved achievement file {path} with error {error}".format({"path": saved_file_path, "error": FileAccess.get_open_error()}))
		return
	
	file.store_string(JSON.stringify(current_achievements))
	file.close()


func _local_source_file_path() -> String:
	return ProjectSettings.get_setting(SETTINGS_PATH + "/local_source")


func _remote_source_url() -> String:
	return ProjectSettings.get_setting(SETTINGS_PATH + "/remote_source")


func _encrypted_save_file_path() -> String:
	return "{dir}/{file}".format({
		"dir": ProjectSettings.get_setting(SETTINGS_PATH + "/save_directory"),
		"file": ProjectSettings.get_setting(SETTINGS_PATH + "/save_file_name")
	})


func _get_password() -> String:
	return ProjectSettings.get_setting(SETTINGS_PATH + "/password")


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == HTTPRequest.RESULT_SUCCESS:
		var content = JSON.parse_string(body.get_string_from_utf8())
		if content:
			current_achievements.merge(content, true)
		return
	
	push_error("GodotEssentials2DPlugin: Failed request with code {code} to remote source url from achievements: {body}".format({"body": body, "code": response_code}))


func _on_achievement_updated(_name: String, _achievement: Dictionary) -> void:
	_update_encrypted_save_file()
	_check_if_all_achievements_are_unlocked()
