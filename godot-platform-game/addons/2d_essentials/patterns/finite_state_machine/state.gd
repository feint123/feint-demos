class_name GodotEssentialsState extends Node

signal state_entered
signal state_finished(next_state, params: Dictionary)

var previous_states: Array[GodotEssentialsState] = []
var params: Dictionary = {}

func _enter() -> void:
	pass
	

func _exit() -> void:
	pass
	

func handle_input(_event):
	pass	


func physics_update(_delta):
	pass
	
	
func update(_delta):
	pass
	

func _on_animation_player_finished(name: String):
	pass


func _on_animation_finished():
	pass
