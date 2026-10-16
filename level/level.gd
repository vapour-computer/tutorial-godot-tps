extends Node3D


signal quit

const RedRobot: PackedScene = preload("res://enemies/red_robot/red_robot.tscn")
const PlayerScene: PackedScene = preload("res://player/player.tscn")
const SettingsPanelScene: PackedScene = preload("res://menu/settings_panel.tscn")

var lightmap_gi: LightmapGI = null
var level_settings_panel: SettingsPanel = null
var last_pointer_was_real_mouse: bool = false

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var robot_spawn_points: Node3D = $RobotSpawnpoints
@onready var player_spawn_points: Node3D = $PlayerSpawnpoints
@onready var spawned_nodes: Node3D = $SpawnedNodes


func _ready() -> void:
	Settings.apply_graphics_settings(get_window(), world_environment.environment, self)
	_setup_level_settings_menu()

	if Settings.config_file.get_value("rendering", "gi_type") == Settings.GIType.SDFGI:
		setup_sdfgi()
	elif Settings.config_file.get_value("rendering", "gi_type") == Settings.GIType.VOXEL_GI:
		setup_voxelgi()
	else:
		setup_lightmapgi()

	if multiplayer.is_server():
		# Server will spawn the red robots
		for child in robot_spawn_points.get_children():
			spawn_robot(child)

		# Then spawn already connected players at random location
		randomize()
		var spawn_points = player_spawn_points.get_children()
		spawn_points.shuffle()
		add_player(1, spawn_points.pop_front())
		for id in multiplayer.get_peers():
			add_player(id, spawn_points.pop_front())

		# Then spawn/despawn players as they connect/disconnect
		multiplayer.peer_connected.connect(add_player)
		multiplayer.peer_disconnected.connect(del_player)


func _setup_level_settings_menu() -> void:
	level_settings_panel = SettingsPanelScene.instantiate()
	level_settings_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	level_settings_panel.configure(world_environment.environment, self)
	level_settings_panel.set_quit_action_enabled(true, "BACK TO MENU")
	level_settings_panel.closed.connect(_close_level_settings)
	level_settings_panel.quit_requested.connect(_quit_to_main_menu)
	level_settings_panel.pointer_source_changed.connect(_on_settings_pointer_source_changed)
	var layer := CanvasLayer.new()
	layer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	layer.layer = 100
	layer.add_child(level_settings_panel)
	add_child(layer)


func _open_level_settings() -> void:
	if level_settings_panel == null:
		return
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	level_settings_panel.open_panel()


func _close_level_settings() -> void:
	if level_settings_panel == null:
		return
	if level_settings_panel.visible:
		level_settings_panel.hide()
	get_tree().paused = false
	if last_pointer_was_real_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _quit_to_main_menu() -> void:
	_close_level_settings()
	quit.emit()


func _on_settings_pointer_source_changed(real_mouse: bool) -> void:
	last_pointer_was_real_mouse = real_mouse


func setup_sdfgi() -> void:
	world_environment.environment.sdfgi_enabled = true
	$VoxelGI.hide()
	$ReflectionProbes.hide()
	# LightmapGI nodes override SDFGI (even when hidden)
	# so we need to free the LightmapGI node if it exists
	if lightmap_gi != null:
		lightmap_gi.queue_free()

	if Settings.config_file.get_value("rendering", "gi_quality") == Settings.GIQuality.HIGH:
		RenderingServer.environment_set_sdfgi_ray_count(RenderingServer.ENV_SDFGI_RAY_COUNT_96)
	elif Settings.config_file.get_value("rendering", "gi_quality") == Settings.GIQuality.LOW:
		RenderingServer.environment_set_sdfgi_ray_count(RenderingServer.ENV_SDFGI_RAY_COUNT_32)
	else:
		world_environment.environment.sdfgi_enabled = false


func setup_voxelgi() -> void:
	world_environment.environment.sdfgi_enabled = false
	$VoxelGI.show()
	$ReflectionProbes.hide()
	# LightmapGI nodes override VoxelGI (even when hidden)
	# so we need to free the LightmapGI node if it exists
	if lightmap_gi != null:
		lightmap_gi.queue_free()

	if Settings.config_file.get_value("rendering", "gi_quality") == Settings.GIQuality.HIGH:
		RenderingServer.voxel_gi_set_quality(RenderingServer.VOXEL_GI_QUALITY_HIGH)
	elif Settings.config_file.get_value("rendering", "gi_quality") == Settings.GIQuality.LOW:
		RenderingServer.voxel_gi_set_quality(RenderingServer.VOXEL_GI_QUALITY_LOW)
	else:
		$VoxelGI.hide()


func setup_lightmapgi() -> void:
	world_environment.environment.sdfgi_enabled = false
	$VoxelGI.hide()
	$ReflectionProbes.show()
	# If no LightmapGI node, create one
	if lightmap_gi == null:
		var new_gi := LightmapGI.new()
		new_gi.light_data = load("res://level/level.lmbake")
		new_gi.name = "LightmapGI"
		lightmap_gi = new_gi
		add_child(new_gi)

	if Settings.config_file.get_value("rendering", "gi_quality") == Settings.GIQuality.DISABLED:
		lightmap_gi.hide()
		$ReflectionProbes.hide()


func spawn_robot(spawn_point) -> void:
	var robot: CharacterBody3D = RedRobot.instantiate()
	robot.transform = spawn_point.transform
	robot.exploded.connect(_respawn_robot.bind(spawn_point))
	spawned_nodes.add_child(robot, true)


func _respawn_robot(spawn_point) -> void:
	await get_tree().create_timer(15.0).timeout
	spawn_robot(spawn_point)


func del_player(id: int) -> void:
	if not spawned_nodes.has_node(str(id)):
		return
	spawned_nodes.get_node(str(id)).queue_free()


func add_player(id: int, spawn_point: Marker3D = null) -> void:
	if spawn_point == null:
		spawn_point = player_spawn_points.get_child(randi() % player_spawn_points.get_child_count())
	var player: CharacterBody3D = PlayerScene.instantiate()
	player.name = str(id)
	player.player_id = id
	player.transform = spawn_point.transform
	spawned_nodes.add_child(player)


func _input(input_event: InputEvent) -> void:
	if input_event is InputEventMouseButton and input_event.is_pressed():
		var mouse_event := input_event as InputEventMouseButton
		last_pointer_was_real_mouse = mouse_event.device != InputEvent.DEVICE_ID_EMULATION

	if input_event.is_action_pressed(&"quit"):
		get_viewport().set_input_as_handled()
		if not get_tree().paused:
			_open_level_settings()
