class_name GodotEssentialsMotion extends Node2D

signal max_speed_reached
signal stopped
signal knockback_received(direction: Vector2, power: float)
signal temporary_speed_started(previous_speed: float, current_speed: float)
signal temporary_speed_finished
signal teleported(from: Vector2, to: Vector2)
signal dashed(position: Vector2)
signal finished_dash(initial_position: Vector2, final_position: Vector2)
signal dash_free_from_cooldown(dash_position: Vector2, current_dash_queue: Array[Vector2])
signal dash_restarted


@export_group("Speed")
## The maximum speed this character can reach.
@export var MAX_SPEED: float = 85
## This value makes the time it takes to reach maximum speed smoother.
@export var ACCELERATION: float = 350.0
## The force applied to slow down the character's movement.
@export var FRICTION: float = 750.0
## Modulates the rate of horizontal speed decrease during airborne movement.
@export_range(0.0 , 1.0, 0.001) var AIR_FRICTION_HORIZONTAL_FACTOR: float = 1.0
## Modulates the rate of vertical speed decrease during airborne movement.
@export_range(0.0 , 1.0, 0.001) var AIR_FRICTION_VERTICAL_FACTOR: float = 1.0

@export_group("Modifiers")
## In seconds, the amount of time a speed modification will endure
@export var DEFAULT_TEMPORARY_SPEED_TIME = 3.0

@export_group("Dash")
## The speed multiplier would be applied to the player velocity on runtime
@export var DASH_SPEED_MULTIPLIER: float = 1.5
## The times this character can dash until the cooldown is activated
@export_range(1, 10, 1, "or_greater") var times_can_dash: int = 1
## The time it takes for the dash ability to become available again.
@export var dash_cooldown: float = 1.5
## The time this dash will be active
@export var dash_duration: float = 0.3
## This variable represents whether the character can initiate another dash while already in the dashing state
@export var can_dash_while_dashing: bool = true

@export_group("Signals")
## Emits a signal when the body reaches its maximum speed.
@export var max_speed_reached_signal: bool = false
## Emits a signal when this body's velocity reaches zero after movement.
@export var stopped_signal: bool = false
## Emits a signal when a knockback function is called.
@export var knockback_received_signal: bool = true

@onready var body = get_parent() as CharacterBody2D
@onready var original_max_speed: float = MAX_SPEED

var velocity: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.ZERO
var last_faced_direction: Vector2 = Vector2.RIGHT

var temporary_speed_timer: Timer

var dash_duration_timer: Timer
var dash_queue: Array[Vector2] = []
var is_dashing: bool = false:
	set(value):
		if value != is_dashing:
			if value:
				dashed.emit(body.global_position)
				
		is_dashing = value


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	var parent_node = get_parent()
	
	if parent_node == null or not parent_node is CharacterBody2D:
		warnings.append("This component needs a CharacterBody2D parent in order to work properly")
			
	return warnings


func _ready():
	_create_temporary_speed_timer()
	_create_dash_duration_timer()
	

func move() -> void:
	if body:
		body.velocity = velocity
		body.move_and_slide()
	


func move_and_collide(delta: float = get_physics_process_delta_time()) -> KinematicCollision2D:
	if body:
		body.velocity = velocity
	
		return body.move_and_collide(body.velocity * delta)
	
	return null


func accelerate(direction: Vector2, delta: float =  get_physics_process_delta_time()) -> GodotEssentialsMotion:
	facing_direction = _normalize_vector(direction)
	
	if not direction.is_zero_approx():
		last_faced_direction = facing_direction
		
		if ACCELERATION > 0:
			velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
		else:	
			velocity = direction * MAX_SPEED
		
		
		if max_speed_reached_signal and _velocity_has_reached_max_speed():
			max_speed_reached.emit()

	return self


func decelerate(delta: float = get_physics_process_delta_time(), force_stop: bool = false) -> GodotEssentialsMotion:
	var previous_velocity = velocity
	
	if force_stop or FRICTION == 0:
		velocity = Vector2.ZERO
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	if stopped_signal and not previous_velocity.is_zero_approx() and velocity.is_zero_approx():
		stopped.emit()
	
	return self
	

func accelerate_to_position(position: Vector2) -> GodotEssentialsMotion:
	return accelerate(body.global_position.direction_to(position))


func apply_air_friction_horizontal(friction_factor: float = AIR_FRICTION_HORIZONTAL_FACTOR) -> GodotEssentialsMotion:
	if AIR_FRICTION_HORIZONTAL_FACTOR > 0 and not body.is_on_floor() and not body.is_on_wall():
		velocity.x *= friction_factor
		
	return self
	

func apply_air_friction_vertical(friction_factor: float = AIR_FRICTION_VERTICAL_FACTOR) -> GodotEssentialsMotion:
	if AIR_FRICTION_VERTICAL_FACTOR > 0 and not body.is_on_floor() and not body.is_on_wall():
		velocity.y *= friction_factor
		
	return self
	

