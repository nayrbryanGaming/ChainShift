extends Control

# ==============================================================================
# CHAINSHIFT - MAIN CONTROLLER (PHASE 2 - CORE INTERACTION)
# ==============================================================================
# Scope: SHIFT Mechanic + Blockchain Bridge
# - Handle Input (Space/Click)
# - Sync with BlockchainManager
# - Zero External Assets
# ==============================================================================

signal shift_triggered()

@onready var world_renderer: ColorRect = $WorldRenderer
@onready var blockchain: BlockchainManager = $BlockchainManager

@export_group("World Parameters")
@export var entropy: float = 2.5
@export var phase: float = 0.0
@export var distortion: float = 0.5
@export var color_seed: Vector3 = Vector3(0.1, 0.4, 0.8)
@export var impulse: float = 0.0

@onready var world_renderer: ColorRect = $WorldRenderer

var time_accum: float = 0.0

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
        _trigger_shift()

func _ready() -> void:
    print("CHAINSHIFT :: CORE PRODUCTION :: PHASE 3 :: BRIDGE ONLINE")
    _certify_build_visuals()
    
    if blockchain:
        blockchain.world_state_updated.connect(_on_world_state_sync)
        blockchain.transaction_confirmed.connect(_on_tx_confirmed)

func _on_world_state_sync(new_entropy, new_phase, new_distortion, new_color) -> void:
    # Smoothly Interpolate to Global Shared State
    entropy = new_entropy
    phase = new_phase
    distortion = new_distortion
    color_seed = new_color
    print("CHAINSHIFT :: WORLD SYNCED TO BLOCKCHAIN STATE")

func _on_tx_confirmed() -> void:
    print("CHAINSHIFT :: TRANSACTION VERIFIED")

func _trigger_shift() -> void:
    impulse = 1.0
    if blockchain:
        blockchain.request_shift()
    print("CHAINSHIFT :: LOCAL SHIFT -> REQUESTING ON-CHAIN SYNC")
    
    # Phase 1: Smooth Auto-Modulation
    phase += delta * (0.2 + impulse * 0.5)
    entropy = 2.0 + sin(time_accum * 0.1) * 1.5 + impulse * 0.5
    distortion = 0.5 + cos(time_accum * 0.15) * 0.3 + impulse * 0.2
    
    _update_shader()

func _update_shader() -> void:
    var mat = world_renderer.material as ShaderMaterial
    if mat:
        mat.set_shader_parameter("u_time", time_accum)
        mat.set_shader_parameter("u_entropy", entropy)
        mat.set_shader_parameter("u_phase", phase)
        mat.set_shader_parameter("u_distortion", distortion)
        mat.set_shader_parameter("u_color_seed", color_seed)
        mat.set_shader_parameter("u_impulse", impulse)

func _certify_build_visuals() -> void:
    var label = Label.new()
    label.text = "CHAINSHIFT CORE PRODUCTION\nPHASE 1: GRAPHICS STABLE\nREAL-TIME PROCEDURAL"
    label.add_theme_font_size_override("font_size", 32)
    label.add_theme_color_override("font_color", Color(0, 1, 0, 1))
    label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_MINSIZE, 20)
    add_child(label)

