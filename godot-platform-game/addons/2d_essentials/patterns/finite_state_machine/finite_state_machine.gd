class_name GodotEssentialsFiniteStateMachine extends Node

signal state_changed(from_state: GodotEssentialsState, state: GodotEssentialsState)
signal stack_pushed(new_state: GodotEssentialsState, stack:Array[GodotEssentialsState])
signal stack_flushed(flushed_states: Array[GodotEssentialsState])

@export var current_state: GodotEssentialsState = null
@export var stack_capacity: int = 3
@export var flush_stack_when_reach_capacity: bool = false
@export var enable_stack: bool = true

var states: Dictionary = {}
var states_stack: Array[GodotEssentialsState] = []
var locked: bool = false:
	set(value):
		if value != locked:
			if value:
				lock_state_machine()
			else:
				unlock_state_machine()
		locked = value
	
		
func _ready():
	_initialize_states_nodes()
	for initialized_state in states.values():
		initialized_state.state_finished.connect(on_finished_state)
	
	if current_state is GodotEssentialsState:
		change_state(current_state, {},  true)
	
	unlock_state_machine()
	
	stack_pushed.connect(on_stack_pushed)


func _unhandled_input(event):
	current_state.handle_input(event)


func _physics_process(delta):
	current_state.physics_update(delta)


func process(delta):
	current_state.update(delta)
		

func change_state(new_state: GodotEssentialsState,  params: Dictionary = {}, force: bool = false):
	if not force and current_state_is(new_state):
		return
	
	if current_state is GodotEssentialsState:
		exit_state(current_state)
	
	push_state_to_stack(current_state)
	state_changed.emit(current_state, new_state)
	
	current_state = new_state
	current_state.params = params
	enter_state(new_state)

	
func change_state_by_name(name: String, params: Dictionary = {}, force: bool = false):
	var new_state = get_state(name)
	
	if new_state:
		return change_state(new_state, params, force)
		
	push_error("Godot2DEssentialsPlugin: The state {name} does not exists on this FiniteStateMachine".format({"name": name}))


func enter_state(state: GodotEssentialsState):
	state._enter()
	state.state_entered.emit()
	

func exit_state(state: GodotEssentialsState):
	state._exit()


func push_state_to_stack(state: GodotEssentialsState) -> void:
	if enable_stack and stack_capacity > 0:
		if states_stack.size() >= stack_capacity:
			if flush_stack_when_reach_capacity:
				states_stack.clear()
				stack_flushed.emit(states_stack)
			else:
				states_stack.pop_front()
		
		states_stack.append(state)
		stack_pushed.emit(state, states_stack)
			

func get_state(name: String):
	if has_state(name):
		return states[name]
	
	return null


func has_state(name: String) -> bool:
	return states.has(name)
	

func current_state_is(state: GodotEssentialsState) -> bool:
	if state:
		return state.name.to_lower() == current_state.name.to_lower()
		
	return false


func current_state_name_is(name: String) -> bool:
	return current_state_is(get_state(name))


func lock_state_machine():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	set_process_unhandled_input(false)
	enable_stack = false
	

func unlock_state_machine():
	set_process(true)
	set_physics_process(true)
	set_process_input(true)
	set_process_unhandled_input(true)
	enable_stack = true

		
func _initialize_states_nodes(node: Node = null):
	var childrens = node.get_children(true) if node else get_children(true)
	
	for child in childrens:
		if child is GodotEssentialsState:
			_add_state_to_dictionary(child)
		else:
			_initialize_states_nodes(child)


func _add_state_to_dictionary(state: GodotEssentialsState):
	if state.is_inside_tree():
		states[state.name] = get_node(state.get_path())


func on_finished_state(next_state, params):
	if typeof(next_state) == TYPE_STRING:	
		change_state_by_name(next_state,  params, false)
		
	if next_state is GodotEssentialsState:
		change_state(next_state, params, false)


func on_stack_pushed(_new_state: GodotEssentialsState, stack:Array[GodotEssentialsState]):
	for state in states.values():
		if state is GodotEssentialsState:	
			state.previous_states = stack
