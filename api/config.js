export default function handler(req, res) {
    // Feed environment variables to the static frontend securely
    // This executes on Vercel's edge/serverless infrastructure at runtime
    res.status(200).json({
        chainName: process.env.NEXT_PUBLIC_CHAIN_NAME || 'Celo Alfajores Testnet',
        chainId: process.env.NEXT_PUBLIC_CHAIN_ID || '44787',
        rpcUrl: process.env.NEXT_PUBLIC_RPC_URL || 'https://alfajores-forno.celo-testnet.org',
        programId: process.env.NEXT_PUBLIC_PROGRAM_ID || '0x0000000000000000000000000000000000000000'
    });
}
