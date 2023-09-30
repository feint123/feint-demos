@tool
@icon("res://addons/ez_transitions/images/transition_node_icon.svg")
extends CanvasLayer

# Plugin Variables:
var plugin_transitions_enabled: bool = true
var plugin_debug_mode: bool = true
var plugin_speed_scale: float = 1.0

# Variables:
var TRANSITION_OVERLAY: TransitionOverlay

func _ready() -> void:
	# Creating a new TransitionOverlay node.
	TRANSITION_OVERLAY = TransitionOverlay.new() # Creating a new TransitionOverlay instance.
	TRANSITION_OVERLAY.size = get_viewport().get_visible_rect().size # Updating the TransitionOverlay size.
	TRANSITION_OVERLAY.material = load("res://addons/ez_transitions/materials/transition_material.tres").duplicate() # Updating the material.
	TRANSITION_OVERLAY.material.set_shader_parameter("screen_size", TRANSITION_OVERLAY.size) # Updating the TextureRect size.
	TRANSITION_OVERLAY.material.set_shader_parameter("progress", 0.0) # Updating the Transition progress.
	TRANSITION_OVERLAY.mouse_filter = Control.MOUSE_FILTER_IGNORE # Ignoring mouse inputs.
	
	# Adding the new TransitionOverlay to the scene.
	add_child(TRANSITION_OVERLAY)
	
	if (plugin_debug_mode): # Checking if the plugin's debug mode is enabled.
		print_rich("[color=red]Successfully added global TransitionOverlay.") # Debug print.
	
func plugin_toggle_debug_mode(enabled: bool) -> void:
	# Enables or disables the plugin's debug mode.
	plugin_debug_mode = enabled
	print_rich("[color=red]Successfully updated EzTransitions debug mode. New value: %s" % str(enabled)) # Debug print.
	
func plugin_toggle_transitions(enabled: bool) -> void:
	# Enables or disables the plugin's transitions.
	plugin_transitions_enabled = enabled
	if (plugin_debug_mode): # Checking if the plugin's debug mode is enabled.
		print_rich("[color=red]Successfully updated EzTransitions transitions mode. New value: %s" % str(enabled)) # Debug print.
	
func plugin_set_speed_scale(new_speed_scale: float) -> void:
	# Sets the plugin's speed scale to the given value.
	plugin_speed_scale = new_speed_scale
	if (plugin_debug_mode): # Checking if the plugin's debug mode is enabled.
		print_rich("[color=red]Successfully updated EzTransitions speed scale. New value: %s" % str(new_speed_scale)) # Debug print.
	
func set_easing(intro_ease: Tween.EaseType, outro_ease: Tween.EaseType) -> void:
	# Updates the TransitionOverlay's intro and outro easing.
	TRANSITION_OVERLAY.INTRO_EASE = intro_ease
	TRANSITION_OVERLAY.OUTRO_EASE = outro_ease
	
func set_trans(intro_trans: Tween.TransitionType, outro_trans: Tween.TransitionType) -> void:
	# Updates the TransitionOverlay's intro and outro transition type.
	TRANSITION_OVERLAY.INTRO_TRANS = intro_trans
	TRANSITION_OVERLAY.OUTRO_TRANS = outro_trans
	
func set_timers(intro_duration: float, delay_to_proceed: float, outro_duration: float) -> void:
	# Updates all the TransitionOverlay's values that are related to times and durations.
	TRANSITION_OVERLAY.INTRO_DURATION = intro_duration
	TRANSITION_OVERLAY.DELAY_TO_PROCEED = delay_to_proceed
	TRANSITION_OVERLAY.OUTRO_DURATION = outro_duration
	
func set_reverse(reverse_intro: bool, reverse_outro: bool) -> void:
	# Updates the TransitionOverlay's intro and outro playback.
	TRANSITION_OVERLAY.REVERSE_INTRO = reverse_intro
	TRANSITION_OVERLAY.REVERSE_OUTRO = reverse_outro
	
func set_textures(intro_texture: String, outro_texture: String) -> void:
	# Updates all the TransitionOverlay's textures.
	TRANSITION_OVERLAY.INTRO_TEXTURE = load(intro_texture)
	TRANSITION_OVERLAY.OUTRO_TEXTURE = load(outro_texture)
	
func set_types(intro_type: int, outro_type: int) -> void:
	# Updates the TransitionOverlay's intro and outro animation type.
	TRANSITION_OVERLAY.INTRO_TYPE = intro_type
	TRANSITION_OVERLAY.OUTRO_TYPE = outro_type
	
func change_scene(target_scene_path: String) -> void:
	# Skipping the transition if the transitions aren't enabled.
	if (!plugin_transitions_enabled): # Checking if the transitions are enabled or not.
		get_tree().change_scene_to_file(target_scene_path) # Changing scene.
		
		if (plugin_debug_mode): # Checking if the plugin's debug mode is enabled.
			print_rich("[color=red]Transitions disabled! Skipping the transition and changing scene to: %s" % target_scene_path) # Debug print.
			
		return # Stopping the code right here.
		
	if (plugin_debug_mode): # Checking if the plugin's debug mode is enabled.
		print_rich("[color=red]Transition started. About to change scene to: %s" % target_scene_path) # Debug print.
		
	# Changes scene using the TransitionOverlay.
	TRANSITION_OVERLAY.play_intro() # Playing the intro.
	
	# Changing scene.
	await TRANSITION_OVERLAY.intro_finished # Waiting until the intro has finished playing.
	await get_tree().create_timer(TRANSITION_OVERLAY.DELAY_TO_PROCEED).timeout # Waiting the extra time.
	
	get_tree().change_scene_to_file(target_scene_path) # Actually changing scene.
	
	# Playing the outro.
	TRANSITION_OVERLAY.play_outro()
