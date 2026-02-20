const hre = require("hardhat");

async function main() {
    console.log("Deploying WorldState contract to Avalanche Fuji...");

    const WorldState = await hre.ethers.getContractFactory("WorldState");
    const worldState = await WorldState.deploy();

    await worldState.deployed();

    console.log("WorldState deployed to:", worldState.address);
    console.log("Transaction hash:", worldState.deployTransaction.hash);

    // Get initial state
    const state = await worldState.currentState();
    console.log("\nInitial State:");
    console.log("  Entropy:", ethers.utils.formatUnits(state.entropy, 18));
    console.log("  Phase:", ethers.utils.formatUnits(state.phase, 18));
    console.log("  Distortion:", ethers.utils.formatUnits(state.distortion, 18));
    console.log("  Color Seed:", [
        ethers.utils.formatUnits(state.colorSeed[0], 18),
        ethers.utils.formatUnits(state.colorSeed[1], 18),
        ethers.utils.formatUnits(state.colorSeed[2], 18)
    ]);

    console.log("\n✅ Deployment complete!");
    console.log(`Add to .env: CONTRACT_ADDRESS=${worldState.address}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
