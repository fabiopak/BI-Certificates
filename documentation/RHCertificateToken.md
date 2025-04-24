# Solidity API

## RHCertificateTokenStorage

### PRICE_MANAGER_ROLE

```solidity
bytes32 PRICE_MANAGER_ROLE
```

### CERTIFICATE_ADMIN_ROLE

```solidity
bytes32 CERTIFICATE_ADMIN_ROLE
```

### FIAT_ADMIN_ROLE

```solidity
bytes32 FIAT_ADMIN_ROLE
```

### TRANSFER_AGENT_ROLE

```solidity
bytes32 TRANSFER_AGENT_ROLE
```

### certificatesFactoryAddress

```solidity
address certificatesFactoryAddress
```

### distributionVault

```solidity
address distributionVault
```

### distributionToken

```solidity
address distributionToken
```

### paymentToken

```solidity
address paymentToken
```

### _decimals

```solidity
uint8 _decimals
```

### riskDegree

```solidity
uint8 riskDegree
```

### certificateType

```solidity
uint8 certificateType
```

### maxTotalCap

```solidity
uint256 maxTotalCap
```

### docsCounter

```solidity
uint256 docsCounter
```

### valStartDate

```solidity
uint256 valStartDate
```

### valEndDate

```solidity
uint256 valEndDate
```

### maturityDate

```solidity
uint256 maturityDate
```

### maxArrayLength

```solidity
uint256 maxArrayLength
```

### nominalValue

```solidity
uint256 nominalValue
```

### tokenBidPrice

```solidity
uint256 tokenBidPrice
```

### tokenAskPrice

```solidity
uint256 tokenAskPrice
```

### paymentDecimals

```solidity
uint256 paymentDecimals
```

### paused

```solidity
bool paused
```

### mintAllowed

```solidity
bool mintAllowed
```

### tokenExpired

```solidity
bool tokenExpired
```

### isins

```solidity
string[] isins
```

### strikePrices

```solidity
uint256[] strikePrices
```

### barrierPrices

```solidity
uint256[] barrierPrices
```

### couponBarrierPrices

```solidity
uint256[] couponBarrierPrices
```

### autoCall

```solidity
bool autoCall
```

### documents

```solidity
mapping(uint256 => struct IRHCertificateToken.Doc) documents
```

_counter => Doc struct_

### investmentRequests

```solidity
mapping(address => struct IRHCertificateToken.InvestmentRequest) investmentRequests
```

_user => InvestmentRequest_

### disinvestmentRequests

```solidity
mapping(address => struct IRHCertificateToken.DisinvestmentRequest) disinvestmentRequests
```

_user => DisnvestmentRequest_

### investmentLogs

```solidity
mapping(address => struct IRHCertificateToken.InvestmentLog) investmentLogs
```

_user => SubscriberInvestment_

### transferAddresses

```solidity
mapping(address => bool) transferAddresses
```

_contractAddress => boolean_

### avgBuyPrices

```solidity
mapping(address => uint256) avgBuyPrices
```

_user => avgPrice_

