@tool
@icon("res://addons/ez_transitions/images/transition_overlay_node_icon.svg")
extends TextureRect
class_name TransitionOverlay

## A node responsable for the front-end of a transition. It can display a transition's visuals separately, but can't actually change scenes.
## If you want to change scenes, use Transition instead.

# Signals:
signal intro_finished # Emitted when the intro animation is over.
signal outro_finished # Emitted when the outro animation is over.

@export_group("Intro")
@export var INTRO_EASE: Tween.EaseType = Tween.EASE_IN_OUT ## The intro easing type. Determines how the intro animation will occur.
@export var INTRO_TRANS: Tween.TransitionType = Tween.TRANS_SINE # The intro transition type. Determines how the intro animation will occur. Changes based on the INTRO_EASE.
@export var INTRO_TYPE: int = 0 ## The transition type. Determines what animation is going to be displayed in the intro.
@export var INTRO_DURATION: float = 1.0 ## The intro duration. Determines how long it will take the intro animation to finish.
@export var DELAY_TO_PROCEED: float = 1.0 ## How long it will take to the outro animation starts playing after the intro animation is over.
@export var REVERSE_INTRO: bool = false ## Determines if the intr animation will be played normally or backwards.
@export var INTRO_TEXTURE: Texture2D = null ## The texture of the intro animation. Determines how the intro will look.

@export_group("Outro")
@export var OUTRO_EASE: Tween.EaseType = Tween.EASE_IN_OUT ## The outro easing type. Determines how the outro animation will occur.
@export var OUTRO_TRANS: Tween.TransitionType = Tween.TRANS_SINE # The outro transition type. Determines how the outro animation will occur. Changes based on the INTRO_EASE.
@export var OUTRO_TYPE: int = 0 ## The transition type. Determines what animation is going to be displayed in the outro.
@export var OUTRO_DURATION: float = 1.0 ## The outro duration. Determines how long it will take the outro animation to finish.
@export var REVERSE_OUTRO: bool = true ## Determines if the intr animation will be played normally or backwards.
@export var OUTRO_TEXTURE: Texture2D = null ## The texture of the intro animation. Determines how the intro will look.

func _get_configuration_warnings() -> PackedStringArray:
	# Creating a new array of warnings.
	var warnings: PackedStringArray = []
	
	# Checking if this TransitionOverlay's material isn't null.
	if (material != null):
		warnings.push_back("This TransitionOverlay's material is going to be replaced at run time so the TransitionOverlay can properly work.") # Adding a new warning.
		
	# Checking if this TransitionOverlay has a texture.
	if (INTRO_TEXTURE == null):
		warnings.push_back("This TransitionOverlay has no Intro Texture. The Transition's intro will not be visible. A Texture should be added either manually or by code.") # Adding a new warning.
	if (OUTRO_TEXTURE == null):
		warnings.push_back("This TransitionOverlay has no Outro Texture. The Transition's outro will not be visible. A Texture should be added either manually or by code.") # Adding a new warning.
	
	# Returning all warnings.
	return warnings

func _ready() -> void:
	# Setting up the TextureRect.
	material = load("res://addons/ez_transitions/materials/transition_material.tres").duplicate() # Updating the material.
	material.set_shader_parameter("screen_size", size) # Updating the TextureRect size.
	material.set_shader_parameter("progress", 0.0) # Updating the Transition progress.
	
## Plays the intro animation, that makes this TransitionOverlay go from invisible to fully visible.
func play_intro() -> void:
	# Updating the shader parameters.
	material.set_shader_parameter("reversed", REVERSE_INTRO) # Making the Transition happen normally / reversed.
	material.set_shader_parameter("progress", 0.0 if (!REVERSE_INTRO) else 1.0) # Updating the Transition progress.
	material.set_shader_parameter("type", INTRO_TYPE) # Updating the Transition type.
	
	# Updating the texture.
	texture = INTRO_TEXTURE
	
	# Checking if the scene tree exists to prevent an error.
	if (!get_tree()):
		print_rich("[color=yellow]Warning: Could not create the TransitionOverlay's tween because the scene tree is returning null.") # Printing an warning.
		return # Stopping the code right here.
	
	# Creating a new Tween.
	var tween: Tween = get_tree().create_tween()
	
	# Setting up the new Tween.
	tween.set_ease(INTRO_EASE) # Updating the Tween's easing.
	tween.set_trans(INTRO_TRANS) # Updating the Tween's transition.
	
	# Tweening the "progress" property.
	tween.tween_property(material, "shader_parameter/progress", 1.0 if (!REVERSE_INTRO) else 0.0, INTRO_DURATION / EzTransitions.plugin_speed_scale)
	
	# Emitting the "intro_finished" signal, indicating that the intro has been finished.
	await tween.finished # Waiting until the tween is over.
	emit_signal("intro_finished") # Emitting the signal.
	
## Plays the intro animation, that makes this TransitionOverlay go from fully visible to invisible.
func play_outro() -> void:
	# Updating the shader parameters.
	material.set_shader_parameter("reversed", REVERSE_OUTRO) # Making the Transition happen normally / reversed.
	material.set_shader_parameter("progress", 0.0 if (REVERSE_OUTRO) else 1.0) # Updating the Transition progress.
	material.set_shader_parameter("type", OUTRO_TYPE) # Updating the Transition type.
	
	# Updating the texture.
	texture = OUTRO_TEXTURE
	
	# Checking if the scene tree exists to prevent an error.
	if (!get_tree()):
		return # Stopping the code right here.
		print_rich("[color=yellow]Warning: Could not create the TransitionOverlay's tween because the scene tree is returning null.") # Printing an error.
	
	# Creating a new Tween.
	var tween: Tween = get_tree().create_tween()
	
	# Setting up the new Tween.
	tween.set_ease(OUTRO_EASE) # Updating the Tween's easing.
	tween.set_trans(OUTRO_TRANS) # Updating the Tween's transition.
	
	# Tweening the "progress" property.
	tween.tween_property(material, "shader_parameter/progress", 1.0 if (REVERSE_OUTRO) else 0.0, OUTRO_DURATION / EzTransitions.plugin_speed_scale)
	
	# Emitting the "outro_finished" signal, indicating that the outro has been finished.
	await tween.finished # Waiting until the tween is over.
	emit_signal("outro_finished") # Emitting the signal.
