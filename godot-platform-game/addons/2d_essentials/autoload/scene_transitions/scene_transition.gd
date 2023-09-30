class_name GodotEssentialsSceneTransition extends Node

signal started_transition(data: Dictionary)
signal finished_transition(data: Dictionary, next_scene)

var data: Dictionary = {}

## LOADING GROUP ##
var progress = [0]
var load_status = ResourceLoader.THREAD_LOAD_FAILED

func _enter_tree():
	started_transition.emit(data)


func _ready():
	if _is_loading_screen():
		ResourceLoader.load_threaded_request(data["scene_path"])
		
		
func _process(delta):
	if _is_loading_screen():
		load_status = ResourceLoader.load_threaded_get_status(data["scene_path"], progress)
		
		if load_status == ResourceLoader.THREAD_LOAD_LOADED:
			finished_transition.emit(data, ResourceLoader.load_threaded_get(data["scene_path"]))
			queue_free()


func _is_loading_screen() -> bool:
	return data.has("is_loading_screen") and data["is_loading_screen"]

