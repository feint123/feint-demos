@tool

class_name RotatorComponent extends Node2D

@export var rotation_degrees_per_second = 5
@export var active: bool = true
@export var clockwise: bool = true

@onready var parent_node = get_parent()
@onready var childrens = get_children()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	var parent_node = get_parent()
	var childrens = get_child_count()
	
	if (parent_node == null or parent_node and not parent_node is Node2D) and childrens == 0:
			warnings.append("This component needs a Node2D parent or at least 1 child in order to work")
	
	return warnings
	
	
func _process(delta):
	if active:
		var rotation_speed = (rotation_degrees_per_second if clockwise else rotation_degrees_per_second * -1) * delta
		
		if parent_node and parent_node is Node2D:
			parent_node.rotation += rotation_speed
			
		if childrens.size() > 0:
			for child in childrens:
				if child is Node2D:
					child.rotation += rotation_speed


