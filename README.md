# KIPU Bank module 2

KipuBank is a simple, secure ETH vault smart contract that allows each user to deposit and withdraw ETH into their own "personal vault" with:

- **Global bank capacity limit (bankCap)**
- **Custom errors** for gas-efficient reverts
- **Event logging** for deposits & withdrawals
- **Reentrancy protection** and CEI pattern


---

## Overview

| Function | Type | Description |
|---------|------|-------------|
| `deposit()` | `external payable` | Deposit ETH into your vault |
| `withdraw(uint256 amount)` | `external` | Withdraw ETH up to your vault balance and the max withdraw limit |
| `getBalance(address user)` | `external view` | View any user's vault balance |
| `totalBankBalance()` | `external view` | View total ETH held by the bank |
| `_transferETH()` | `private` | transfer eth securely |

---



# Práticas de Segurança a Seguir:

    Use Custom errors instead require for save gas.

    Respect checks-effects-interactions patterns and global naming conventions.

    Readable.

    Well comment.

## Options for deployment: via **Remix IDE** (quick/manual) or via **Hardhat** (scripted/automated).

---

### Option 1 — Deploy with Remix IDE

1. Open [Remix IDE](https://remix.ethereum.org).
2. Create a new file `deploy.ts` and paste:

```javascript
// Remix Script Deployment
async function deploy() {
  const KipuBank = await ethers.getContractFactory("KipuBank");
  const kipuBank = await KipuBank.deploy(
    ethers.parseEther("100"), // bankCap: change this as needed
    ethers.parseEther("1")    // maxWithdrawPerTx: change this as needed
  );

  console.log("✅ KipuBank deployed to:", kipuBank.target);
}

deploy();
```
---

### Option 2 — Deploy with Hardhat


```typescript
npm install

import { ethers } from "hardhat";

async function main() {
  const BANK_CAP = ethers.utils.parseEther("1000"); // global cap
  const MAX_WITHDRAW = ethers.utils.parseEther("1"); // per-tx limit

  const Kipu = await ethers.getContractFactory("KipuBank");
  const kipu = await Kipu.deploy(BANK_CAP, MAX_WITHDRAW);
  await kipu.deployed();

  console.log("✅ KipuBank deployed to:", kipu.address);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});

npx hardhat run scripts/deploy.ts --network sepolia

npx hardhat verify --network sepolia <DEPLOYED_ADDRESS> 1000000000000000000000 1000000000000000000
```

## Testing
```
If you use Remix:

Use the "Deploy & Run" tab to call deposit();

Call withdraw(amount) to test withdrawals (must be ≤ MAX_WITHDRAW_PER_TX).
npx hardhat test
```
