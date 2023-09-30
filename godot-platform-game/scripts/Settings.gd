extends Control

@onready var return_button:Button = %ReturnButton

# Called when the node enters the scene tree for the first time.
func _ready():
	return_button.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_return_button_pressed():
	EzTransitions.set_easing(0, 1)
	EzTransitions.set_trans(2, 2)
	EzTransitions.set_timers(1, 0, 1)
	EzTransitions.set_reverse(false, true)
	EzTransitions.set_textures("res://addons/ez_transitions/images/black_texture.png", "res://addons/ez_transitions/images/black_texture.png")
	EzTransitions.set_types(3, 4)
	EzTransitions.change_scene("res://scenes/ui/main_menu.tscn")
