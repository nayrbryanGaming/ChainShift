extends Node
class_name BlockchainManager

# ==============================================================================
# BLOCKCHAIN MANAGER (PHASE 4)
# ==============================================================================
# Simulates the Network Layer.
# - Handling RPC calls
# - Simulating Latency (Block time)
# - Emitting "On-Chain" Events to the Client
# ==============================================================================

signal transaction_pending
signal transaction_confirmed
signal world_state_updated(entropy, phase, distortion, color_seed)

var is_pending: bool = false

func request_shift() -> void:
    if is_pending:
        print(">> NETWORK BUSY: Transaction already pending.")
        return

    print(">> RPC: Sending Shift Transaction...")
    is_pending = true
    transaction_pending.emit()
    
    # Simulate Network Latency (2.0 seconds)
    await get_tree().create_timer(2.0).timeout
    
    _confirm_transaction()

func _confirm_transaction() -> void:
    print(">> NETWORK: Transaction Confirmed (Block #%d)" % randi())
    
    # Simulate "Solidity Event" Data
    # In a real app, this comes from the JSON-RPC event log
    var new_entropy = randf_range(1.0, 5.0)
    var new_phase = randf_range(-3.14, 3.14)
    var new_distortion = randf_range(-0.8, 0.8)
    var new_color = Vector3(randf(), randf(), randf())
    
    is_pending = false
    transaction_confirmed.emit()
    world_state_updated.emit(new_entropy, new_phase, new_distortion, new_color)
