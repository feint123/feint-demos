class_name ShakeCameraComponent2D extends Node2D 

@onready var camera2d: Camera2D = get_parent()

@export var default_shake_strength = 15.0
@export var default_fade = 5.0

var random_number_generator = RandomNumberGenerator.new()
var shake_strength: float = 0.0
var shake_fade: float = 5.0

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	var camera_node = get_parent()

	if camera_node == null:
		warnings.append("The camera node was not found, make sure this node is a child of Camera2D")
			
	if not camera_node is Camera2D:
		warnings.append("The camera node where this node lives is not a Camera2D")
	
	return warnings


func _process(delta):
	shake_camera(delta)


func shake_camera(delta: float = get_process_delta_time()):
	if shake_strength > 0 and camera2d is Camera2D:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		camera2d.offset = Vector2(random_number_generator.randf_range(-shake_strength, shake_strength), random_number_generator.randf_range(-shake_strength,shake_strength))


func shake(strength: float = default_shake_strength, fade: float = default_fade):
	shake_strength = strength
	shake_fade = fade
