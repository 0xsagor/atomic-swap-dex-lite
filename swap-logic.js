const { ethers } = require("ethers");

// Helper to generate hashlock and secret
function generateSecret() {
    const secret = ethers.randomBytes(32);
    const hashLock = ethers.keccak256(secret);
    return {
        secret: ethers.hexlify(secret),
        hashLock: hashLock
    };
}

async function initiateSwap(contract, participant, token, amount, hashLock, duration) {
    const swapId = ethers.id(Date.now().toString());
    const tx = await contract.initiate(
        swapId,
        participant,
        token,
        ethers.parseEther(amount),
        hashLock,
        duration
    );
    await tx.wait();
    return swapId;
}

module.exports = { generateSecret, initiateSwap };
