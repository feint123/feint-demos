class_name ProjectileComponent extends Node2D

signal follow_started(target:Node2D)
signal follow_stopped(target: Node2D)
signal target_swapped(current_target: Node2D, previous_target:Node2D)
signal bounced(position: Vector2)
signal penetrated(remaining_penetrations: int)
signal penetration_complete()

@export_group("Speed")
@export var max_speed: float = 10.0:
	get:
		return max(0, max_speed - (speed_reduction_on_penetration * penetration_count))
@export var acceleration: float = 0.0

@export_group("Homing")
## When the target goes beyond the homing_distance, the homing behavior could stop.
@export var homing_distance: float = 500.0
## The purpose of "homing_strength" is to provide fine-grained control over how aggressively the projectile homes in on the target
@export var homing_strength: float = 20.0

@export_group("Penetration")
## The maximum number of penetrations a projectile can perform.
@export var max_penetrations: int = 1
## The maximum number of penetrations a projectile can perform before penetration is complete.
@export var speed_reduction_on_penetration: float = 0.0

@export_group("Bounce")
## Determines whether bounce behavior is enabled for the projectile.
@export var bounce_enabled: bool = false
## The maximum number of bounces a projectile can perform before stopping.
@export var max_bounces: int = 10

@onready var projectile = get_parent() as Node2D

var direction: Vector2 = Vector2.ZERO

var target: Node2D
var follow_target: bool = false:
	set(value):
		if value != follow_target:
			if follow_target:
				follow_started.emit(target)
			else:
				follow_stopped.emit(target)
				
		follow_target = value

var penetration_count: int = 0:
	set(value):
		penetration_count += value
		if penetration_count >= max_penetrations:
			penetration_complete.emit()
		else:
			penetrated.emit(max(0, max_penetrations - penetration_count))

var bounced_positions: Array[Vector2] = []


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	var parent_node = get_parent()
	
	if parent_node == null or not parent_node is Node2D:
		warnings.append("This component needs a Node2D parent in order to work properly")
			
	return warnings


func _ready():
	follow_started.connect(on_follow_started)


func move(delta: float = get_physics_process_delta_time()):
	if projectile:
		if acceleration > 0:
			projectile.global_position = projectile.global_position.lerp(projectile.global_position * max_speed, acceleration * max_speed * delta)
		else:
			projectile.global_position += direction * max_speed
			
		projectile.look_at(direction + projectile.global_position)


func swap_target(next_target: Node2D) -> void:
	target_swapped.emit(target, next_target)
	target = next_target
	
	
func stop_follow_target() -> void:
	target = null
	follow_target = false


func begin_follow_target(new_target: Node2D) -> void:
	target = new_target
	follow_target = true

	
func target_position() -> Vector2:
	if target:
		return projectile.global_position.direction_to(target.global_position)
	
	return Vector2.ZERO


func bounce(new_direction: Vector2) -> Vector2:
	if bounced_positions.size() < max_bounces:
		bounced_positions.append(projectile.global_position)
		direction = direction.bounce(new_direction)
		bounced.emit(bounced_positions.back())
	
	return direction


func _target_can_be_follow(target: Node2D) -> bool:
	return follow_target and target and target.global_position.distance_to(global_position) < homing_distance


func on_follow_started(delta: float = get_physics_process_delta_time()) -> void:
	if _target_can_be_follow(target):
		var direction_to_target: Vector2 = GodotEssentialsHelpers.normalize_vector(target.global_position - projectile.global_position)
		direction = direction.lerp(direction_to_target, homing_strength * delta)
	else:
		stop_follow_target()
