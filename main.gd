extends Control

# ==============================================================================
# CHAINSHIFT - MAIN CONTROLLER (PHASE 1 - NUCLEAR STABILIZATION)
# ==============================================================================
# Scope: Graphics Foundation
# - Setup Shader Uniforms (u_entropy, u_phase, u_distortion, u_color_seed, u_time)
# - Deterministic World Evolution
# - Zero External Assets
# ==============================================================================

@export_group("World Parameters")
@export var entropy: float = 2.5
@export var phase: float = 0.0
@export var distortion: float = 0.5
@export var color_seed: Vector3 = Vector3(0.1, 0.4, 0.8)

@onready var world_renderer: ColorRect = $WorldRenderer

var time_accum: float = 0.0

func _ready() -> void:
    print("CHAINSHIFT :: NUCLEAR BUILD :: PHASE 1 :: ONLINE")
    _certify_build_visuals()
    
    if not world_renderer:
        push_error("CRITICAL: WorldRenderer node not found!")
        return

func _process(delta: float) -> void:
    time_accum += delta
    
    # Phase 1: Smooth Auto-Modulation (Deterministic)
    phase += delta * 0.2
    entropy = 2.0 + sin(time_accum * 0.1) * 1.5
    distortion = 0.5 + cos(time_accum * 0.15) * 0.3
    
    _update_shader()

func _update_shader() -> void:
    var mat = world_renderer.material as ShaderMaterial
    if mat:
        mat.set_shader_parameter("u_time", time_accum)
        mat.set_shader_parameter("u_entropy", entropy)
        mat.set_shader_parameter("u_phase", phase)
        mat.set_shader_parameter("u_distortion", distortion)
        mat.set_shader_parameter("u_color_seed", color_seed)

func _certify_build_visuals() -> void:
    var label = Label.new()
    label.text = "CHAINSHIFT NUCLEAR BUILD\nPHASE 1: GRAPHICS STABLE\nREAL-TIME PROCEDURAL"
    label.add_theme_font_size_override("font_size", 32)
    label.add_theme_color_override("font_color", Color(0, 1, 0, 1))
    label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_MINSIZE, 20)
    add_child(label)

