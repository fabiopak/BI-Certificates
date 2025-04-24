# Solidity API

## IStableCoin

### transferAddresses

```solidity
function transferAddresses(address addr) external view returns (bool)
```

### mintCoins

```solidity
function mintCoins(address to, uint256 amount) external
```

### forcedBurnCoins

```solidity
function forcedBurnCoins(address account, uint256 amount) external
```

### batchForcedBurnCoins

```solidity
function batchForcedBurnCoins(address[] account, uint256[] amount) external
```

