class_name GodotEssentialsPluginHelpers extends Node

signal frame_freezed

@onready var random_number_generator: RandomNumberGenerator = RandomNumberGenerator.new()

## Generate 'n' random directions on the angle range provided
## from an origin vector that will be rotated accordingly
# [Important] The angles needs to be on degrees
#
## [codeblock]
##	Globals2D.generate_random_directions_on_angle_range(Vector2.ZERO, -45, 45, 5)
## [/codeblock]
##
func generate_random_directions_on_angle_range(origin: Vector2 = Vector2.UP, min_angle_range: float = 0.0, max_angle_range: float = 360.0, num_directions: int = 10) -> Array[Vector2]:
	var random_directions: Array[Vector2] = []
	random_directions.resize(num_directions) # Improve performance if we know the final size
	
	var min_angle_range_in_rad = deg_to_rad(min_angle_range)
	var max_angle_range_in_rad = deg_to_rad(max_angle_range)
	
	for i in range(num_directions):
		var random_angle = generate_random_angle(min_angle_range_in_rad, max_angle_range_in_rad)
		random_directions.append(origin.rotated(random_angle))
		
	return random_directions

## Generate a random angle between a provided range
func generate_random_angle(min_angle_range: float = 0.0, max_angle_range: float = 360.0) -> float:
	return lerp(min_angle_range, max_angle_range, randf())


func generate_random_direction() -> Vector2:
	return Vector2(random_number_generator.randi_range(-1, 1), random_number_generator.randi_range(-1, 1)).normalized()


func translate_x_axis_to_vector(axis: float) -> Vector2:
	var horizontal_direction = Vector2.ZERO
	
	match axis:
		-1.0:
			horizontal_direction = Vector2.LEFT 
		1.0:
			horizontal_direction = Vector2.RIGHT
			
	return horizontal_direction


func normalize_vector(value: Vector2) -> Vector2:
	return value if value.is_normalized() else value.normalized()


func normalize_diagonal_vector(direction: Vector2) -> Vector2:
	if is_diagonal_direction(direction):
		return direction * sqrt(2)
	
	return direction


func is_diagonal_direction(direction: Vector2) -> bool:
	return direction.x != 0 and direction.y != 0
	

func frame_freeze(time_scale: float, duration: float):
	frame_freezed.emit()
	
	var original_value: float = Engine.time_scale
	
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale).timeout
	Engine.time_scale = original_value


func generate_random_string(length: int, characters: String =  "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"):
	var random_number_generator: RandomNumberGenerator = RandomNumberGenerator.new()
	var result = ""

	if not characters.is_empty() and length > 0:
		for i in range(length):
			result += characters[random_number_generator.randi() % characters.length()]

	return result

func is_valid_url(url: String) -> bool:
	var regex = RegEx.new()
	var url_pattern = "/(https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z]{2,}(\\.[a-zA-Z]{2,})(\\.[a-zA-Z]{2,})?\\/[a-zA-Z0-9]{2,}|((https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z]{2,}(\\.[a-zA-Z]{2,})(\\.[a-zA-Z]{2,})?)|(https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z0-9]{2,}\\.[a-zA-Z0-9]{2,}\\.[a-zA-Z0-9]{2,}(\\.[a-zA-Z0-9]{2,})?/g"
	regex.compile(url_pattern)
	
	return regex.search(url) != null
