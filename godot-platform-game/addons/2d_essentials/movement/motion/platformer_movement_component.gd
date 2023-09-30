class_name GodotEssentialsPlatformerMovementComponent extends GodotEssentialsMotion

signal gravity_changed(enabled: bool)
signal inverted_gravity(inverted: bool)
signal temporary_gravity_started(previous_gravity: float, current_gravity: float)
signal temporary_gravity_finished
signal jumped(position: Vector2)
signal wall_jumped(normal: Vector2, position: Vector2)
signal allowed_jumps_reached(jump_positions: Array[Vector2])
signal jumps_restarted
signal coyote_time_started
signal coyote_time_finished
signal wall_slide_started
signal wall_slide_finished
signal wall_climb_started
signal wall_climb_finished

@export_group("Gravity")
## The maximum vertical velocity while falling to control fall speed
@export var MAXIMUM_FALL_VELOCITY: float = 200.0
## The default duration in seconds when the gravity is suspended
@export var DEFAULT_GRAVITY_SUSPEND_DURATION: float = 2.0
## The default duration in seconds when the gravity is modified temporary
@export var DEFAULT_TEMPORARY_GRAVITY_TIME: float = 2.0

@export_group("Jump")
## The maximum height the character can reach
@export var jump_height: float = 85:
	set(value):
		jump_height = value
		jump_velocity = _calculate_jump_velocity(jump_height, jump_time_to_peak)
		jump_gravity = _calculate_jump_gravity(jump_height, jump_time_to_peak )
		fall_gravity = _calculate_fall_gravity(jump_height, jump_time_to_fall)
	get:
		return jump_height
		
## Time it takes to reach the maximum jump height
@export var jump_time_to_peak: float = 0.4:
	set(value):
		jump_time_to_peak = value
		jump_velocity = _calculate_jump_velocity(jump_height, jump_time_to_peak)
		jump_gravity = _calculate_jump_gravity(jump_height, jump_time_to_peak )
	get:
		return jump_time_to_peak
		
## Time it takes to reach the floor after jump
@export var jump_time_to_fall: float = 0.4:
	set(value):
		jump_time_to_fall = value
		fall_gravity = _calculate_fall_gravity(jump_height, jump_time_to_fall)
	get:
		return jump_time_to_fall
		
## The value represents a velocity threshold that determines whether the character can jump
@export var jump_hang_threshold: float = 300.0
## Jumps allowed to perform in a row
@export var allowed_jumps : int = 1
## Reduced amount of jump effectiveness at each iteration
@export var height_reduced_by_jump : int = 0
## An extra boost speed on velocity.x when jump
@export var jump_horizontal_boost: float = 0.0

## Enable the coyote jump
@export var coyote_jump_enabled: bool = true
## The time window this jump can be executed when the character is not on the floor
@export var coyote_jump_time_window: float = 0.15

@export_group("Wall Jump")
## Enable the wall jump action
@export var wall_jump_enabled : bool = false
## The force applied in the wall jump, this can be different as jump_height
@export var wall_jump_force: float = jump_height
## Defines whether the wall jump is counted as a jump in the overall count.
@export var wall_jump_count_as_jump: bool = false
## The maximum angle of deviation that a wall can have to allow the jump to be executed.
@export var maximum_permissible_wall_angle : float = 0.0

@export_group("Wall Slide")
# Enable the sliding when the character is on a wall
@export var wall_slide_enabled: bool = false
## Overrides the fall gravity and apply instead the wall_slide_gravity_value
@export var override_gravity_on_wall_slide: bool = true
## The gravity applied to start sliding on the wall until reach the floor
@export var wall_slide_gravity: float = 50.0

@export_group("Wall Climb")
## Enable the wall climb action
@export var wall_climb_enabled: bool = false
## Disables gravity so that climbing has no resistance when going up
@export var disable_gravity_on_wall_climb: bool = true
## The speed when climb upwards
@export var wall_climb_speed_up: float = 50.0
## The speed when climb downwards
@export var wall_climb_speed_down: float = 55.0
## The force applied when the time it can climb reachs the timeout
@export var wall_climb_fatigue_knockback: float = 100.0
## Window time range in which where you can be climbing without getting tired of it
@export var time_it_can_climb: float = 3.0
## Time that the climb action is disabled when the fatigue timeout is triggered.
@export var time_disabled_when_timeout: float = 0.7

@onready var jump_velocity: float = _calculate_jump_velocity()
@onready var jump_gravity: float =  _calculate_jump_gravity()
@onready var fall_gravity: float =  _calculate_fall_gravity()


var gravity_enabled: bool = true:
	set(value):
		if value != gravity_enabled:
			gravity_changed.emit(value)
			
		gravity_enabled = value


