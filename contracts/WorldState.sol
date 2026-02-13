// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title WorldState
 * @dev Single source of truth for the ChainShift procedural world.
 * All values are stored as fixed-point integers (scaled by 1e18) to maintain 
 * deterministic fidelity across the EVM and the game engine.
 */
contract WorldState {
    
    struct State {
        uint256 entropy;     // 0.0 to 1.0 (scaled by 1e18)
        uint256 phase;       // 0.1 to 10.0 (scaled by 1e18)
        uint256 distortion;  // 0.0 to 1.0 (scaled by 1e18)
        uint256[3] colorSeed; // RGB components (each 0.0 to 1.0, scaled by 1e18)
        uint256 lastUpdated;  // Block timestamp
    }

    State public worldState;
    uint256 public constant SCALE = 1e18;
    uint256 public constant MIN_COOLDOWN = 1 minutes;

    event WorldShifted(
        uint256 entropy,
        uint256 phase,
        uint256 distortion,
        uint256[3] colorSeed,
        address indexed shifter,
        uint256 timestamp
    );

    constructor(
        uint256 _entropy,
        uint256 _phase,
        uint256 _distortion,
        uint256[3] memory _colorSeed
    ) {
        worldState = State({
            entropy: _entropy,
            phase: _phase,
            distortion: _distortion,
            colorSeed: _colorSeed,
            lastUpdated: block.timestamp
        });
    }

    /**
     * @dev Mutate the global world state. 
     * In future phases, this may require payment (AVA) or specific tokens.
     */
    function shift(
        uint256 _entropy,
        uint256 _phase,
        uint256 _distortion,
        uint256[3] calldata _colorSeed
    ) external {
        require(block.timestamp >= worldState.lastUpdated + MIN_COOLDOWN, "World is still stabilizing");
        
        // Basic validation for parameter ranges
        require(_entropy <= SCALE, "Entropy out of bounds");
        require(_phase >= SCALE / 10 && _phase <= 10 * SCALE, "Phase out of bounds");
        require(_distortion <= SCALE, "Distortion out of bounds");
        require(_colorSeed[0] <= SCALE && _colorSeed[1] <= SCALE && _colorSeed[2] <= SCALE, "Color seed out of bounds");

        worldState = State({
            entropy: _entropy,
            phase: _phase,
            distortion: _distortion,
            colorSeed: _colorSeed,
            lastUpdated: block.timestamp
        });

        emit WorldShifted(
            _entropy,
            _phase,
            _distortion,
            _colorSeed,
            msg.sender,
            block.timestamp
        );
    }

    /**
     * @dev Get current color seed as an array.
     */
    function getColorSeed() external view returns (uint256[3] memory) {
        return worldState.colorSeed;
    }
}
