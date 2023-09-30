@tool
extends Control

# Nodes:
@onready var TRANSITION_OVERLAY: TransitionOverlay = $TransitionOverlay

# Variables:
var INTRO_EASE_ID: int = 0
var INTRO_TRANS_ID: int = 2
var INTRO_TYPE: int = 0
var INTRO_DURATION: float = 1.0
var DELAY_TO_PROCEED: float = 0.0
var REVERSE_INTRO: bool = false
var INTRO_TEXTURE_PATH: String = "res://addons/ez_transitions/images/black_texture.png"

var OUTRO_EASE_ID: int = 1
var OUTRO_TRANS_ID: int = 2
var OUTRO_TYPE: int = 0
var OUTRO_DURATION: float = 1.0
var REVERSE_OUTRO: bool = true
var OUTRO_TEXTURE_PATH: String = "res://addons/ez_transitions/images/black_texture.png"

var TARGET_SCENE_PATH: String = ""

func _ready() -> void:
	# Connections.
	for group in ["EasingCheckboxIntro", "EasingCheckboxOutro", "TransitionCheckboxIntro", "TransitionCheckboxOutro", "TypeCheckboxIntro", "TypeCheckboxOutro"]:
		connect_checkboxes(group)
		
func _on_preview_button_pressed() -> void:
	# Updating the TransitionOverlay variables.
	TRANSITION_OVERLAY.INTRO_EASE = INTRO_EASE_ID
	TRANSITION_OVERLAY.INTRO_TRANS = INTRO_TRANS_ID
	TRANSITION_OVERLAY.INTRO_TYPE = INTRO_TYPE
	TRANSITION_OVERLAY.INTRO_DURATION = INTRO_DURATION
	TRANSITION_OVERLAY.DELAY_TO_PROCEED = DELAY_TO_PROCEED
	TRANSITION_OVERLAY.REVERSE_INTRO = REVERSE_INTRO
	TRANSITION_OVERLAY.INTRO_TEXTURE = load(INTRO_TEXTURE_PATH)
	TRANSITION_OVERLAY.OUTRO_EASE = OUTRO_EASE_ID
	TRANSITION_OVERLAY.OUTRO_TRANS = OUTRO_TRANS_ID
	TRANSITION_OVERLAY.OUTRO_TYPE = OUTRO_TYPE
	TRANSITION_OVERLAY.OUTRO_DURATION = OUTRO_DURATION
	TRANSITION_OVERLAY.REVERSE_OUTRO = REVERSE_OUTRO
	TRANSITION_OVERLAY.OUTRO_TEXTURE = load(OUTRO_TEXTURE_PATH)
	
	# Playing the transition animation.
	TRANSITION_OVERLAY.play_intro() # Playing the intro.
	
	# Changing scene.
	await TRANSITION_OVERLAY.intro_finished # Waiting until the intro has finished playing.
	await get_tree().create_timer(DELAY_TO_PROCEED).timeout # Waiting the extra time.
	
	# Playing the outro.
	TRANSITION_OVERLAY.play_outro()
	
func _on_copy_button_pressed() -> void: 
	# Generating the transition code and putting in the user's clipboard.
	DisplayServer.clipboard_set(generate_code())

# Updating the intro variables.
func _on_intro_duration_spinbox_value_changed(value: float) -> void: INTRO_DURATION = value # Updating the intro duration variable.
func _on_intro_delay_spinbox_value_changed(value: float) -> void: DELAY_TO_PROCEED = value # Updating the intro delay to proceed variable.
func _on_intro_reverse_checkbox_toggled(button_pressed: bool) -> void: REVERSE_INTRO = button_pressed # Updating the intro reverse variable.
func _on_intro_texture_edit_text_changed(new_text: String) -> void: INTRO_TEXTURE_PATH = new_text # Updating the intro texture path variable.

