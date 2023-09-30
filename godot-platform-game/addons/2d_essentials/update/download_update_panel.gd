@tool

extends Control

signal failed(response_code: int)
signal updated(new_version: String)

@onready var available_version_download_label = %VersionReleaseLabel
@onready var download_version_button = %DownloadVersionButton
@onready var http_request = $HTTPRequest


const ADDON_PATH = "res://addons/2d_essentials"
var TEMPORARY_FILE_NAME = OS.get_user_data_dir() + "2d_essentials_temp.zip"

var next_version_release: Dictionary:
	set(value):
		next_version_release = value
		available_version_download_label.text = value.tag_name.substr(1) + " is available for download!"
	get:
		return next_version_release

func save_downloaded_version_zip_file(body: PackedByteArray):
	var downloaded_version: FileAccess = FileAccess.open(TEMPORARY_FILE_NAME, FileAccess.WRITE)
	downloaded_version.store_buffer(body)
	downloaded_version.close()

func remove_downloaded_version_temporary_file():
	if FileAccess.file_exists(TEMPORARY_FILE_NAME):
		DirAccess.remove_absolute(TEMPORARY_FILE_NAME)

func remove_old_addon_version():
	if DirAccess.dir_exists_absolute(ADDON_PATH):
		DirAccess.remove_absolute(ADDON_PATH)

func install_new_addon_version():
	if FileAccess.file_exists(TEMPORARY_FILE_NAME):
		var zip_reader : ZIPReader = ZIPReader.new()
		zip_reader.open(TEMPORARY_FILE_NAME)
		
		var downloaded_version_files: PackedStringArray = zip_reader.get_files()
		
		var base_path: String = downloaded_version_files[1]
		
		# Remove the root base path and the addons base path
		# godotessentials-2d-essentials-e68fb3a/,
		# godotessentials-2d-essentials-e68fb3a/addons/
		downloaded_version_files.remove_at(0)
		downloaded_version_files.remove_at(0)
		
		for path in downloaded_version_files:
			var new_file_path: String = path.replace(base_path, "")
			if path.ends_with("/"):
				DirAccess.make_dir_recursive_absolute("res://addons/%s" % new_file_path)
			else:
				var file: FileAccess = FileAccess.open("res://addons/%s" % new_file_path, FileAccess.WRITE)
				file.store_buffer(zip_reader.read_file(path))

		zip_reader.close()
	
func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		failed.emit(response_code)
		return

	download_version_button.disabled = false
	download_version_button.text = "Download update"
	
	save_downloaded_version_zip_file(body)
	remove_old_addon_version()
	install_new_addon_version()
	remove_downloaded_version_temporary_file()
	
	updated.emit(next_version_release.tag_name.substr(1))

func _on_download_version_button_pressed():
	if FileAccess.file_exists("res://examples/.gitkeep"): 
		push_error("Godot2DEssentialsPlugin: You can't update the 2d essentials addon from within itself.")
		failed.emit(401)
		return
		
	if not next_version_release.is_empty():
		http_request.request(next_version_release.zipball_url)
		
		download_version_button.disabled = true
		download_version_button.text = "Downloading new version..."
	else:
		push_warning("Godot2DEssentialsPlugin: You're up to date with the latest version of the plugin")


func _on_read_release_notes_button_pressed():
	if not next_version_release.is_empty():
		OS.shell_open(next_version_release.html_url)



### EXAMPLE NEXT VERSION RELEASE DICTIONARY FROM GITHUB API
#{
#  "url": "https://api.github.com/repos/godotessentials/2d-essentials/releases/117140839",
#  "assets_url": "https://api.github.com/repos/godotessentials/2d-essentials/releases/117140839/assets",
#  "upload_url": "https://uploads.github.com/repos/godotessentials/2d-essentials/releases/117140839/assets{?name,label}",
#  "html_url": "https://github.com/godotessentials/2d-essentials/releases/tag/v1.0.4",
#  "id": 117140839,
#  "author": {
#    "login": "s3r0s4pi3ns",
#    "id": 105492707,
#    "node_id": "U_kgDOBkmw4w",
#    "avatar_url": "https://avatars.githubusercontent.com/u/105492707?v=4",
#    "gravatar_id": "",
#    "url": "https://api.github.com/users/s3r0s4pi3ns",
#    "html_url": "https://github.com/s3r0s4pi3ns",
#    "followers_url": "https://api.github.com/users/s3r0s4pi3ns/followers",
#    "following_url": "https://api.github.com/users/s3r0s4pi3ns/following{/other_user}",
#    "gists_url": "https://api.github.com/users/s3r0s4pi3ns/gists{/gist_id}",
#    "starred_url": "https://api.github.com/users/s3r0s4pi3ns/starred{/owner}{/repo}",
#    "subscriptions_url": "https://api.github.com/users/s3r0s4pi3ns/subscriptions",
#    "organizations_url": "https://api.github.com/users/s3r0s4pi3ns/orgs",
#    "repos_url": "https://api.github.com/users/s3r0s4pi3ns/repos",
#    "events_url": "https://api.github.com/users/s3r0s4pi3ns/events{/privacy}",
#    "received_events_url": "https://api.github.com/users/s3r0s4pi3ns/received_events",
#    "type": "User",
#    "site_admin": false
#  },
#  "node_id": "RE_kwDOKDC0bM4G-21n",
#  "tag_name": "v1.0.4",
#  "target_commitish": "main",
#  "name": "Test release",
#  "draft": false,
#  "prerelease": false,
#  "created_at": "2023-08-09T16:40:13Z",
#  "published_at": "2023-08-14T10:14:03Z",
#  "assets": [],
#  "tarball_url": "https://api.github.com/repos/godotessentials/2d-essentials/tarball/v1.0.4",
#  "zipball_url": "https://api.github.com/repos/godotessentials/2d-essentials/zipball/v1.0.4",
#  "body": "test"
#}


### EXAMPLE OF READING FILE PATHS ON DOWNLOADED VERSION
#[
#  "godotessentials-2d-essentials-e68fb3a/",
#  "godotessentials-2d-essentials-e68fb3a/addons/",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/Backpack.png",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/Backpack.png.import",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/Car.png",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/Car.png.import",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/MagnifyingGlass.png",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/MagnifyingGlass.png.import",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/autoload/",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/autoload/helpers.gd",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/camera/",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/camera/shake_camera_component.gd",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/camera/shake_camera_component.tscn",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/movement/",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/movement/rotator_component.gd",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/movement/rotator_component.tscn",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/movement/velocity_component_2d.gd",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/movement/velocity_component_2d.tscn",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/plugin.cfg",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/plugin.gd",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/survivability/",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/survivability/health_component.gd",
#  "godotessentials-2d-essentials-e68fb3a/addons/2d_essentials/survivability/health_component.tscn"
#]


