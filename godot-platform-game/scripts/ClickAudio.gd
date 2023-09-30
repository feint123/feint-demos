extends Node2D


@onready var click_player = $ClickPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
		click_player.play()
