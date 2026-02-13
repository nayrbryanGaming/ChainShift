# ChainShift

ChainShift is a crypto-native procedural game built entirely through code.  
It renders a shared abstract world using deterministic, 4K-capable raymarching shaders, where the state of the world is designed to evolve through on-chain parameters rather than static assets or server-controlled logic.

This project is intentionally minimal, system-driven, and focused on execution.

---

## What is ChainShift?

ChainShift is not a traditional game with characters, levels, or scripted content.  
It is a **living procedural world**—a visual system that continuously evolves based on a small set of mathematical parameters.

Each interaction (called a **Shift**) modifies the global state of the world.  
Over time, these accumulated shifts transform the environment for all participants.

The core idea is simple:
> **A shared world where the source of truth is code and on-chain state, not assets or centralized servers.**

---

## Why Procedural, Code-Only Graphics?

ChainShift uses:
- Raymarching
- Signed Distance Fields (SDF)
- Deterministic noise
- Mathematical transformations

There are:
- No textures  
- No models  
- No sprites  
- No external assets  

This approach ensures:
- Infinite visual variation from a small parameter set
- Clean scaling to 4K resolution
- Full determinism and reproducibility
- A tight feedback loop between system state and visuals

The visuals are not decorative—they are a direct expression of the underlying system.

---

## Why Blockchain?

Blockchain is not used as a feature add-on.

In ChainShift, the blockchain is designed to become the **single source of truth for the world state**:
- World parameters are written on-chain
- State changes are transparent and verifiable
- The world evolves collectively, not per user or per server

This enables a shared universe that:
- Cannot be silently reset
- Does not depend on a single backend
- Reflects real collective interaction over time

Avalanche is chosen for its fast finality, low latency, and EVM compatibility, making it suitable for real-time system-driven interaction.

---

## Current Scope (Build Games MVP)

This repository focuses on a tightly scoped MVP that can be built and validated within six weeks:

- Procedural world rendering (code-only)
- Single core interaction: **Shift**
- Deterministic parameter-based world mutation
- Foundation for on-chain world state integration

There is no feature creep by design.

---

## Technical Stack

**Engine**
- Godot Engine 4.x
- GDScript

**Graphics**
- Fullscreen fragment shader
- Raymarching with SDF
- Resolution-independent rendering (4K-ready)

**Blockchain (Planned)**
- Avalanche C-Chain (EVM)
- Solidity
- Single WorldState smart contract

**Deployment (Planned)**
- Godot Web export
- Vercel hosting
- Avalanche Fuji testnet

---

## Design Principles

- Execution over hype  
- Systems over content  
- Determinism over randomness  
- Small scope, long-term vision  

ChainShift is built to be understandable, auditable, and extensible.

---

## Roadmap (High-Level)

**Phase 1**
- Procedural graphics foundation
- Stable 4K rendering
- Parameter-driven world

**Phase 2**
- Shift interaction
- Local state mutation
- Visual feedback loop

**Phase 3**
- On-chain world state
- Event-based synchronization

**Phase 4**
- Stability, polish, and demo readiness

---

## Status

ChainShift is under active development as part of the Avalanche Build Games program.  
This repository represents an execution-focused prototype, not a finished product.

---

## License

MIT License.                                     ---

## 6-Week Execution Plan (Avalanche Build Games)

ChainShift is intentionally scoped to align with the 6-week Avalanche Build Games structure, prioritizing execution, stability, and demonstrable progress over feature breadth.

### Week 1 — Visual & Engine Foundation
- Godot 4 project setup
- Fullscreen procedural shader using raymarching and SDF
- Stable abstract world rendering
- Parameter-driven visual mutation (local only)

**Deliverable:** Running visual prototype with 4K-capable rendering

---

### Week 2 — Core Interaction (Shift)
- Implement Shift as the single core interaction
- Controlled parameter mutation with strict bounds
- Visual feedback loop per Shift
- Minimal debug overlay for world parameters

**Deliverable:** Playable local prototype

---

### Week 3 — On-Chain World State
- Design and implement WorldState smart contract
- Store global world parameters on-chain
- Map on-chain values to shader parameters
- Event-based state updates

**Deliverable:** On-chain connected prototype (testnet)

---

### Week 4 — Synchronization & Stability
- State synchronization via contract events
- Edge-case handling and fallback logic
- Gas usage optimization
- Performance tuning

**Deliverable:** Stable shared world across sessions

---

### Week 5 — Polish & Demo Readiness
- Visual smoothing and consistency
- Performance validation up to 4K
- Demo recording flow
- Documentation refinement

**Deliverable:** Demo-ready build and walkthrough

---

### Week 6 — Finalization & Showcase
- Final testing and cleanup
- Pitch refinement
- Live demo preparation
- Submission and showcase

**Deliverable:** Final demo, codebase, and pitch
