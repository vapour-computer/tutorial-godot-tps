extends Node


signal replace_main_scene

const LEVEL_PATH: String = "res://level/level.tscn"

var peer: MultiplayerPeer = OfflineMultiplayerPeer.new()

@onready var world_environment: WorldEnvironment = $WorldEnvironment

@onready var ui: Control = $UI
@onready var main: Control = ui.get_node(^"Main")
@onready var play_button: Button = main.get_node(^"Play")

@onready var online: Control = ui.get_node(^"Online")
@onready var online_port: SpinBox = online.get_node(^"Port")
@onready var online_address: LineEdit = online.get_node(^"Address")

@onready var settings_panel: SettingsPanel = ui.get_node(^"Settings")

@onready var loading: HBoxContainer = ui.get_node(^"Loading")
@onready var loading_progress: ProgressBar = loading.get_node(^"Progress")
@onready var loading_done_timer: Timer = loading.get_node(^"DoneTimer")


func _ready() -> void:
	# Apply relevant settings directly.
	Settings.apply_graphics_settings(get_window(), world_environment.environment, self)
	settings_panel.configure(world_environment.environment, self)
	settings_panel.closed.connect(_on_settings_panel_closed)

	if DisplayServer.get_name() == "headless":
		_on_host_pressed.call_deferred()

	play_button.grab_focus()


func _process(_delta: float) -> void:
	if loading.visible:
		var progress: Array = []
		var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(LEVEL_PATH, progress)
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			loading_progress.value = progress[0] * 100.0
		elif status == ResourceLoader.THREAD_LOAD_LOADED:
			loading_progress.value = 100.0
			set_process(false)
			loading_done_timer.start()
		else:
			print("Error while loading level: " + str(status))
			main.show()
			loading.hide()


func _on_loading_done_timer_timeout() -> void:
	multiplayer.multiplayer_peer = peer
	emit_signal("replace_main_scene", ResourceLoader.load_threaded_get(LEVEL_PATH))


func _on_play_pressed() -> void:
	main.hide()
	loading.show()
	ResourceLoader.load_threaded_request(LEVEL_PATH, "", true)


func _on_settings_pressed() -> void:
	main.hide()
	online.hide()
	settings_panel.open_panel()


func _on_settings_panel_closed() -> void:
	main.show()
	play_button.grab_focus()
	online.hide()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_cancel_pressed() -> void:
	main.show()
	play_button.grab_focus()
	online.hide()
	if settings_panel.visible:
		settings_panel.close_panel()


func _on_play_online_pressed() -> void:
	online.show()
	main.hide()


func _on_host_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(int(online_port.value))
	_on_play_pressed()
	online.hide()


func _on_connect_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(online_address.text, int(online_port.value))
	_on_play_pressed()
	online.hide()