## RHCertificateToken

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(address _certificatesFactoryAddress, string _tokenName, string _tokenSymbol, address _admin, address _paymentToken, uint256 _paymentDecs, uint8 _riskDegree, uint8 _certificateType) external
```

_certificate token contract constructor_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _certificatesFactoryAddress | address | certificate factory contract address |
| _tokenName | string | token name |
| _tokenSymbol | string | token symbol |
| _admin | address | first admin address |
| _paymentToken | address | payment token (if zero address = fiat) |
| _paymentDecs | uint256 |  |
| _riskDegree | uint8 | certificate risk degree |
| _certificateType | uint8 | certificate type (web2 type) |

### receive

```solidity
receive() external payable
```

### mintAllowance

```solidity
modifier mintAllowance()
```

check if mint operations are allowed

### tokenNotExpired

```solidity
modifier tokenNotExpired()
```

check if token is not expired

### whenNotPaused

```solidity
modifier whenNotPaused()
```

check if token is not paused

### setCertificateParameters

```solidity
function setCertificateParameters(uint256 _maxTotalCap, uint256 _nominalValue, address _vault, address _token, uint256 _valStartDate, uint256 _valEndDate, uint256 _maturityDate) public
```

_set certificate parameters (certificateAdminOnly)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _maxTotalCap | uint256 | max total cap |
| _nominalValue | uint256 |  |
| _vault | address | distribution vault address |
| _token | address | token address for distribution |
| _valStartDate | uint256 |  |
| _valEndDate | uint256 |  |
| _maturityDate | uint256 | expiration date |

### setCertificateOperativeParameters

```solidity
function setCertificateOperativeParameters(string[] _isins, uint256[] _strikePrices, uint256[] _barrierPrices, uint256[] _couponBarrierPrices, bool _autoCall) public
```

_set certificate parameters (certificateAdminOnly)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _isins | string[] | underlying ISIN list |
| _strikePrices | uint256[] | underlying ISIN strike prices |
| _barrierPrices | uint256[] | uderlying ISIN barrier prices |
| _couponBarrierPrices | uint256[] | underlying ISIN coupon barrier prices |
| _autoCall | bool | autocall feature enabled |

### setTokenExpired

```solidity
function setTokenExpired() external
```

_set token expired (certificateAdminOnly), debt tokens only_

### decimals

```solidity
function decimals() public view returns (uint8)
```

_get token decimals_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint8 | _decimals token decimals number |

### setMaxArrayLen

```solidity
function setMaxArrayLen(uint256 _newLen) external
```

_set new max array length for txs (certificateAdminOnly)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _newLen | uint256 | new max array length |

### setMintAllowance

```solidity
function setMintAllowance(bool _newVal) external
```

_set token minting allowance (certificateAdminOnly)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _newVal | bool | true or false |

### pause

```solidity
function pause() external
```

_set token in pause (onlyTransferAgents)_

### unpause

```solidity
function unpause() external
```

_remove token paused (onlyTransferAgents)_

### transfer

```solidity
function transfer(address _to, uint256 _value) public returns (bool)
```

_modified transfer function (onlyTransferAgents)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _to | address | recipient address |
| _value | uint256 | tokens to transfer |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | success true or false |

### transferFrom

```solidity
function transferFrom(address _from, address _to, uint256 _value) public returns (bool)
```

_modified transferFrom function (onlyTransferAgents)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _from | address | sender address |
| _to | address | recipient address |
| _value | uint256 | token amount to transfer |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | success true or false |

### investorDeposit

```solidity
function investorDeposit(uint256 _amount) public
```

_investor deposit function (onlyTransferAgents)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amount | uint256 | amount of tokens to deposit |

### managedMint

```solidity
function managedMint(address _account, uint256 _amount, bytes32 _depositProof, uint256 _time) public
```

_modified mint function (onlyTransferAgents), only if mint allowed (onlyTransferAgents)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _account | address | recipient address |
| _amount | uint256 | amount of tokens to mint and send to recipient address |
| _depositProof | bytes32 |  |
| _time | uint256 |  |

### setTransferAddress

```solidity
function setTransferAddress(address allowedAddress) external
```

_set transfer address (DEFAULT_ADMIN_ROLE)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| allowedAddress | address | address to be allowed |

### _update

```solidity
function _update(address from, address to, uint256 value) internal
```

_Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
(or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
this function.

Emits a {Transfer} event._

### calcAvgPrice

```solidity
function calcAvgPrice(uint256 prevInv, uint256 prevToken, uint256 newInv, uint256 newToken) public pure returns (uint256)
```

_buy average price calculation (external)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| prevInv | uint256 | previous investment amount |
| prevToken | uint256 | previous token amount |
| newInv | uint256 | new investment amount |
| newToken | uint256 | new token amount |

### distributeDividends

```solidity
function distributeDividends(address[] _investorWallets, uint256 totalDiv, bool dividendPerToken) external
```

_distribute interests or dividends to token holders (onlyTransferAgents)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _investorWallets | address[] | investor wallets array |
| totalDiv | uint256 | total dividend amount to distribute to all investors pro-quota o per token |
| dividendPerToken | bool | if the dividend is to divide pro-quota or to be multiplied per token |

### finalizeCertificate

```solidity
function finalizeCertificate(address[] _investorWallets, uint256 finalPrice) external
```

_nominal capital back to investor when token expires (onlyAdmins)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _investorWallets | address[] | investor wallets array |
| finalPrice | uint256 | token exit price |

### investorWithdraw

```solidity
function investorWithdraw(uint256 _amount) external
```

### managedWithdraw

```solidity
function managedWithdraw(address _investor, uint256 _amount) external
```

### addNewDocument

```solidity
function addNewDocument(string uri, bytes32 documentHash) external
```

_set a new document structure to store in the list, queueing it if others exist and incrementing documents counter (certificateAdminOnly)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| uri | string | document URL |
| documentHash | bytes32 | Hash to add to list |

### setPrice

```solidity
function setPrice(uint256 _newBidPrice, uint256 _newAskPrice) public
```

_updates security token price (onlyPriceSetter)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _newBidPrice | uint256 | new security token bid price (scaled to payment tokens decimals) |
| _newAskPrice | uint256 | new security token ask price (scaled to payment tokens decimals) |

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

