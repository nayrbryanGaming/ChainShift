extends Control

# ==============================================================================
# CHAINSHIFT - MAIN CONTROLLER
# ==============================================================================
# Production system: SHIFT mechanic + on-chain state synchronization
# ==============================================================================

signal shift_triggered()

# Node references
@onready var world_renderer: ColorRect = $WorldRenderer
@onready var blockchain_manager: Node = null  # Initialized if exists

# World parameters (synced with blockchain)
@export_group("World Parameters")
@export var entropy: float = 2.5
@export var phase: float = 0.0
@export var distortion: float = 0.5
@export var color_seed: Vector3 = Vector3(0.1, 0.4, 0.8)
@export var impulse: float = 0.0

# UI elements
var fps_label: Label
var params_label: Label
var status_label: Label

# State
var time_accum: float = 0.0
var shift_cooldown: float = 0.0
const SHIFT_COOLDOWN_TIME: float = 2.0

# Parameter bounds
const ENTROPY_MIN = 0.5
const ENTROPY_MAX = 5.0
const DISTORTION_MIN = -1.0
const DISTORTION_MAX = 2.0

func _ready() -> void:
	print("CHAINSHIFT :: PRODUCTION BUILD :: ONLINE")
	_setup_ui()
	_setup_blockchain()
	_load_initial_state()

func _setup_ui() -> void:
	# FPS counter
	fps_label = Label.new()
	fps_label.position = Vector2(20, 20)
	fps_label.add_theme_font_size_override("font_size", 16)
	fps_label.add_theme_color_override("font_color", Color(0, 1, 0, 0.8))
	add_child(fps_label)
	
	# Parameters display
	params_label = Label.new()
	params_label.position = Vector2(20, 50)
	params_label.add_theme_font_size_override("font_size", 14)
	params_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
	add_child(params_label)
	
	# Status display
	status_label = Label.new()
	status_label.position = Vector2(20, 150)
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color(1, 1, 0, 1))
	add_child(status_label)
	status_label.text = "CHAINSHIFT ONLINE\nPress SPACE or CLICK to SHIFT"

func _setup_blockchain() -> void:
	# Try to connect to blockchain manager if it exists
	if has_node("BlockchainManager"):
		blockchain_manager = get_node("BlockchainManager")
		if blockchain_manager.has_signal("world_state_updated"):
			blockchain_manager.world_state_updated.connect(_on_world_state_sync)
		if blockchain_manager.has_signal("transaction_confirmed"):
			blockchain_manager.transaction_confirmed.connect(_on_tx_confirmed)
		print("CHAINSHIFT :: BLOCKCHAIN BRIDGE CONNECTED")
	else:
		print("CHAINSHIFT :: LOCAL MODE (No blockchain bridge)")

func _load_initial_state() -> void:
	# Request initial state from blockchain if available
	if blockchain_manager and blockchain_manager.has_method("fetch_world_state"):
		blockchain_manager.fetch_world_state()
	_update_shader()

func _process(delta: float) -> void:
	time_accum += delta
	
	# Update cooldown
	if shift_cooldown > 0:
		shift_cooldown -= delta
	
	# Impulse decay
	if impulse > 0:
		impulse = max(0, impulse - delta * 2.0)
	
	# Auto-modulation (smooth ambient evolution)
	phase += delta * 0.1
	if phase > TAU:
		phase -= TAU
	
	# Update shader every frame
	_update_shader()
	
	# Update UI
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	params_label.text = "Entropy: %.2f\nPhase: %.2f\nDistortion: %.2f\nImpulse: %.2f\nCooldown: %.1fs" % [
		entropy, phase, distortion, impulse, max(0, shift_cooldown)
	]

func _input(event: InputEvent) -> void:
	# SHIFT trigger (space or click)
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		_trigger_shift()
	
	# Manual parameter controls (for testing)
	if event.is_action_pressed("ui_up"):
		entropy = clamp(entropy + 0.1, ENTROPY_MIN, ENTROPY_MAX)
	if event.is_action_pressed("ui_down"):
		entropy = clamp(entropy - 0.1, ENTROPY_MIN, ENTROPY_MAX)
	if event.is_action_pressed("ui_right"):
		distortion = clamp(distortion + 0.05, DISTORTION_MIN, DISTORTION_MAX)
	if event.is_action_pressed("ui_left"):
		distortion = clamp(distortion - 0.05, DISTORTION_MIN, DISTORTION_MAX)

func _trigger_shift() -> void:
	if shift_cooldown > 0:
		print("CHAINSHIFT :: SHIFT ON COOLDOWN")
		return
	
	# Trigger impulse (visual feedback)
	impulse = 1.0
	shift_cooldown = SHIFT_COOLDOWN_TIME
	
	# Mutate world parameters (deterministic transformation)
	var rng_seed = hash(str(time_accum))
	var rng = RandomNumberGenerator.new()
	rng.seed = rng_seed
	
	entropy = clamp(entropy + rng.randf_range(-0.3, 0.5), ENTROPY_MIN, ENTROPY_MAX)
	distortion = clamp(distortion + rng.randf_range(-0.2, 0.2), DISTORTION_MIN, DISTORTION_MAX)
	color_seed = Vector3(
		rng.randf(),
		rng.randf(),
		rng.randf()
	)
	
	emit_signal("shift_triggered")
	print("CHAINSHIFT :: SHIFT EXECUTED (entropy=%.2f, distortion=%.2f)" % [entropy, distortion])
	
	# Send to blockchain if available
	if blockchain_manager and blockchain_manager.has_method("request_shift"):
		blockchain_manager.request_shift(entropy, phase, distortion, color_seed)

func _update_shader() -> void:
	var mat = world_renderer.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("u_time", time_accum)
		mat.set_shader_parameter("u_entropy", entropy)
		mat.set_shader_parameter("u_phase", phase)
		mat.set_shader_parameter("u_distortion", distortion)
		mat.set_shader_parameter("u_color_seed", color_seed)
		mat.set_shader_parameter("u_impulse", impulse)

# Blockchain callbacks
func _on_world_state_sync(new_entropy: float, new_phase: float, new_distortion: float, new_color: Vector3) -> void:
	entropy = new_entropy
	phase = new_phase
	distortion = new_distortion
	color_seed = new_color
	print("CHAINSHIFT :: STATE SYNCED FROM BLOCKCHAIN")

func _on_tx_confirmed(tx_hash: String) -> void:
	print("CHAINSHIFT :: TX CONFIRMED: %s" % tx_hash)
	status_label.text = "SHIFT CONFIRMED ON-CHAIN\nTX: %s" % tx_hash.substr(0, 16)
	await get_tree().create_timer(3.0).timeout
	status_label.text = "CHAINSHIFT ONLINE\nPress SPACE or CLICK to SHIFT"
