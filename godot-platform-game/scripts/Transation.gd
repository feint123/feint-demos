extends GodotEssentialsSceneTransition



@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	animation_player.animation_finished.connect(on_animation_finished)
	animation_player.play(data["animation"])
	
func on_animation_finished(name: String):
	if name in animation_player.get_animation_list():
		finished_transition.emit(data, null)
		queue_free()
