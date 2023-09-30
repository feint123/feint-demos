extends Node2D

@export var target_scene: PackedScene
@onready var new_game_button: Button = %NewGameButton
# Called when the node enters the scene tree for the first time.
func _ready():
	new_game_button.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass



func _on_new_game_button_pressed():
	EzTransitions.set_easing(0, 1)
	EzTransitions.set_trans(2, 2)
	EzTransitions.set_timers(1, 0, 1)
	EzTransitions.set_reverse(false, true)
	EzTransitions.set_textures("res://addons/ez_transitions/images/black_texture.png", "res://addons/ez_transitions/images/black_texture.png")
	EzTransitions.set_types(4, 4)
	EzTransitions.change_scene("res://scenes/levels/demo.tscn")



func _on_setting_button_pressed():
	EzTransitions.set_easing(0, 1)
	EzTransitions.set_trans(2, 2)
	EzTransitions.set_timers(1, 0, 1)
	EzTransitions.set_reverse(false, true)
	EzTransitions.set_textures("res://addons/ez_transitions/images/black_texture.png", "res://addons/ez_transitions/images/black_texture.png")
	EzTransitions.set_types(3, 4)
	EzTransitions.change_scene("res://scenes/ui/Settings.tscn")


func _on_exit_button_pressed():
	get_tree().quit()