# Updating the outro variables.
func _on_outro_reverse_checkbox_toggled(button_pressed: bool) -> void: REVERSE_OUTRO = button_pressed # Updating the outro reverse variable.
func _on_outro_duration_spinbox_value_changed(value: float) -> void: OUTRO_DURATION = value # Updating the intro duration variable.
func _on_outro_texture_edit_text_changed(new_text: String) -> void: OUTRO_TEXTURE_PATH = new_text # Updating the outro texture path variable.

# Updating other variables.
func _on_scene_edit_text_changed(new_text: String) -> void: TARGET_SCENE_PATH = new_text # Updating the next scene path variable.
	
func connect_checkboxes(group: String) -> void:
	# This function cnnects all checkboxes in a certain group.
	for check_box in get_tree().get_nodes_in_group(group): # Looping trough every node in a group.
		check_box.connect("pressed", func(): # Connecting a signal.
			# Updating the nodes.
			for i in get_tree().get_nodes_in_group(group): # Looping trough every node in a group.
				i.button_pressed = false # Unchecking that node.
			check_box.button_pressed = true # Chceking that node.
			
			# Updating variables.
			if (check_box.is_in_group("EasingCheckboxIntro")): # Checking if the node is in the "EasingCheckboxIntro" group.
				INTRO_EASE_ID = check_box.z_index # Updating the intro easing ID.
				
			elif (check_box.is_in_group("EasingCheckboxOutro")): # Checking if the node is in the "EasingCheckboxOutro" group.
				OUTRO_EASE_ID = check_box.z_index # Updating the intro easing ID.
				
			elif (check_box.is_in_group("TransitionCheckboxIntro")): # Checking if the node is in the "TransitionCheckboxIntro" group.
				INTRO_TRANS_ID = check_box.z_index # Updating the intro easing ID.
				
			elif (check_box.is_in_group("TransitionCheckboxOutro")): # Checking if the node is in the "TransitionCheckboxOutro" group.
				OUTRO_TRANS_ID = check_box.z_index # Updating the intro easing ID.
				
			elif (check_box.is_in_group("TypeCheckboxIntro")): # Checking if the node is in the "TransitionCheckboxIntro" group.
				INTRO_TYPE = check_box.z_index # Updating the intro easing ID.
				
			elif (check_box.is_in_group("TypeCheckboxOutro")): # Checking if the node is in the "TransitionCheckboxOutro" group.
				OUTRO_TYPE = check_box.z_index # Updating the intro easing ID.
		)
		
func generate_code() -> String:
	# This function generates a GD Script code that can be used to start a new transition.
	var code: String = "" # This variable stores the code that is going to be generated.
	
	# Generating the code itself.
	code += "EzTransitions.set_easing(%s, %s)" % [str(INTRO_EASE_ID), str(OUTRO_EASE_ID)] + "\n"
	code += "EzTransitions.set_trans(%s, %s)" % [str(INTRO_TRANS_ID), str(OUTRO_TRANS_ID)] + "\n"
	code += "EzTransitions.set_timers(%s, %s, %s)" % [str(INTRO_DURATION), str(DELAY_TO_PROCEED), str(OUTRO_DURATION)] + "\n"
	code += "EzTransitions.set_reverse(%s, %s)" % [str(REVERSE_INTRO), str(REVERSE_OUTRO)] + "\n"
	code += "EzTransitions.set_textures(\"%s\", \"%s\")" % [str(INTRO_TEXTURE_PATH), str(OUTRO_TEXTURE_PATH)] + "\n"
	code += "EzTransitions.set_types(%s, %s)" % [str(INTRO_TYPE), str(OUTRO_TYPE)] + "\n"
	code += "EzTransitions.change_scene(\"%s\")" % TARGET_SCENE_PATH
	
	# Returnning the generated code.
	return code
		
# EzTransitions.set_easing(intro_easing, outro_easing)
# EzTransitions.set_trans(intro_trans, outro_trans)
# EzTransitions.set_timers(intro_duration, delay_to_proceed, outro_duration)
# EzTransitions.set_reverse(reverse_intro, reverse_outro)
# EzTransitions.set_textures(intro_texture, outro_texture)
# EzTransitions.set_types(intro_type, outro_type)
# EzTransitions.change_scene(next_scene)
