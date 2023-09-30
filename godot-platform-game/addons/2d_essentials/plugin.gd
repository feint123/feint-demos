@tool
extends EditorPlugin

const PLUGIN_PREFIX = "GodotEssentials"

var SETTINGS_BASE = "{project_name}/config".format({"project_name": ProjectSettings.get_setting("application/config/name")})
var DEFAULT_SETTINGS = [
	{
		"name": SETTINGS_BASE + "/achievements/local_source",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"value": "res://",
	},
		{
		"name": SETTINGS_BASE + "/achievements/remote_source",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"value": "https://"
	},
	{
		"name": SETTINGS_BASE + "/achievements/save_directory",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"value": OS.get_user_data_dir()
	},
	{
		"name": SETTINGS_BASE + "/achievements/save_file_name",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"value": "achievements.json"
	},
	{
		"name": SETTINGS_BASE + "/achievements/password",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"value": ""
	},
	{
		"name": SETTINGS_BASE + "/godotenv/root_directory",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"value": "res://"
	}
]


var update_dialog_scene: UpdateGodot2DEssentialsButton

func _enter_tree():
	add_autoload_singleton(_add_prefix("Helpers"), "res://addons/2d_essentials/autoload/helpers.gd")
	add_autoload_singleton(_add_prefix("Audio"), "res://addons/2d_essentials/autoload/audio/audio.gd")
	add_autoload_singleton(_add_prefix("SceneTransitioner"), "res://addons/2d_essentials/autoload/scene_transitions/scene_transitioner.gd")
	add_autoload_singleton(_add_prefix("Achievements"), "res://addons/2d_essentials/autoload/achievements/achievements.tscn")
	add_autoload_singleton(_add_prefix("Environment"), "res://addons/2d_essentials/autoload/dotenv/godotenv.gd")
	add_custom_type(_add_prefix("SceneTransition"), "Node", preload("res://addons/2d_essentials/autoload/scene_transitions/scene_transition.gd"), preload("res://addons/2d_essentials/icons/video.png"))
	add_custom_type(_add_prefix("HealthComponent"), "Node", preload("res://addons/2d_essentials/survivability/health_component.gd"), preload("res://addons/2d_essentials/icons/suit_hearts.svg"))
	add_custom_type(_add_prefix("ShakeCameraComponent2D"), "Node2D", preload("res://addons/2d_essentials/camera/shake_camera_component.gd"), preload("res://addons/2d_essentials/icons/video.png"))
	add_custom_type(_add_prefix("RotatorComponent"), "Node2D", preload("res://addons/2d_essentials/movement/rotator_component.gd"), preload("res://addons/2d_essentials/icons/arrow_clockwise.svg"))
	add_custom_type(_add_prefix("ProjectileComponent"), "Node2D", preload("res://addons/2d_essentials/movement/rotator_component.gd"), preload("res://addons/2d_essentials/icons/bow.png"))
	add_custom_type(_add_prefix("FiniteStateMachine"), "Node", preload("res://addons/2d_essentials/patterns/finite_state_machine/finite_state_machine.gd"), preload("res://addons/2d_essentials/icons/share2.png"))
	add_custom_type(_add_prefix("State"), "Node", preload("res://addons/2d_essentials/patterns/finite_state_machine/state.gd"), preload("res://addons/2d_essentials/icons/target.png"))
	add_custom_type(_add_prefix("PlatformerMovementComponent"), "Node2D", preload("res://addons/2d_essentials/movement/motion/platformer_movement_component.gd"), preload("res://addons/2d_essentials/icons/target.png"))
	add_custom_type(_add_prefix("TopDownMovementComponent"), "Node2D", preload("res://addons/2d_essentials/movement/motion/top_down_movement_component.gd"), preload("res://addons/2d_essentials/icons/arrow_diagonal.png"))
	add_custom_type(_add_prefix("GridMovementComponent"), "Node2D", preload("res://addons/2d_essentials/movement/motion/grid_movement_component.gd"), preload("res://addons/2d_essentials/icons/menu_grid.png"))
	
	_setup_settings()
	_setup_update_notificator()
	

func _exit_tree():
	## AUTOLOAD ##
	remove_autoload_singleton(_add_prefix("Helpers"))
	remove_autoload_singleton(_add_prefix("Audio"))
	remove_autoload_singleton(_add_prefix("SceneTransitioner"))
	remove_autoload_singleton(_add_prefix("Achievements"))
	remove_autoload_singleton(_add_prefix("Environment"))
	## CUSTOM TYPES ##
	remove_custom_type(_add_prefix("SceneTransition"))
	remove_custom_type(_add_prefix("HealthComponent"))
	remove_custom_type(_add_prefix("ShakeCameraComponent2D"))
	remove_custom_type(_add_prefix("RotatorComponent"))
	remove_custom_type(_add_prefix("ProjectileComponent"))
	remove_custom_type(_add_prefix("FiniteStateMachine"))
	remove_custom_type(_add_prefix("State"))
	remove_custom_type(_add_prefix("PlatformerMovementComponent"))
	remove_custom_type(_add_prefix("TopDownMovementComponent"))
	remove_custom_type(_add_prefix("GridMovementComponent"))
	
	_remove_settings()
	_remove_update_notificator()


func _setup_update_notificator() -> void:
	update_dialog_scene = load("res://addons/2d_essentials/update/update_plugin_button.tscn").instantiate() as UpdateGodot2DEssentialsButton
	Engine.get_main_loop().root.call_deferred("add_child", update_dialog_scene)
	
	update_dialog_scene.editor_plugin = self
	

func _remove_update_notificator() -> void:
	if update_dialog_scene:
		Engine.get_main_loop().root.call_deferred("remove_child", update_dialog_scene)


func _setup_settings():
	for setting in DEFAULT_SETTINGS:
		if not ProjectSettings.has_setting(setting["name"]):
			if setting["name"].ends_with("password"):
				setting["value"] = GodotEssentialsPluginHelpers.new().generate_random_string(25)
				
			ProjectSettings.set_setting(setting["name"], setting["value"])
			ProjectSettings.add_property_info({"name": setting["name"], "type": setting["type"]})
	

func _remove_settings():
	for setting in DEFAULT_SETTINGS:
		if ProjectSettings.has_setting(setting["name"]):
			ProjectSettings.set_setting(setting["name"], null)
	
	
func _add_prefix(text: String) -> String:
	return "{prefix}{text}".format({"prefix": PLUGIN_PREFIX, "text": text}).strip_edges()
