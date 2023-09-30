class_name GodotEssentialsPluginSceneTransitioner extends Node

signal started_transition(data: Dictionary)
signal finished_transition(data: Dictionary, next_scene)


func transition_to_with_loading(scene: String, loading_scene: PackedScene, data: Dictionary = {}) -> void:
		data.merge({"is_loading_screen": true, "scene_path": scene})
		transition_to(scene, loading_scene, data)


func transition_to(scene, transition, data: Dictionary = {}) -> void:
	var transition_scene = transition.instantiate() as GodotEssentialsSceneTransition
	transition_scene.data.merge(data)
	transition_scene.data["target_scene"] = scene
	transition_scene.started_transition.emit(data)
	
	get_viewport().add_child(transition_scene)
	transition_scene.finished_transition.connect(on_finished_transition)


func _change_to_packed(scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(scene)
	
	
func _change_to_file(path: String) -> void:
	get_tree().change_scene_to_file(path)


func _scene_is_available(path: String) -> bool:
	return FileAccess.file_exists(path) or ResourceLoader.exists(path)


func _is_loading_screen(data: Dictionary) -> bool:
	return data.has("is_loading_screen") and data["is_loading_screen"]


func on_finished_transition(data: Dictionary, next_scene) -> void:
	var scene = data["target_scene"]
	
	if _is_loading_screen(data):
		_change_to_packed(next_scene)
	if typeof(scene) == TYPE_STRING and _scene_is_available(scene):
		_change_to_file(scene)
	elif scene is PackedScene:
		_change_to_packed(scene)
	else:
		push_error("Godot2DEssentialsPlugin: The scene {scene} cannot be transitioned".format({"scene": scene}))
