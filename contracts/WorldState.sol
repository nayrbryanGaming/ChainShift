// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title WorldState
 * @dev The Single Source of Truth for ChainShift.
 * Stores the abstract world parameters on the Avalanche C-Chain.
 * All logic is deterministic. 1e18 scaling used for float precision.
 */
contract WorldState {
    
    // State Variables (Scaled by 1e18)
    struct State {
        uint256 entropy;      // 0.0 to 5.0
        uint256 phase;        // -PI to PI
        uint256 distortion;   // -1.0 to 1.0
        uint256[3] colorSeed; // RGB (0.0 to 1.0)
        uint256 lastUpdated;  // Block timestamp
    }

    State public currentState;
    
    // Constants
    uint256 constant SCALE = 1e18;
    uint256 constant MIN_COOLDOWN = 30; // Seconds between shifts

    // Events
    event WorldShifted(
        uint256 entropy,
        uint256 phase,
        uint256 distortion,
        uint256[3] colorSeed,
        address indexed shifter,
        uint256 timestamp
    );

    constructor() {
        // Initial State (Genesis)
        currentState = State({
            entropy: 1 * SCALE,
            phase: 0,
            distortion: 0,
            colorSeed: [uint256(500000000000000000), uint256(500000000000000000), uint256(500000000000000000)],
            lastUpdated: block.timestamp
        });
    }

    /**
     * @dev Mutate the world state. 
     * In a full version, this might use VRF. For now, we trust the caller's randomness 
     * or derive it from block difficulty (prevrandao) in strict implementations.
     * Here we accept parameters to allow the gameplay loop to drive it, 
     * validating they are within bounds.
     */
    function shift(
        uint256 _entropy,
        uint256 _phase,
        uint256 _distortion,
        uint256[3] calldata _colorSeed
    ) external {
        require(block.timestamp >= currentState.lastUpdated + MIN_COOLDOWN, "Cooldown active");
        
        // Bounds Checking
        require(_entropy <= 10 * SCALE, "Entropy too high");
        // Color bounds
        require(_colorSeed[0] <= 1 * SCALE && _colorSeed[1] <= 1 * SCALE && _colorSeed[2] <= 1 * SCALE, "Invalid Color");

        // Update State
        currentState = State({
            entropy: _entropy,
            phase: _phase,
            distortion: _distortion,
            colorSeed: _colorSeed,
            lastUpdated: block.timestamp
        });

        // Emit Event for Game Clients (Godot) to sync
        emit WorldShifted(
            _entropy,
            _phase,
            _distortion,
            _colorSeed,
            msg.sender,
            block.timestamp
        );
    }
}
