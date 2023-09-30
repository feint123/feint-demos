extends Node2D

@onready var pause_scene = $CanvasLayer/PauseOverlay
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("menu") and not pause_scene.visible:
		get_viewport().set_input_as_handled()
		get_tree().paused = true
		pause_scene.resume_focus()
		pause_scene.visible = true
	


func _on_player_player_dead():
	# 触发死亡转场，player返回到复活点
	EzTransitions.set_easing(0, 1)
	EzTransitions.set_trans(2, 2)
	EzTransitions.set_timers(1, 0, 1)
	EzTransitions.set_reverse(false, true)
	EzTransitions.set_textures("res://addons/ez_transitions/images/black_texture.png", "res://addons/ez_transitions/images/black_texture.png")
	EzTransitions.set_types(1, 1)
	EzTransitions.change_scene("res://scenes/levels/demo.tscn")
