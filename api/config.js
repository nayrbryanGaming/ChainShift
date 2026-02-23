export default function handler(req, res) {
    // Feed environment variables to the static frontend securely
    // This executes on Vercel's edge/serverless infrastructure at runtime
    res.status(200).json({
        chainName: process.env.NEXT_PUBLIC_CHAIN_NAME || 'Avalanche Fuji Testnet',
        chainId: process.env.NEXT_PUBLIC_CHAIN_ID || '43113',
        rpcUrl: process.env.NEXT_PUBLIC_RPC_URL || 'https://api.avax-test.network/ext/bc/C/rpc',
        programId: process.env.NEXT_PUBLIC_PROGRAM_ID || '0x0000000000000000000000000000000000000000'
    });
}
