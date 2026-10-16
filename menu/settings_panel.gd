class_name SettingsPanel
extends VBoxContainer


signal closed
signal quit_requested
signal pointer_source_changed(real_mouse: bool)

var metalfx_supported: bool = RenderingServer.get_current_rendering_driver_name() == "metal"
var target_environment: Environment
var target_scene_root: Node
var quit_action_button: Button = null

@onready var settings_actions: HBoxContainer = get_node(^"Actions")
@onready var settings_action_apply: Button = settings_actions.get_node(^"Apply")
@onready var settings_action_cancel: Button = settings_actions.get_node(^"Cancel")

@onready var display_mode_menu: HBoxContainer = get_node(^"DisplayMode")
@onready var display_mode_windowed: Button = display_mode_menu.get_node(^"Windowed")
@onready var display_mode_fullscreen: Button = display_mode_menu.get_node(^"Fullscreen")
@onready var display_mode_exclusive_fullscreen: Button = display_mode_menu.get_node(^"ExclusiveFullscreen")

@onready var vsync_menu: HBoxContainer = get_node(^"VSync")
@onready var vsync_disabled: Button = vsync_menu.get_node(^"Disabled")
@onready var vsync_enabled: Button = vsync_menu.get_node(^"Enabled")
@onready var vsync_adaptive: Button = vsync_menu.get_node(^"Adaptive")
@onready var vsync_mailbox: Button = vsync_menu.get_node(^"Mailbox")

@onready var max_fps_menu: HBoxContainer = get_node(^"MaxFPS")
@onready var max_fps_30: Button = max_fps_menu.get_node(^"30")
@onready var max_fps_40: Button = max_fps_menu.get_node(^"40")
@onready var max_fps_60: Button = max_fps_menu.get_node(^"60")
@onready var max_fps_72: Button = max_fps_menu.get_node(^"72")
@onready var max_fps_90: Button = max_fps_menu.get_node(^"90")
@onready var max_fps_120: Button = max_fps_menu.get_node(^"120")
@onready var max_fps_144: Button = max_fps_menu.get_node(^"144")
@onready var max_fps_unlimited: Button = max_fps_menu.get_node(^"Unlimited")

@onready var resolution_scale_menu: HBoxContainer = get_node(^"ResolutionScale")
@onready var resolution_scale_ultra_performance: Button = resolution_scale_menu.get_node(^"UltraPerformance")
@onready var resolution_scale_performance: Button = resolution_scale_menu.get_node(^"Performance")
@onready var resolution_scale_balanced: Button = resolution_scale_menu.get_node(^"Balanced")
@onready var resolution_scale_quality: Button = resolution_scale_menu.get_node(^"Quality")
@onready var resolution_scale_ultra_quality: Button = resolution_scale_menu.get_node(^"UltraQuality")
@onready var resolution_scale_native: Button = resolution_scale_menu.get_node(^"Native")

@onready var scale_filter_menu: HBoxContainer = get_node(^"ScaleFilter")
@onready var scale_filter_nearest: Button = scale_filter_menu.get_node(^"Nearest")
@onready var scale_filter_bilinear: Button = scale_filter_menu.get_node(^"Bilinear")
@onready var scale_filter_fsr1: Button = scale_filter_menu.get_node(^"FSR1")
@onready var scale_filter_metalfx_spatial: Button = scale_filter_menu.get_node(^"MetalFXSpatial")
@onready var scale_filter_fsr2: Button = scale_filter_menu.get_node(^"FSR2")
@onready var scale_filter_metalfx_temporal: Button = scale_filter_menu.get_node(^"MetalFXTemporal")

@onready var taa_menu: HBoxContainer = get_node(^"TAA")
@onready var taa_disabled: Button = taa_menu.get_node(^"Disabled")
@onready var taa_enabled: Button = taa_menu.get_node(^"Enabled")

