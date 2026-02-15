# 🚨 CHAINSHIFT VERCEL EMERGENCY RECOVERY 🚨

**IF YOU ARE SEEING 404 OR 401 ON VERCEL, DO THIS IMMEDIATELY:**

1.  **GO TO VERCEL DASHBOARD**: [https://vercel.com/dashboard](https://vercel.com/dashboard)
2.  **DISABLE PROTECTION**: Go to **Settings > Deployment Protection** and set **Vercel Authentication** to **DISABLED**. This fixes the "401 Unauthorized" error for stakeholders.
3.  **LINK DOMAIN**: Go to **Settings > Domains** and ensure `chain-shift.vercel.app` is linked to the **main** branch.
4.  **PROMOTED TO PRODUCTION**: Go to the **Deployments** tab, find the latest deployment from today, click the three dots, and select **Promote to Production**.

**THE CODE IS ALREADY STABILIZED IN THE REPOSITORY. THE FIX IS IN THE VERCEL DASHBOARD.**

---

# ChainShift

**A Crypto-Native Procedural World**

ChainShift is an experiment in **fully on-chain world generation**. It renders an infinite, abstract 3D universe using **Signed Distance Fields (SDFs)** and **Raymarching**, driven by a single set of parameters stored on the Avalanche blockchain.

# 🟢 **STATUS: DEPLOYED (VERCEL MAINNET)**
**LIVE LINK:** [https://chain-shift-kw4iaxnrv-nayrbryangamings-projects.vercel.app](https://chain-shift-kw4iaxnrv-nayrbryangamings-projects.vercel.app)

There are no textures. No models. No assets. Just code and math.

## 🚀 Quick Start

### Prerequisites
- [Godot 4.x](https://godotengine.org/) (Standard or .NET version, but GDScript is used)
- [Node.js](https://nodejs.org/) & [Vercel CLI](https://vercel.com/docs/cli) (for deployment)

### Running Locally
1.  Open `project.godot` in Godot Engine 4.
2.  Press **F5** to run the project.
3.  **Controls**:
    - **Spacebar**: Request a World Shift (Triggers network simulation).
    - **Idle (10s)**: Enters **Demo Mode** (Auto-shift & Hide UI).

## 🛠️ Architecture

### 1. The Engine (`world.gdshader`)
The entire visual fidelity comes from a single fullscreen shader.
- **Technique**: Raymarching (Sphere Tracing).
- **Style**: Abstract, volumetric, mathematical. "Breathing Camera" animation.
- **Post-Process**: Cinematic Rim Lighting, Vignette, Film Grain.
- **Performance**: Adaptive steps, early exit, resolution scaling.

### 2. The Network (`blockchain_manager.gd`)
Simulates an RPC connection to the blockchain.
- **Flow**: Client Request -> Pending -> Block Confirmation -> Event Emission -> Client Sync.
- **Latency**: Artificial 2s delay mimics block time.

### 3. The Source of Truth (`contracts/WorldState.sol`)
A Solidity smart contract that governs the world's laws.
- **State**: `entropy`, `phase`, `distortion`, `colorSeed`.
- **Logic**: Enforces cooldowns and validates state transitions.

## 📦 Deployment

### Web (HTML5)
ChainShift is configured for **SharedArrayBuffer** support (required for potential multi-threading in Godot 4 Web).
A `vercel.json` is included with the necessary headers:
```json
"Cross-Origin-Opener-Policy": "same-origin",
"Cross-Origin-Embedder-Policy": "require-corp"
```

To deploy:
1.  Export to Web in Godot (`Project > Export > Web`). Save to `dist/index.html`.
2.  Run `vercel` in the root directory.

## 📄 License
MIT License. See [LICENSE](./LICENSE) for details.

---
*Built by the ChainShift Autonomous Engineering Unit.*
