# Solidity API

## IRHCertificateToken

### InvestmentRequest

```solidity
struct InvestmentRequest {
  address investor;
  uint256 amount;
  uint256 timestamp;
}
```

### DisinvestmentRequest

```solidity
struct DisinvestmentRequest {
  address investor;
  uint256 amount;
  uint256 timestamp;
}
```

### InvestmentLog

```solidity
struct InvestmentLog {
  address investor;
  bytes32 proofID;
  uint256 timestamp;
}
```

### Doc

```solidity
struct Doc {
  string docURI;
  bytes32 docHash;
  uint256 lastModified;
}
```

### DocHashAdded

```solidity
event DocHashAdded(uint256 num, string docuri, bytes32 dochash)
```

_new doc with hash added_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| num | uint256 | counter for document |
| docuri | string | link to external document |
| dochash | bytes32 | document hash |

### TokenExpired

```solidity
event TokenExpired(uint256 expirationBlock)
```

_token expired event_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| expirationBlock | uint256 | block number |

### Paused

```solidity
event Paused(address account)
```

_token paused event_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | pauser account |

### Unpaused

```solidity
event Unpaused(address account)
```

_token unpaused event_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | unpauser account |

### MintAllowance

```solidity
event MintAllowance(bool status, uint256 newStatusBlock)
```

_token mint allowance event_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| status | bool | true if mint operations allowed, false otherwise |
| newStatusBlock | uint256 | block number |

### CustomMintWithLogs

```solidity
event CustomMintWithLogs(address _account, uint256 newAmount, uint256 invLogLength, struct IRHCertificateToken.InvestmentLog invLogs)
```

_token mint with investment log number_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _account | address | investor account |
| newAmount | uint256 | token amount |
| invLogLength | uint256 | investor investments log length (0 = no log registered) |
| invLogs | struct IRHCertificateToken.InvestmentLog | investment logs structs array |

### DistributeAmount

```solidity
event DistributeAmount(address investor, uint256 grossAmount)
```

_token mint with investment log number_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| investor | address | investor account |
| grossAmount | uint256 | gross amount |

### WDAmount

```solidity
event WDAmount(address investor, uint256 grossAmount)
```

_operations allowed event_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| investor | address | investor address |
| grossAmount | uint256 | gross amount |