@onready var msaa_menu: HBoxContainer = get_node(^"MSAA")
@onready var msaa_disabled: Button = msaa_menu.get_node(^"Disabled")
@onready var msaa_2x: Button = msaa_menu.get_node(^"2X")
@onready var msaa_4x: Button = msaa_menu.get_node(^"4X")
@onready var msaa_8x: Button = msaa_menu.get_node(^"8X")

@onready var screen_space_aa_menu: HBoxContainer = get_node(^"ScreenSpaceAA")
@onready var screen_space_aa_disabled: Button = screen_space_aa_menu.get_node(^"Disabled")
@onready var screen_space_aa_fxaa: Button = screen_space_aa_menu.get_node(^"FXAA")
@onready var screen_space_aa_smaa: Button = screen_space_aa_menu.get_node(^"SMAA")

@onready var shadow_mapping_menu: HBoxContainer = get_node(^"ShadowMapping")
@onready var shadow_mapping_disabled: Button = shadow_mapping_menu.get_node(^"Disabled")
@onready var shadow_mapping_enabled: Button = shadow_mapping_menu.get_node(^"Enabled")

@onready var gi_type_menu: HBoxContainer = get_node(^"GIType")
@onready var gi_lightmapgi: Button = gi_type_menu.get_node(^"LightmapGI")
@onready var gi_voxelgi: Button = gi_type_menu.get_node(^"VoxelGI")
@onready var gi_sdfgi: Button = gi_type_menu.get_node(^"SDFGI")

@onready var gi_quality_menu: HBoxContainer = get_node(^"GIQuality")
@onready var gi_disabled: Button = gi_quality_menu.get_node(^"Disabled")
@onready var gi_low: Button = gi_quality_menu.get_node(^"Low")
@onready var gi_high: Button = gi_quality_menu.get_node(^"High")

@onready var ssao_menu: HBoxContainer = get_node(^"SSAO")
@onready var ssao_disabled: Button = ssao_menu.get_node(^"Disabled")
@onready var ssao_medium: Button = ssao_menu.get_node(^"Medium")
@onready var ssao_high: Button = ssao_menu.get_node(^"High")

@onready var ssil_menu: HBoxContainer = get_node(^"SSIL")
@onready var ssil_disabled: Button = ssil_menu.get_node(^"Disabled")
@onready var ssil_medium: Button = ssil_menu.get_node(^"Medium")
@onready var ssil_high: Button = ssil_menu.get_node(^"High")

@onready var bloom_menu: HBoxContainer = get_node(^"Bloom")
@onready var bloom_disabled: Button = bloom_menu.get_node(^"Disabled")
@onready var bloom_enabled: Button = bloom_menu.get_node(^"Enabled")

@onready var volumetric_fog_menu: HBoxContainer = get_node(^"VolumetricFog")
@onready var volumetric_fog_disabled: Button = volumetric_fog_menu.get_node(^"Disabled")
@onready var volumetric_fog_enabled: Button = volumetric_fog_menu.get_node(^"Enabled")


func _ready() -> void:
	for menu in [
		display_mode_menu, vsync_menu, max_fps_menu, resolution_scale_menu, scale_filter_menu,
		taa_menu, msaa_menu, screen_space_aa_menu, shadow_mapping_menu, gi_type_menu, gi_quality_menu,
		ssao_menu, ssil_menu, bloom_menu, volumetric_fog_menu,
	]:
		_make_button_group(menu)

	if not metalfx_supported:
		scale_filter_metalfx_spatial.hide()
		scale_filter_metalfx_temporal.hide()

	settings_action_apply.pressed.connect(_on_apply_pressed)
	settings_action_cancel.pressed.connect(_on_cancel_pressed)


func configure(environment: Environment, scene_root: Node) -> void:
	target_environment = environment
	target_scene_root = scene_root


