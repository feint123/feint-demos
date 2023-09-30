class_name GodotEssentialsPluginAudio extends Node

@onready var available_buses: Array = _enumerate_available_buses()


## Change the volume of selected bus_index if it exists
## Can receive the bus parameter as name or index
func change_volume(bus, value: float) -> void:
	if typeof(bus) == TYPE_STRING:
		bus = AudioServer.get_bus_index(bus)
		
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))


## Get the actual linear value from the selected bus by name
func get_actual_volume_db_from_bus_name(name: String) -> float:
	var bus_index: int = AudioServer.get_bus_index(name)
	
	if bus_index == -1:
		push_error("Godot2DEssentialsPlugin: Cannot retrieve volume for bus name {name}, it does not exists".format({"name": name}))
		return 0.0
		
	return db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(name)))

## Get the actual linear value from the selected bus by its index
func get_actual_volume_db_from_bus_index(bus_index: int) -> float:
	return db_to_linear(AudioServer.get_bus_volume_db(bus_index))

## Get a list of available buses by name
func _enumerate_available_buses() -> Array:
	return range(AudioServer.bus_count).map(func(bus_index: int): return AudioServer.get_bus_name(bus_index))
