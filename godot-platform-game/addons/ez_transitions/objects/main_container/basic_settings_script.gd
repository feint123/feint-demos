@tool
extends MarginContainer

func _on_transitions_checkbox_toggled(button_pressed: bool) -> void:
	# Enabling or disabling all transitions.
	EzTransitions.plugin_toggle_transitions(button_pressed)
	
func _on_debug_checkbox_toggled(button_pressed: bool) -> void:
	# Enabling or disabling the plugin's debug mode.
	EzTransitions.plugin_toggle_debug_mode(button_pressed)
	
func _on_speed_spinbox_value_changed(value: float) -> void:
	# Updating the plugin's speed scale.
	EzTransitions.plugin_set_speed_scale(value)
