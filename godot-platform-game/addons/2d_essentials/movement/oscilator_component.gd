@tool

class_name OscilatorComponent extends Node2D

@export var active: bool = true
@export var speed: float = 5.0
@export var frequency: float = 2.0
@export var amplitude: float = 2.5

@onready var parent_node = get_parent()
@onready var childrens = get_children()

var offset: float = 0.0

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	var parent_node = get_parent()
	var childrens = get_child_count()
	
	if (parent_node == null or parent_node and not parent_node is Node2D) and childrens == 0:
			warnings.append("This component needs a Node2D parent or at least 1 child in order to work")
	
	return warnings
	
	
func _process(delta):
	if active and not Engine.is_editor_hint():
		offset += delta
		
		if parent_node:
			apply_oscilation(parent_node, delta)

		for child in childrens:
			apply_oscilation(child, delta)


func apply_oscilation(node: Node2D, delta: float = get_process_delta_time()):
	node.position += (node.transform.x * speed * delta) + (node.transform.y * cos(offset * frequency) * amplitude)