func knockback(direction: Vector2, power: float) -> GodotEssentialsMotion:
	var knockback_direction: Vector2 = _normalize_vector(direction) * max(1, power)

	velocity = knockback_direction

	if knockback_received_signal:
		knockback_received.emit(direction, power)

	return self	


func teleport_to_position(target_position: Vector2, valid_position_callback: Callable = _default_valid_position_callback) -> GodotEssentialsMotion:
	if call("valid_position_callback" ,body, target_position):
		var original_position: Vector2  = body.global_position
		body.global_position = target_position
		
		teleported.emit(original_position, target_position)
		
	return self


func change_speed_temporary(new_speed: float, time: float = DEFAULT_TEMPORARY_SPEED_TIME) -> GodotEssentialsMotion:
	if temporary_speed_timer:
		temporary_speed_timer.stop()
		temporary_speed_timer.wait_time = max(0.05, absf(time))
		temporary_speed_timer.start()
		
		MAX_SPEED = absf(new_speed)
		
		temporary_speed_started.emit(MAX_SPEED, new_speed)

	return self


func has_available_dashes() -> bool:
	return dash_queue.size() < times_can_dash


func can_dash(direction: Vector2 = Vector2.ZERO) -> bool:
	# var available_dashes = not direction.is_zero_approx() and has_available_dashes() 
	var available_dashes = has_available_dashes() 
	var while_dashing = can_dash_while_dashing or (not can_dash_while_dashing and not is_dashing)

	return available_dashes and while_dashing


func dash(target_direction: Vector2 = facing_direction, speed_multiplier: float = DASH_SPEED_MULTIPLIER) -> GodotEssentialsMotion:
	if can_dash(target_direction):
		facing_direction = _normalize_vector(target_direction)
		last_faced_direction = facing_direction
		is_dashing = true
		velocity = target_direction * (MAX_SPEED * max(1, absf(speed_multiplier)))

		dash_queue.append(body.global_position)
		
		if dash_duration_timer.time_left > 0:
			dash_duration_timer.timeout.emit()
		
		dash_duration_timer.start()
	
	return self


func reset_dash_queue():
	if dash_queue.size() > 0:
		dash_queue.clear()
		dash_restarted.emit()


func _normalize_vector(value: Vector2) -> Vector2:
	return value if value.is_normalized() else value.normalized()


func _velocity_has_reached_max_speed() -> bool:
	return velocity.length_squared() == MAX_SPEED * MAX_SPEED


func _create_dash_duration_timer(time: float = dash_duration):
	if dash_duration_timer:
		return
		
	dash_duration_timer = Timer.new()
	dash_duration_timer.name = "DashDurationTimer"
	dash_duration_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	dash_duration_timer.wait_time = time
	dash_duration_timer.one_shot = true
	dash_duration_timer.autostart = false
	
	add_child(dash_duration_timer)
	dash_duration_timer.timeout.connect(on_dash_duration_timer_timeout)


func _create_dash_cooldown_timer(time: float = dash_cooldown):
	var dash_cooldown_timer: Timer = Timer.new()

	dash_cooldown_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	dash_cooldown_timer.wait_time = max(0.05, time)
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.autostart = true
	
	add_child(dash_cooldown_timer)
	dash_cooldown_timer.timeout.connect(on_dash_cooldown_timer_timeout.bind(dash_cooldown_timer))


func _create_temporary_speed_timer(time: float = DEFAULT_TEMPORARY_SPEED_TIME) -> void:
	if temporary_speed_timer:
		return
		
	temporary_speed_timer = Timer.new()
	temporary_speed_timer.name = "TemporarySpeedTimer"
	temporary_speed_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	temporary_speed_timer.wait_time = time
	temporary_speed_timer.one_shot = true
	temporary_speed_timer.autostart = false

	add_child(temporary_speed_timer)
	temporary_speed_timer.timeout.connect(on_temporary_speed_timer_timeout.bind(MAX_SPEED))


func  _default_valid_position_callback(_body: CharacterBody2D, _position: Vector2) -> bool:
	return true


func on_temporary_speed_timer_timeout(original_speed: float):
	MAX_SPEED = original_speed
	temporary_speed_finished.emit()


func on_dash_cooldown_timer_timeout(timer: Timer):
	if not dash_queue.is_empty():
		var last_dash_position = dash_queue.pop_back()
		dash_free_from_cooldown.emit(last_dash_position, dash_queue)
	timer.queue_free()
	
	
func on_dash_duration_timer_timeout():
	is_dashing = false
	_create_dash_cooldown_timer()
	var last_dash = dash_queue.back() if dash_queue.size() else Vector2.ZERO
	finished_dash.emit(last_dash, body.global_position)
	
