@tool
extends EditorPlugin

# Constants:
const main_panel_packed = preload("res://addons/ez_transitions/objects/main_container/main_container.tscn")

# Instances:
var MAIN_CONTROL

func _enter_tree() -> void:
	# Initialization of the plugin.
	MAIN_CONTROL = main_panel_packed.instantiate() # Getting the instance of the MAIN_CONTROL.
	
	# Adding the plugin to the editor.
	get_editor_interface().get_editor_main_screen().add_child(MAIN_CONTROL) # Adding the MAIN_CONTROL to the scene.
	_make_visible(false) # Hidding the MAIN_CONTROL.
	
	# Adding the plugin's singleton.
	add_autoload_singleton("EzTransitions", "res://addons/ez_transitions/objects/plugin_singleton/plugin_singleton_script.gd")
	
func _exit_tree() -> void:
	# Clean-up of the plugin.
	if (MAIN_CONTROL): # Checking if the MAIN_CONTROL exists.
		MAIN_CONTROL.queue_free() # Removing the MAIN_CONTROL.
		
	# Removing the plugin's singleton.
	remove_autoload_singleton("EzTransitions")
	
func _make_visible(visible: bool) -> void:
	# Updating the visibility of the plugin stuff.
	if (MAIN_CONTROL): # Checking if the MAIN_CONTROL exists.
		MAIN_CONTROL.visible = visible # Updating the visibility of the MAIN_CONTROL.
		
func _has_main_screen() -> bool:
	# Making the plugin visible on the main screen.
	return true
	
func _get_plugin_name() -> String:
	# Returning the plugin name.
	return "EzTransitions"
	
func _get_plugin_icon() -> Texture2D:
	# Returning the plugin icon.
	return preload("res://addons/ez_transitions/images/transition_node_icon.svg")
