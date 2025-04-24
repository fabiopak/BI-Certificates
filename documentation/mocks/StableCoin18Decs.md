# Solidity API

## StableCoin18Decs

### ADMIN_ROLE

```solidity
bytes32 ADMIN_ROLE
```

### maxArrayLength

```solidity
uint256 maxArrayLength
```

### transferAddresses

```solidity
mapping(address => bool) transferAddresses
```

_contractAddress => boolean_

### constructor

```solidity
constructor(string _name, string _sym) public
```

### setMaxArrayLen

```solidity
function setMaxArrayLen(uint256 _newLen) external
```

_set new max array length for txs (DEFAULT_ADMIN_ROLE)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _newLen | uint256 | new max array length |

### mintCoins

```solidity
function mintCoins(address to, uint256 amount) external
```

_single mint (ADMIN_ROLE, check performed by inherited contract)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | recipient address |
| amount | uint256 | amount to be minted |

### batchMintCoins

```solidity
function batchMintCoins(address[] to, uint256[] amount) external
```

_batch mint (ADMIN_ROLE, check performed by inherited contract)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address[] | recipient address array |
| amount | uint256[] | amount to be minted array |

### _update

```solidity
function _update(address from, address to, uint256 value) internal
```

_Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
(or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
this function.

Emits a {Transfer} event._

### setTransferAddress

```solidity
function setTransferAddress(address allowedAddress) external
```

_set transfer address (DEFAULT_ADMIN_ROLE)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| allowedAddress | address | address to be allowed |

### forcedBurnCoins

```solidity
function forcedBurnCoins(address account, uint256 amount) external
```

_forced burn (ADMIN_ROLE)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | address where token has to be burned |
| amount | uint256 | amount of tokens to be burned |

### batchForcedBurnCoins

```solidity
function batchForcedBurnCoins(address[] account, uint256[] amount) external
```

_batch forced burn (ADMIN_ROLE)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address[] | address array where token has to be burned |
| amount | uint256[] | amount array of tokens to be burned |

### pause

```solidity
function pause() external
```

_pause this contract (ADMIN_ROLE)_

### unpause

```solidity
function unpause() external
```

_unpause this contract (ADMIN_ROLE)_

