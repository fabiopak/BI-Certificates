# Solidity API

## RHCertificatesFactoryStorage

### FACTORY_ADMIN_ROLE

```solidity
bytes32 FACTORY_ADMIN_ROLE
```

### certificatesCounter

```solidity
uint256 certificatesCounter
```

### loansLogic

```solidity
address loansLogic
```

### isCertificateDeployed

```solidity
mapping(address => bool) isCertificateDeployed
```

_user => deployed_

### deployedCertificates

```solidity
address[] deployedCertificates
```

## RHCertificatesFactory

### loansBeacon

```solidity
contract UpgradeableBeacon loansBeacon
```

### initialize

```solidity
function initialize(address _vLogic, address _admin) external
```

### _authorizeUpgrade

```solidity
function _authorizeUpgrade(address) internal
```

_required by the UUPS module_

### update

```solidity
function update(address _vLogic) external
```

_Beacon: update procedures_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _vLogic | address | new logic implementation |

### receive

```solidity
receive() external payable
```

### createCertificate

```solidity
function createCertificate(string _tokenName, string _tokenSymbol, address _admin, address _paymentToken, uint8 _decs, uint8 _riskDegree, uint8 _certificateType) external returns (address)
```

_create a new certificate_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenName | string | token name |
| _tokenSymbol | string | token symbol |
| _admin | address |  |
| _paymentToken | address |  |
| _decs | uint8 | token decimals |
| _riskDegree | uint8 |  |
| _certificateType | uint8 |  |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address | proxy loan address |

### emergencyTokenTransfer

```solidity
function emergencyTokenTransfer(address _token, address _to, uint256 _amount) external
```

Emergency function to withdraw stuck tokens (onlyAdmins)

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _token | address | token address |
| _to | address | receiver address |
| _amount | uint256 | token amount |