func set_quit_action_enabled(enabled: bool, text: String = "BACK TO MENU") -> void:
	if enabled:
		if quit_action_button == null:
			quit_action_button = Button.new()
			quit_action_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			quit_action_button.pressed.connect(_on_quit_requested)
			settings_actions.add_child(quit_action_button)
		quit_action_button.text = text
		quit_action_button.show()
	else:
		if quit_action_button != null:
			quit_action_button.hide()


func open_panel() -> void:
	show()
	_sync_buttons_from_settings()
	settings_action_cancel.grab_focus()


func close_panel() -> void:
	hide()
	closed.emit()


func _input(input_event: InputEvent) -> void:
	if not visible:
		return
	if input_event is InputEventMouseButton and input_event.is_pressed():
		var mouse_event := input_event as InputEventMouseButton
		pointer_source_changed.emit(mouse_event.device != InputEvent.DEVICE_ID_EMULATION)
	if input_event.is_action_pressed(&"quit") or input_event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_cancel_pressed()


func _make_button_group(common_parent: Node) -> void:
	var group = ButtonGroup.new()
	for btn in common_parent.get_children():
		if not btn is BaseButton:
			continue
		btn.button_group = group


func _sync_buttons_from_settings() -> void:
	if (
			Settings.config_file.get_value("video", "display_mode") == Window.MODE_WINDOWED
			or Settings.config_file.get_value("video", "display_mode") == Window.MODE_MAXIMIZED
	):
		display_mode_windowed.button_pressed = true
	elif Settings.config_file.get_value("video", "display_mode") == Window.MODE_FULLSCREEN:
		display_mode_fullscreen.button_pressed = true
	else:
		display_mode_exclusive_fullscreen.button_pressed = true

	if Settings.config_file.get_value("video", "vsync") == DisplayServer.VSYNC_DISABLED:
		vsync_disabled.button_pressed = true
	elif Settings.config_file.get_value("video", "vsync") == DisplayServer.VSYNC_ENABLED:
		vsync_enabled.button_pressed = true
	elif Settings.config_file.get_value("video", "vsync") == DisplayServer.VSYNC_ADAPTIVE:
		vsync_adaptive.button_pressed = true
	else:
		vsync_mailbox.button_pressed = true

	if Settings.config_file.get_value("video", "max_fps") == 30:
		max_fps_30.button_pressed = true
	elif Settings.config_file.get_value("video", "max_fps") == 40:
		max_fps_40.button_pressed = true
	elif Settings.config_file.get_value("video", "max_fps") == 60:
		max_fps_60.button_pressed = true
	elif Settings.config_file.get_value("video", "max_fps") == 72:
		max_fps_72.button_pressed = true
	elif Settings.config_file.get_value("video", "max_fps") == 90:
		max_fps_90.button_pressed = true
	elif Settings.config_file.get_value("video", "max_fps") == 120:
		max_fps_120.button_pressed = true
	elif Settings.config_file.get_value("video", "max_fps") == 144:
		max_fps_144.button_pressed = true
	else:
		max_fps_unlimited.button_pressed = true

	if is_equal_approx(Settings.config_file.get_value("video", "resolution_scale"), 1.0 / 3.0):
		resolution_scale_ultra_performance.button_pressed = true
	elif is_equal_approx(Settings.config_file.get_value("video", "resolution_scale"), 1.0 / 2.0):
		resolution_scale_performance.button_pressed = true
	elif is_equal_approx(Settings.config_file.get_value("video", "resolution_scale"), 1.0 / 1.7):
		resolution_scale_balanced.button_pressed = true
	elif is_equal_approx(Settings.config_file.get_value("video", "resolution_scale"), 1.0 / 1.5):
		resolution_scale_quality.button_pressed = true
	elif is_equal_approx(Settings.config_file.get_value("video", "resolution_scale"), 1.0 / 1.3):
		resolution_scale_ultra_quality.button_pressed = true
	else:
		resolution_scale_native.button_pressed = true

	if Settings.config_file.get_value("video", "scale_filter") == Viewport.SCALING_3D_MODE_NEAREST:
		scale_filter_nearest.button_pressed = true
	elif Settings.config_file.get_value("video", "scale_filter") == Viewport.SCALING_3D_MODE_BILINEAR:
		scale_filter_bilinear.button_pressed = true
	elif Settings.config_file.get_value("video", "scale_filter") == Viewport.SCALING_3D_MODE_FSR:
		scale_filter_fsr1.button_pressed = true
	elif Settings.config_file.get_value("video", "scale_filter") == Viewport.SCALING_3D_MODE_FSR2:
		scale_filter_fsr2.button_pressed = true
	elif Settings.config_file.get_value("video", "scale_filter") == Viewport.SCALING_3D_MODE_METALFX_SPATIAL:
		scale_filter_metalfx_spatial.button_pressed = true
	elif Settings.config_file.get_value("video", "scale_filter") == Viewport.SCALING_3D_MODE_METALFX_TEMPORAL:
		scale_filter_metalfx_temporal.button_pressed = true
	elif metalfx_supported:
		scale_filter_metalfx_temporal.button_pressed = true
	else:
		scale_filter_fsr2.button_pressed = true

	if Settings.config_file.get_value("rendering", "gi_type") == Settings.GIType.LIGHTMAP_GI:
		gi_lightmapgi.button_pressed = true
	elif Settings.config_file.get_value("rendering", "gi_type") == Settings.GIType.VOXEL_GI:
		gi_voxelgi.button_pressed = true
	else:
		gi_sdfgi.button_pressed = true

	if Settings.config_file.get_value("rendering", "gi_quality") == Settings.GIQuality.DISABLED:
		gi_disabled.button_pressed = true
	elif Settings.config_file.get_value("rendering", "gi_quality") == Settings.GIQuality.LOW:
		gi_low.button_pressed = true
	else:
		gi_high.button_pressed = true

	taa_disabled.button_pressed = not Settings.config_file.get_value("rendering", "taa")
	taa_enabled.button_pressed = Settings.config_file.get_value("rendering", "taa")

	if Settings.config_file.get_value("rendering", "msaa") == Viewport.MSAA_DISABLED:
		msaa_disabled.button_pressed = true
	elif Settings.config_file.get_value("rendering", "msaa") == Viewport.MSAA_2X:
		msaa_2x.button_pressed = true
	elif Settings.config_file.get_value("rendering", "msaa") == Viewport.MSAA_4X:
		msaa_4x.button_pressed = true
	else:
		msaa_8x.button_pressed = true

	if Settings.config_file.get_value("rendering", "screen_space_aa") == Viewport.SCREEN_SPACE_AA_DISABLED:
		screen_space_aa_disabled.button_pressed = true
	elif Settings.config_file.get_value("rendering", "screen_space_aa") == Viewport.SCREEN_SPACE_AA_FXAA:
		screen_space_aa_fxaa.button_pressed = true
	else:
		screen_space_aa_smaa.button_pressed = true

	shadow_mapping_disabled.button_pressed = not Settings.config_file.get_value("rendering", "shadow_mapping")
	shadow_mapping_enabled.button_pressed = Settings.config_file.get_value("rendering", "shadow_mapping")

	if Settings.config_file.get_value("rendering", "ssao_quality") == -1:
		ssao_disabled.button_pressed = true
	elif Settings.config_file.get_value("rendering", "ssao_quality") == RenderingServer.ENV_SSAO_QUALITY_MEDIUM:
		ssao_medium.button_pressed = true
	else:
		ssao_high.button_pressed = true

	if Settings.config_file.get_value("rendering", "ssil_quality") == -1:
		ssil_disabled.button_pressed = true
	elif Settings.config_file.get_value("rendering", "ssil_quality") == RenderingServer.ENV_SSIL_QUALITY_MEDIUM:
		ssil_medium.button_pressed = true
	else:
		ssil_high.button_pressed = true

	bloom_disabled.button_pressed = not Settings.config_file.get_value("rendering", "bloom")
	bloom_enabled.button_pressed = Settings.config_file.get_value("rendering", "bloom")

	volumetric_fog_disabled.button_pressed = not Settings.config_file.get_value("rendering", "volumetric_fog")
	volumetric_fog_enabled.button_pressed = Settings.config_file.get_value("rendering", "volumetric_fog")


