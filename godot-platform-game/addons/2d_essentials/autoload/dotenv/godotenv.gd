class_name GodotEssentialsPluginGodotEnvironment extends Node

signal variable_added(key: String)
signal variable_removed(key: String)
signal variable_replaced(key: String)
signal env_file_loaded(filename: String)

@export var ENVIRONMENT_FILES_PATH: String = _default_path_from_settings()

## Dictionary to track environment variables.
var ENVIRONMENT_VARIABLE_TRACKER: Array[String] = []

## Retrieve the value of an environment variable by its key.
func get_var(key: String) -> String:
	return OS.get_environment(key)
	
## Retrieve the value of an environment variable by its key or null it if it doesn't.
func get_var_or_null(key: String):
	var value: String = get_var(key)
	
	return null if value.is_empty() else value

## Set an environment variable with a key and an optional value.
## If the variable already exists, it will be replaced.
func set_var(key: String, value: String = "") -> void:
	if ENVIRONMENT_VARIABLE_TRACKER.has(key):
		variable_replaced.emit(key)
	else:
		ENVIRONMENT_VARIABLE_TRACKER.append(key)
		variable_added.emit(key)
		
	OS.set_environment(key, value)

## Remove an environment variable by its key.
func remove_var(key: String)-> void:
	if OS.has_environment(key):
		variable_removed.emit(key)
		ENVIRONMENT_VARIABLE_TRACKER.remove_at(ENVIRONMENT_VARIABLE_TRACKER.find(key))
		
	OS.unset_environment(key)

## Create an environment file with the specified filename. If it already exists, it can be overwritten.
func create_environment_file(filename: String = ".env", overwrite: bool = false) -> void:
	if overwrite or not _env_file_exists(filename):
		FileAccess.open(_env_path(filename), FileAccess.WRITE)
		var error = FileAccess.get_open_error()
		if error:
			push_error("Godotenv plugin: {error}".format({"error": error}))
			return

## Load environment variables from an environment file with the specified filename.
func load_env_file(filename: String = ".env") -> void:
	_read_file_with_callback(filename, _set_environment_from_line)
	env_file_loaded.emit(filename)

## Remove environment variables from the current process runtime
## You can add the keys that you do not want to be deleted in this process.
func flush_environment_variables(filename: String = ".env", except: Array[String] = []) -> void:	
	for key in ENVIRONMENT_VARIABLE_TRACKER.filter(func(key: String): return not key in except):
		remove_var(key)

## Add a key-value pair to an environment file and set the environment variable.
func add_var_to_file(filename: String, key: String, value: String = "") -> void:
	var env_file = FileAccess.open(_env_path(filename), FileAccess.READ_WRITE)
	var error = FileAccess.get_open_error()
	if error:
		push_error("Godotenv plugin: {error}".format({"error": error}))
		return
	
	env_file.seek_end()
	env_file.store_line("{key}={value}".format({"key": key, "value": value}))
	env_file.close()
	
	set_var(key, value)
	
## Check if an environment file with the specified filename exists.
func _env_file_exists(filename: String) -> bool:
	return FileAccess.file_exists(_env_path(filename))

## Get the full path to an environment file.
func _env_path(filename: String) -> String:
	return "{filepath}/{file}".format({"filepath": ENVIRONMENT_FILES_PATH, "file": filename})

## Callback to remove environment variables from a line in the environment file.
func _remove_environment_from_line(line: PackedStringArray) -> void:
	if line.size() > 1:
		var key: String = line[0].strip_edges()	
		remove_var(key)
	
## Callback to set environment variables from a line in the environment file.
func _set_environment_from_line(line: PackedStringArray) -> void:
	if line.size() > 1:
		var key: String = line[0].strip_edges()
		var value: String = line[1].strip_edges()
		set_var(key, value)

## Read an environment file with a callback function.
func _read_file_with_callback(filename: String = ".env", callback: Callable = func(line): pass):
	if _env_file_exists(filename):
		var env_file = FileAccess.open(_env_path(filename), FileAccess.READ)
		var error = FileAccess.get_open_error()
		if error:
			push_error("Godotenv plugin: {error}".format({"error": error}))
			return
			
		while env_file.get_position() < env_file.get_length():
			var line = env_file.get_line().split("=")		
			callback.call(line)
	
		env_file.close()
		
func _default_path_from_settings() -> String:
	var settings_path: String = "{project_name}/config/godotenv".format({"project_name": ProjectSettings.get_setting("application/config/name")})
	return ProjectSettings.get_setting(settings_path + "/root_directory")
