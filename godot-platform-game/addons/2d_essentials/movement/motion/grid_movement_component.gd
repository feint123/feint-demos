class_name GodotEssentialsGridMovementComponent extends Node2D

signal moved(result: Dictionary)
signal move_not_valid(result: Dictionary)
signal flushed_recorded_grid_movements(recorded_movements: Array[Dictionary])
signal movements_completed(movements: Array[Dictionary])

@export_group("GridSize")
## The tile size for this grid based movement
@export var TILE_SIZE: int = 16

@export_group("GridBehaviour")
## Number of grid movements recorded before deletion (set to 0 to keep them indefinitely)
@export var MAX_RECORDED_GRID_MOVEMENTS: int = 5
## Number of movements to be performed before emitting a signal notification.
@export var EMIT_SIGNAL_EVERY_N_MOVEMENTS: int = 3

@onready var body: CharacterBody2D = get_parent() as CharacterBody2D

var recorded_grid_movements: Array[Dictionary] = []
var movements_count: int = 0

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	var parent_node = get_parent()
	
	if parent_node == null or not parent_node is CharacterBody2D:
		warnings.append("This component needs a CharacterBody2D parent in order to work properly")
			
	return warnings


func _ready():
	if body:
		snap_body_position(body)
	
	moved.connect(on_moved)
	flushed_recorded_grid_movements.connect(on_flushed_recorded_grid_movements)
	

func move(direction: Vector2, valid_position_callback: Callable = _default_valid_position_callback):
	direction = _handle_grid_direction(direction)
	
	if direction.is_zero_approx():
		return
	
	var original_position = body.global_position
	var next_position = original_position + direction * TILE_SIZE
	
	var result = {
		"from": original_position, 
		"to": next_position, 
		"direction": direction
	}
	

	if valid_position_callback.call(result):
		body.global_position = next_position
		look_at(direction + body.global_position)

		moved.emit(result)
	else:
		move_not_valid.emit(result)



func follow_path(moves: Array[Vector2], valid_position_callback: Callable = _default_valid_position_callback):
	if moves.size() > 0:
		var move = moves.pop_front()
		move(move, valid_position_callback)
		call_deferred("follow_path", moves, valid_position_callback)


func teleport_to(target_position: Vector2,  valid_position_callback: Callable = _default_valid_position_callback):
	var result = {
		"from":  body.global_position, 
		"to": target_position, 
		"direction": GodotEssentialsHelpers.normalize_vector(target_position)
	}
	
	if valid_position_callback.call(result):
		body.global_position = target_position 
		snap_body_position(body)


func snap_body_position(body: CharacterBody2D) -> void:
	body.global_position = snap_position(body.global_position)
	body.global_position += Vector2.ONE * TILE_SIZE/2


func snap_position(position: Vector2) -> Vector2:
	return position.snapped(Vector2.ONE * TILE_SIZE)


func _handle_grid_direction(direction: Vector2):
	direction = GodotEssentialsHelpers.normalize_vector(direction)
	
	# Normalize diagonals
	if GodotEssentialsHelpers.is_diagonal_direction(direction):
		direction *= sqrt(2)

	return direction


func _default_valid_position_callback(_result: Dictionary = {}) -> bool:
	return true


func on_moved(result: Dictionary):
	if MAX_RECORDED_GRID_MOVEMENTS == 0 or recorded_grid_movements.size() < MAX_RECORDED_GRID_MOVEMENTS:
		recorded_grid_movements.append(result)
	
	movements_count += 1
	
	if movements_count >= EMIT_SIGNAL_EVERY_N_MOVEMENTS:
		var movements: Array[Dictionary] = recorded_grid_movements.duplicate()
		movements.reverse()
		
		movements_completed.emit(movements.slice(0, movements_count))
		movements_count = 0

	if recorded_grid_movements.size() >= MAX_RECORDED_GRID_MOVEMENTS:
		flushed_recorded_grid_movements.emit(recorded_grid_movements)
		recorded_grid_movements.clear()
	

func on_flushed_recorded_grid_movements(movements: Array[Dictionary]):
	movements.clear()
