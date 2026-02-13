extends Node

@onready var shader_rect: ColorRect = $ShaderRect

# Global World State (Phase 2: Local SHIFT | Phase 3: Sync Prep)
var target_entropy: float = 0.5
var target_phase: float = 1.0
var target_distortion: float = 0.2
var target_color_seed: Vector3 = Vector3(0.2, 0.5, 0.8)

var current_entropy: float = 0.5
var current_phase: float = 1.0
var current_distortion: float = 0.2
var current_color_seed: Vector3 = Vector3(0.2, 0.5, 0.8)

var shift_intensity: float = 0.0

# Sync State
var last_sync_timestamp: float = 0.0
var sync_interval: float = 5.0 
var rpc_url: String = "https://api.avax-test.network/ext/bc/C/rpc"
var contract_address: String = "0x0000000000000000000000000000000000000000" # Deployment target

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var label: Label = $DebugUI/Label

func _ready() -> void:
	print("ChainShift NUCLEAR: System Active.")
	http_request.request_completed.connect(_on_sync_completed)
	_request_chain_sync()

func _process(delta: float) -> void:
	_handle_input(delta)
	_interpolate_state(delta)
	_update_shader_parameters()
	
	last_sync_timestamp += delta
	if last_sync_timestamp >= sync_interval:
		last_sync_timestamp = 0.0
		_request_chain_sync()

func _request_chain_sync() -> void:
	if contract_address == "0x0000000000000000000000000000000000000000":
		return # Wait for actual deployment address
		
	# eth_call for worldState() member access 
	# worldState() returns (uint256, uint256, uint256, uint256[3], uint256)
	# For simplicity in this demo, we'll assume a standard JSON-RPC call
	var payload = {
		"jsonrpc": "2.0",
		"method": "eth_call",
		"params": [{
			"to": contract_address,
			"data": "0x16008631" # worldState() selector stub
		}, "latest"],
		"id": 1
	}
	var query = JSON.stringify(payload)
	var headers = ["Content-Type: application/json"]
	http_request.request(rpc_url, headers, HTTPClient.METHOD_POST, query)

func _on_sync_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return
		
	var json = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		return
		
	var response = json.get_data()
	if response.has("result") and typeof(response["result"]) == TYPE_STRING:
		_parse_world_state(response["result"])

func _parse_world_state(hex_data: String) -> void:
	var data = hex_data.substr(2) # Strip 0x
	if data.length() < 64 * 6: return
	
	target_entropy = _hex_to_scaled_float(data.substr(0, 64))
	target_phase = _hex_to_scaled_float(data.substr(64, 64))
	target_distortion = _hex_to_scaled_float(data.substr(128, 64))
	
	var r = _hex_to_scaled_float(data.substr(192, 64))
	var g = _hex_to_scaled_float(data.substr(256, 64))
	var b = _hex_to_scaled_float(data.substr(320, 64))
	target_color_seed = Vector3(r, g, b)
	
	shift_intensity = 0.8
	print("Global Sync Success | State: E:%.2f P:%.2f D:%.2f" % [target_entropy, target_phase, target_distortion])

func _hex_to_scaled_float(hex: String) -> float:
	# Robustly parse 256-bit EVM word scaled by 1e18
	# We take the last 16 chars (64 bits) since our values (0-10) * 1e18 fit in 64 bits.
	# Godot 4 hex_to_int returns 64-bit signed. 10e18 is ~0x8A... which fits in unsigned 64-bit.
	# We use float() with a hex literal bridge for absolute precision.
	var SCALE = 1000000000000000000.0
	var last_16 = hex.substr(hex.length() - 16)
	
	# Bitwise handle unsigned wrap if necessary
	# 10e18 (0x8AC...) is larger than 2^63-1.
	var val_i = last_16.hex_to_int()
	var val_f: float
	if val_i < 0:
		# Unsigned recovery: val_f = (val_i & 0x7FFFFFFFFFFFFFFF) + 2^63
		val_f = float(val_i & 0x7FFFFFFFFFFFFFFF) + 9223372036854775808.0
	else:
		val_f = float(val_i)
	
	return val_f / SCALE

func _handle_input(_delta: float) -> void:
	# Continuous mutation inputs
	if Input.is_key_pressed(KEY_UP):
		target_entropy = clamp(target_entropy + 0.5 * _delta, 0.0, 1.0)
	if Input.is_key_pressed(KEY_DOWN):
		target_entropy = clamp(target_entropy - 0.5 * _delta, 0.0, 1.0)
	if Input.is_key_pressed(KEY_RIGHT):
		target_phase = clamp(target_phase + 2.0 * _delta, 0.1, 10.0)
	if Input.is_key_pressed(KEY_LEFT):
		target_phase = clamp(target_phase - 2.0 * _delta, 0.1, 10.0)

func _interpolate_state(delta: float) -> void:
	# Smoothly converge to target state
	current_entropy = lerp(current_entropy, target_entropy, delta * 5.0)
	current_phase = lerp(current_phase, target_phase, delta * 5.0)
	current_distortion = lerp(current_distortion, target_distortion, delta * 5.0)
	current_color_seed = current_color_seed.lerp(target_color_seed, delta * 3.0)
	
	# Decay shift intensity
	shift_intensity = lerp(shift_intensity, 0.0, delta * 4.0)

@onready var label: Label = $DebugUI/Label

func _update_shader_parameters() -> void:
	if shader_rect.material is ShaderMaterial:
		var mat = shader_rect.material as ShaderMaterial
		var raw_time = Time.get_ticks_msec() / 1000.0
		mat.set_shader_parameter("u_time", fmod(raw_time, 3600.0))
		mat.set_shader_parameter("u_entropy", current_entropy)
		mat.set_shader_parameter("u_phase", current_phase)
		mat.set_shader_parameter("u_distortion", current_distortion)
		mat.set_shader_parameter("u_color_seed", current_color_seed)
		mat.set_shader_parameter("u_shift_intensity", shift_intensity)
		
		# Update UI
		var status = "SYNCED" if contract_address != "0x0000000000000000000000000000000000000000" else "LOCAL"
		label.text = "CHAINSHIFT | %s | E:%.2f P:%.2f\n[SPACE] SHIFT | [R] RAND" % [status, current_entropy, current_phase]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				get_tree().quit()
			KEY_SPACE:
				_trigger_shift()
			KEY_R:
				_randomize_target()

func _trigger_shift() -> void:
	shift_intensity = 1.0
	# Shift causes a sudden jump in distortion and a new color palette
	target_distortion = randf_range(0.2, 0.8)
	target_color_seed = Vector3(randf(), randf(), randf())
	print("SHIFT Triggered: New State Target established.")

func _randomize_target() -> void:
	target_entropy = randf()
	target_phase = randf_range(0.5, 5.0)
	target_distortion = randf_range(0.1, 0.5)
	target_color_seed = Vector3(randf(), randf(), randf())
	print("State Target Randomized.")
