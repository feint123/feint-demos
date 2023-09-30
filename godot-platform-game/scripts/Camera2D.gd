extends Camera2D

@onready var SCREEN_SIZE: Vector2 = get_viewport_rect().size
@onready var PLAYER: CharacterBody2D = get_parent() as Player
var current_screen: Vector2 = Vector2.ZERO


func _ready():
	top_level = true
	global_position = PLAYER.global_position
	_update_screen(current_screen)
	
	
func _physics_process(delta):
	var parent_screen: Vector2 = (PLAYER.global_position / SCREEN_SIZE).floor()
	if not parent_screen.is_equal_approx(current_screen):
		_update_screen(parent_screen)
	
	
func _update_screen(new_screen: Vector2):
	current_screen = new_screen
	global_position = current_screen * SCREEN_SIZE + SCREEN_SIZE * 0.5
	PLAYER.get_node("GodotEssentialsPlatformerMovementComponent").reset_dash_queue()