func _on_apply_pressed() -> void:
	if display_mode_windowed.button_pressed:
		Settings.config_file.set_value("video", "display_mode", Window.MODE_WINDOWED)
	elif display_mode_fullscreen.button_pressed:
		Settings.config_file.set_value("video", "display_mode", Window.MODE_FULLSCREEN)
	elif display_mode_exclusive_fullscreen.button_pressed:
		Settings.config_file.set_value("video", "display_mode", Window.MODE_EXCLUSIVE_FULLSCREEN)

	if vsync_disabled.button_pressed:
		Settings.config_file.set_value("video", "vsync", DisplayServer.VSYNC_DISABLED)
	elif vsync_enabled.button_pressed:
		Settings.config_file.set_value("video", "vsync", DisplayServer.VSYNC_ENABLED)
	elif vsync_adaptive.button_pressed:
		Settings.config_file.set_value("video", "vsync", DisplayServer.VSYNC_ADAPTIVE)
	elif vsync_mailbox.button_pressed:
		Settings.config_file.set_value("video", "vsync", DisplayServer.VSYNC_MAILBOX)

	if max_fps_30.button_pressed:
		Settings.config_file.set_value("video", "max_fps", 30)
	elif max_fps_40.button_pressed:
		Settings.config_file.set_value("video", "max_fps", 40)
	elif max_fps_60.button_pressed:
		Settings.config_file.set_value("video", "max_fps", 60)
	elif max_fps_72.button_pressed:
		Settings.config_file.set_value("video", "max_fps", 72)
	elif max_fps_90.button_pressed:
		Settings.config_file.set_value("video", "max_fps", 90)
	elif max_fps_120.button_pressed:
		Settings.config_file.set_value("video", "max_fps", 120)
	elif max_fps_144.button_pressed:
		Settings.config_file.set_value("video", "max_fps", 144)
	elif max_fps_unlimited.button_pressed:
		Settings.config_file.set_value("video", "max_fps", 0)

	if resolution_scale_ultra_performance.button_pressed:
		Settings.config_file.set_value("video", "resolution_scale", 1.0 / 3.0)
	elif resolution_scale_performance.button_pressed:
		Settings.config_file.set_value("video", "resolution_scale", 1.0 / 2.0)
	elif resolution_scale_balanced.button_pressed:
		Settings.config_file.set_value("video", "resolution_scale", 1.0 / 1.7)
	elif resolution_scale_quality.button_pressed:
		Settings.config_file.set_value("video", "resolution_scale", 1.0 / 1.5)
	elif resolution_scale_ultra_quality.button_pressed:
		Settings.config_file.set_value("video", "resolution_scale", 1.0 / 1.3)
	elif resolution_scale_native.button_pressed:
		Settings.config_file.set_value("video", "resolution_scale", 1.0)

	if scale_filter_nearest.button_pressed:
		Settings.config_file.set_value("video", "scale_filter", Viewport.SCALING_3D_MODE_NEAREST)
	elif scale_filter_bilinear.button_pressed:
		Settings.config_file.set_value("video", "scale_filter", Viewport.SCALING_3D_MODE_BILINEAR)
	elif scale_filter_fsr1.button_pressed:
		Settings.config_file.set_value("video", "scale_filter", Viewport.SCALING_3D_MODE_FSR)
	elif scale_filter_fsr2.button_pressed:
		Settings.config_file.set_value("video", "scale_filter", Viewport.SCALING_3D_MODE_FSR2)
	elif scale_filter_metalfx_spatial.button_pressed:
		Settings.config_file.set_value("video", "scale_filter", Viewport.SCALING_3D_MODE_METALFX_SPATIAL)
	elif scale_filter_metalfx_temporal.button_pressed:
		Settings.config_file.set_value("video", "scale_filter", Viewport.SCALING_3D_MODE_METALFX_TEMPORAL)

	if gi_lightmapgi.button_pressed:
		Settings.config_file.set_value("rendering", "gi_type", Settings.GIType.LIGHTMAP_GI)
	elif gi_voxelgi.button_pressed:
		Settings.config_file.set_value("rendering", "gi_type", Settings.GIType.VOXEL_GI)
	elif gi_sdfgi.button_pressed:
		Settings.config_file.set_value("rendering", "gi_type", Settings.GIType.SDFGI)

	if gi_low.button_pressed:
		Settings.config_file.set_value("rendering", "gi_quality", Settings.GIQuality.LOW)
	elif gi_high.button_pressed:
		Settings.config_file.set_value("rendering", "gi_quality", Settings.GIQuality.HIGH)
	elif gi_disabled.button_pressed:
		Settings.config_file.set_value("rendering", "gi_quality", Settings.GIQuality.DISABLED)

	Settings.config_file.set_value("rendering", "taa", taa_enabled.button_pressed)

	if msaa_disabled.button_pressed:
		Settings.config_file.set_value("rendering", "msaa", Viewport.MSAA_DISABLED)
	elif msaa_2x.button_pressed:
		Settings.config_file.set_value("rendering", "msaa", Viewport.MSAA_2X)
	elif msaa_4x.button_pressed:
		Settings.config_file.set_value("rendering", "msaa", Viewport.MSAA_4X)
	elif msaa_8x.button_pressed:
		Settings.config_file.set_value("rendering", "msaa", Viewport.MSAA_8X)

	if screen_space_aa_disabled.button_pressed:
		Settings.config_file.set_value("rendering", "screen_space_aa", Viewport.SCREEN_SPACE_AA_DISABLED)
	elif screen_space_aa_fxaa.button_pressed:
		Settings.config_file.set_value("rendering", "screen_space_aa", Viewport.SCREEN_SPACE_AA_FXAA)
	elif screen_space_aa_smaa.button_pressed:
		Settings.config_file.set_value("rendering", "screen_space_aa", Viewport.SCREEN_SPACE_AA_SMAA)

	Settings.config_file.set_value("rendering", "shadow_mapping", shadow_mapping_enabled.button_pressed)

	if ssao_disabled.button_pressed:
		Settings.config_file.set_value("rendering", "ssao_quality", -1)
	elif ssao_medium.button_pressed:
		Settings.config_file.set_value("rendering", "ssao_quality", RenderingServer.ENV_SSAO_QUALITY_MEDIUM)
	elif ssao_high.button_pressed:
		Settings.config_file.set_value("rendering", "ssao_quality", RenderingServer.ENV_SSAO_QUALITY_HIGH)

	if ssil_disabled.button_pressed:
		Settings.config_file.set_value("rendering", "ssil_quality", -1)
	elif ssil_medium.button_pressed:
		Settings.config_file.set_value("rendering", "ssil_quality", RenderingServer.ENV_SSIL_QUALITY_MEDIUM)
	elif ssil_high.button_pressed:
		Settings.config_file.set_value("rendering", "ssil_quality", RenderingServer.ENV_SSIL_QUALITY_HIGH)

	Settings.config_file.set_value("rendering", "bloom", bloom_enabled.button_pressed)
	Settings.config_file.set_value("rendering", "volumetric_fog", volumetric_fog_enabled.button_pressed)

	if target_environment != null and target_scene_root != null:
		Settings.apply_graphics_settings(get_window(), target_environment, target_scene_root)

	Settings.save_settings()
	close_panel()


func _on_cancel_pressed() -> void:
	close_panel()


func _on_quit_requested() -> void:
	quit_requested.emit()