var is_inverted_gravity: bool = false:
	set(value):
		if value != is_inverted_gravity:
			inverted_gravity.emit(value)
			
		is_inverted_gravity = value


var is_wall_sliding: bool = false:
	set(value):
		if value != is_wall_sliding:
			if value:
				wall_slide_started.emit()
			else:
				wall_slide_finished.emit()
				
		is_wall_sliding = value

	
var is_wall_climbing: bool = false:
	set(value):
		if value != is_wall_climbing:
			if value:
				wall_climb_started.emit()
			else:
				wall_climb_finished.emit()
				
		is_wall_climbing = value

var suspend_gravity_timer: Timer
var temporary_gravity_timer: Timer
var coyote_timer: Timer
var wall_climb_timer: Timer
var jump_queue: Array[Vector2] = []


enum JUMP_TYPES {
	NORMAL,
	WALL_JUMP
}


func _ready():
	super._ready()
	_create_suspend_gravity_timer()
	_create_coyote_timer()
	_create_wall_climbing_timer()
	
	jumped.connect(on_jumped)
	wall_jumped.connect(on_wall_jumped)
	wall_climb_started.connect(on_wall_climb_started)
	wall_climb_finished.connect(on_wall_climb_finished)
	wall_slide_started.connect(on_wall_slide_started)
	wall_slide_finished.connect(on_wall_slide_finished)


func move() -> void:
	var was_on_floor: bool = body.is_on_floor()
	super.move()
	
	var just_left_edge = was_on_floor and not body.is_on_floor()
	
	if coyote_jump_enabled and just_left_edge and is_falling():
		coyote_time_started.emit()
		

func accelerate_horizontally(direction: Vector2, delta: float =  get_physics_process_delta_time()) -> GodotEssentialsPlatformerMovementComponent:
	facing_direction = _normalize_vector(direction)
	
	if not direction.is_zero_approx():
		last_faced_direction = direction
		
		if ACCELERATION > 0:
			velocity.x = lerp(velocity.x, direction.x * MAX_SPEED, (ACCELERATION / 100) * delta)
		else:
			velocity.x = direction.x * MAX_SPEED
		
	return self


func decelerate_horizontally(delta: float = get_physics_process_delta_time(), force_stop: bool = false) -> GodotEssentialsPlatformerMovementComponent:
	if force_stop or FRICTION == 0:
		velocity.x = 0
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	return self


func accelerate_vertically(direction: Vector2, delta: float =  get_physics_process_delta_time()) -> GodotEssentialsPlatformerMovementComponent:
	facing_direction = _normalize_vector(direction)
	
	if not direction.is_zero_approx():
		last_faced_direction = direction
		
		if ACCELERATION > 0:
			velocity.y = lerp(velocity.y, direction.y * MAX_SPEED, (ACCELERATION / 100) * delta)
		else:
			velocity.y = direction.y * MAX_SPEED
		
	return self



func decelerate_vertically(delta: float = get_physics_process_delta_time(), force_stop: bool = false) -> GodotEssentialsPlatformerMovementComponent:
	if force_stop or AIR_FRICTION_VERTICAL_FACTOR == 1:
		velocity.y = 0
	else:
		velocity.y = move_toward(velocity.y, 0.0, AIR_FRICTION_VERTICAL_FACTOR * delta)

	return self


func get_gravity() -> float:
	if is_inverted_gravity:
		return jump_gravity if velocity.y > 0 else fall_gravity
	else:
		return jump_gravity if velocity.y < 0 else fall_gravity


func apply_gravity(delta: float = get_physics_process_delta_time()) -> GodotEssentialsPlatformerMovementComponent:
	if gravity_enabled:
		var gravity_force = get_gravity() * delta
		if is_inverted_gravity:
			gravity_force *= -1
			
		velocity.y += gravity_force

		if MAXIMUM_FALL_VELOCITY > 0:
			if is_inverted_gravity:
				velocity.y = max(velocity.y, -MAXIMUM_FALL_VELOCITY)
			else:
				velocity.y = min(velocity.y, absf(MAXIMUM_FALL_VELOCITY))	
			
	return self


func invert_gravity() -> GodotEssentialsPlatformerMovementComponent:
	if body and gravity_enabled:
		jump_velocity = -jump_velocity
		

		is_inverted_gravity = jump_velocity > 0
		body.up_direction = Vector2.DOWN if is_inverted_gravity else Vector2.UP
		
		inverted_gravity.emit(is_inverted_gravity)
	
	return self
	
	
func suspend_gravity_for_duration(duration: float) -> GodotEssentialsPlatformerMovementComponent:
	if duration > 0:
		gravity_enabled = false
		suspend_gravity_timer.stop()
		suspend_gravity_timer.wait_time = duration
		suspend_gravity_timer.start()
	
	return self


