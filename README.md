# Atomic Swap DEX Lite

This repository provides a high-quality, professional implementation of an Atomic Swap mechanism. It utilizes Hashed Timelock Contracts (HTLCs) to ensure that two parties can trade assets across different chains (or the same chain) safely.

### How It Works
1. **Initiate:** Party A generates a secret, hashes it, and creates a contract locking funds with that hash.
2. **Participate:** Party B sees the hash and locks their funds in a similar contract using the same hash.
3. **Claim:** Party A claims Party B's funds by revealing the secret.
4. **Complete:** Party B sees the secret on-chain and uses it to claim Party A's funds.

### Security
If either party fails to complete the trade, funds are returned to the original owners after a specified `lockTime` expiry.
