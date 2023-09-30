extends CenterContainer

@onready var resume_button:Button = %ResumeButton

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

		
func _unhandled_input(event):
	if event.is_action_pressed("menu") and visible:
		get_viewport().set_input_as_handled()
		resume_button.emit_signal("pressed")

func resume_focus():
	resume_button.grab_focus()


func _on_resume_button_pressed():
	_resume()

func _resume():
	visible = false
	get_tree().paused = false

func _on_return_button_pressed():
	_resume()
	EzTransitions.set_easing(0, 1)
	EzTransitions.set_trans(2, 2)
	EzTransitions.set_timers(1, 0, 1)
	EzTransitions.set_reverse(false, true)
	EzTransitions.set_textures("res://addons/ez_transitions/images/black_texture.png", "res://addons/ez_transitions/images/black_texture.png")
	EzTransitions.set_types(4, 4)
	EzTransitions.change_scene("res://scenes/ui/main_menu.tscn")