func change_gravity_temporary(gravity: float, time: float) -> GodotEssentialsPlatformerMovementComponent:
	if temporary_gravity_timer:
		temporary_gravity_timer.stop()
		temporary_gravity_timer.wait_time = max(0.05, absf(time))
		temporary_gravity_timer.start()
		
		temporary_gravity_started.emit(fall_gravity, gravity)
		fall_gravity = gravity
		
	return self


func can_jump() -> bool:
	var coyote_jump_active: bool = coyote_jump_enabled and coyote_timer.time_left > 0.0
	var available_jumps: bool = jump_queue.size() < allowed_jumps
	return available_jumps and (coyote_jump_active or is_withing_jump_hang_threshold())


func can_wall_jump() -> bool:
	var is_on_wall: bool =  wall_jump_enabled and body.is_on_wall()
	var available_jumps: bool = not wall_jump_count_as_jump or (wall_jump_count_as_jump and jump_queue.size() < allowed_jumps)
	
	return is_on_wall and available_jumps
		

func jump(height: float = jump_height, bypass: bool = false) -> GodotEssentialsPlatformerMovementComponent:
	if bypass or can_jump():
		var height_reduced: int =  max(0, jump_queue.size()) * height_reduced_by_jump
		velocity.y = _calculate_jump_velocity(height - height_reduced)
		if jump_horizontal_boost > 0:
			velocity.x += sign(velocity.x) + jump_horizontal_boost

		_add_position_to_jump_queue(body.global_position)
		jumped.emit(body.global_position)
		
	return self


func shorten_jump() -> void:
	var actual_velocity_y = velocity.y
	var new_jump_velocity = jump_velocity / 2

	if is_inverted_gravity:
		if actual_velocity_y > new_jump_velocity:
			velocity.y = new_jump_velocity
	else:
		if actual_velocity_y < new_jump_velocity:
			velocity.y = new_jump_velocity



func wall_jump(direction: Vector2, height: float = jump_height) -> GodotEssentialsPlatformerMovementComponent:
	var wall_normal: Vector2 = body.get_wall_normal()
	var left_angle: float = absf(wall_normal.angle_to(Vector2.LEFT))
	var right_angle: float = absf(wall_normal.angle_to(Vector2.RIGHT))
	
	velocity.x = wall_normal.x * wall_jump_force
	
	if not direction.is_zero_approx():
		velocity *= GodotEssentialsHelpers.normalize_vector(direction)
	jump(height, true)

	# if wall_jump_count_as_jump:
	# 	_add_position_to_jump_queue(body.global_position)

	wall_jumped.emit(wall_normal, body.global_position)
	
	return self


func can_wall_slide() -> bool:
	return wall_slide_enabled and body.is_on_wall()
	
	
func wall_slide(delta: float =  get_physics_process_delta_time()) -> GodotEssentialsPlatformerMovementComponent:
	if can_wall_slide():
		is_wall_sliding = true
		
		velocity.y += wall_slide_gravity * delta
		
		if is_inverted_gravity:
			velocity.y = max(velocity.y - wall_slide_gravity * delta, -wall_slide_gravity)
		else:
			velocity.y = min(velocity.y + wall_slide_gravity * delta, wall_slide_gravity)
	else:
		is_wall_sliding = false
	
	return self
	

func can_wall_climb() -> bool:
	return wall_climb_enabled and (is_wall_climbing or body.is_on_wall())
	
	
func wall_climb(direction: Vector2) -> GodotEssentialsPlatformerMovementComponent:
	if can_wall_climb():
		is_wall_climbing = true
		is_wall_sliding = false
		
		direction = _normalize_vector(direction)
		
		if direction.is_zero_approx():
			decelerate(true)
		else:
			var wall_climb_speed: float = 0.0
			match(direction):
				Vector2.UP:
					wall_climb_speed = wall_climb_speed_up
				Vector2.DOWN:
					wall_climb_speed = wall_climb_speed_down
			
			velocity.y = direction.y * wall_climb_speed
			
			if is_inverted_gravity:
				velocity.y *= -1
				
	return self
	
	
func reset_jump_queue() -> GodotEssentialsPlatformerMovementComponent:
	if not jump_queue.is_empty():
		jump_queue.clear()
		jumps_restarted.emit()
	
	return self
	

func is_withing_jump_hang_threshold() -> bool:
	var is_withing_threshold: bool = jump_hang_threshold == 0
	if jump_hang_threshold > 0:
		if is_inverted_gravity:
			is_withing_threshold = velocity.y > 0 or (velocity.y < -jump_hang_threshold)
		else:	
			is_withing_threshold = velocity.y < 0 or (velocity.y < jump_hang_threshold)
	return is_withing_threshold

	
func is_falling() -> bool:
	return not body.is_on_floor() \
		and gravity_enabled \
		and (velocity.y < 0 if is_inverted_gravity else velocity.y > 0)


func _add_position_to_jump_queue(position: Vector2):
	jump_queue.append(position)
	
	if jump_queue.size() == allowed_jumps:
		allowed_jumps_reached.emit(jump_queue)
	

func _calculate_jump_velocity(height: int = jump_height, time_to_peak: float = jump_time_to_peak):
	var y_axis = 1.0 if is_inverted_gravity else -1.0
	return ((2.0 * height) / time_to_peak) * y_axis
	
	
func _calculate_jump_gravity(height: int = jump_height, time_to_peak: float = jump_time_to_peak):
	return (2.0 * height) / pow(time_to_peak, 2) 
	
	
func _calculate_fall_gravity(height: int = jump_height, time_to_fall: float = jump_time_to_fall):
	return (2.0 * height) / pow(time_to_fall, 2) 
	

func _create_suspend_gravity_timer(time: float = DEFAULT_GRAVITY_SUSPEND_DURATION):
	if suspend_gravity_timer:
		return
		
	suspend_gravity_timer= Timer.new()
	suspend_gravity_timer.name = "SuspendGravityTimer"
	suspend_gravity_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	suspend_gravity_timer.wait_time = max(0.05, time)
	suspend_gravity_timer.one_shot = true
	suspend_gravity_timer.autostart = false
	
	add_child(suspend_gravity_timer)
	suspend_gravity_timer.timeout.connect(on_suspend_gravity_timeout)


func _create_coyote_timer():
	if coyote_timer:
		return
	
	coyote_timer = Timer.new()
	coyote_timer.name = "CoyoteTimer"
	coyote_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	coyote_timer.wait_time = coyote_jump_time_window
	coyote_timer.one_shot = true
	coyote_timer.autostart = false

	add_child(coyote_timer)
	coyote_time_started.connect(on_coyote_time_started)
	coyote_timer.timeout.connect(on_coyote_timer_timeout)


func _create_wall_climbing_timer(time: float = time_it_can_climb):
	if wall_climb_timer:
		return
		
	wall_climb_timer = Timer.new()
	wall_climb_timer.name = "WallClimbTimer"
	wall_climb_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	wall_climb_timer.wait_time = time
	wall_climb_timer.one_shot = true
	wall_climb_timer.autostart = false
	
	add_child(wall_climb_timer)
	wall_climb_timer.timeout.connect(on_wall_climb_timer_timeout)


func _create_temporary_gravity_timer(time: float = DEFAULT_TEMPORARY_GRAVITY_TIME):
	if temporary_gravity_timer:
			return
			
	temporary_gravity_timer = Timer.new()
	temporary_gravity_timer.name = "TemporaryGravityTimer"
	temporary_gravity_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	temporary_gravity_timer.wait_time = time
	temporary_gravity_timer.one_shot = true
	temporary_gravity_timer.autostart = false

	add_child(temporary_gravity_timer)
	temporary_gravity_timer.timeout.connect(on_temporary_gravity_timer_timeout.bind(fall_gravity))


func on_jumped(position: Vector2):
	is_wall_climbing = false
	is_wall_sliding = false
	
	coyote_timer.stop()


func on_wall_jumped(normal: Vector2, position: Vector2):
	if not normal.is_zero_approx():
		facing_direction = normal
		last_faced_direction = normal
		
	if not wall_jump_count_as_jump:
		jump_queue.pop_back()
		

func on_suspend_gravity_timeout():
	gravity_enabled = true


func on_wall_climb_started():
	if disable_gravity_on_wall_climb:
		gravity_enabled = false
		
	wall_climb_timer.start()


func on_wall_climb_finished():
	gravity_enabled = true
	wall_climb_timer.stop()


func on_wall_slide_started():
	if gravity_enabled and override_gravity_on_wall_slide:
		gravity_enabled = false


func on_wall_slide_finished():
	if override_gravity_on_wall_slide:
		gravity_enabled = true


func on_coyote_time_started():
	suspend_gravity_for_duration(coyote_jump_time_window)
	velocity.y = 0
	coyote_timer.start()


func on_coyote_timer_timeout():
	gravity_enabled = true
	coyote_time_finished.emit()


func on_wall_climb_timer_timeout():
	is_wall_climbing = false
	
	if wall_climb_fatigue_knockback > 0:
		knockback(Vector2(-sign(last_faced_direction.x), last_faced_direction.y), wall_climb_fatigue_knockback)
	
	if time_disabled_when_timeout > 0:
		wall_climb_enabled = false
		await (get_tree().create_timer(time_disabled_when_timeout)).timeout
		wall_climb_enabled = true


func on_temporary_gravity_timer_timeout(original_gravity: float):
	temporary_gravity_finished.emit()
	fall_gravity = original_gravity
