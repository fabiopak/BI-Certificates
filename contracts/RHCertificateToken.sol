// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {IRHErrors} from "./interfaces/IRHErrors.sol";
import {IRHCertificatesFactory} from "./interfaces/IRHCertificatesFactory.sol";
import {IRHCertificateToken} from "./interfaces/IRHCertificateToken.sol";
// import "hardhat/console.sol";


abstract contract RHCertificateTokenStorage is IRHCertificateToken {
    bytes32 public constant PRICE_MANAGER_ROLE = keccak256("PRICE_MANAGER_ROLE");
    bytes32 public constant CERTIFICATE_ADMIN_ROLE = keccak256("CERTIFICATE_ADMIN_ROLE");
    bytes32 public constant FIAT_ADMIN_ROLE = keccak256("FIAT_ADMIN_ROLE");
    bytes32 public constant TRANSFER_AGENT_ROLE = keccak256("TRANSFER_AGENT_ROLE");

    address public certificatesFactoryAddress;
    address public distributionVault;
    address public distributionToken;
    address public paymentToken;

    uint8 public _decimals;
    uint8 public riskDegree;
    uint8 public certificateType;

    uint256 public maxTotalCap;
    uint256 public docsCounter;
    uint256 public valStartDate;
    uint256 public valEndDate;
    uint256 public maturityDate;
    uint256 public maxArrayLength;
    uint256 public nominalValue;
    uint256 public tokenBidPrice;
    uint256 public tokenAskPrice;
    uint256 public paymentDecimals;

    bool public paused;
    bool public mintAllowed;
    bool public tokenExpired;
    // bool public directMint; // always true

    string[] public isins;
    uint256[] public strikePrices;
    uint256[] public barrierPrices;
    uint256[] public couponBarrierPrices;
    bool public autoCall;

    /// @dev counter => Doc struct
    mapping(uint256 => Doc) public documents;

    /// @dev user => InvestmentRequest
    mapping (address => InvestmentRequest) public investmentRequests;

    /// @dev user => DisnvestmentRequest
    mapping (address => DisinvestmentRequest) public disinvestmentRequests;

    /// @dev user => SubscriberInvestment
    mapping (address => InvestmentLog) public investmentLogs;

    /// @dev contractAddress => boolean
    mapping(address => bool) public transferAddresses;

    /// @dev user => avgPrice
    mapping (address => uint256) public avgBuyPrices;
}


contract RHCertificateToken is Initializable, ERC20Upgradeable, AccessControlUpgradeable, OwnableUpgradeable, RHCertificateTokenStorage, IRHErrors, ReentrancyGuardUpgradeable {

    constructor() {
        _disableInitializers();
    }

    /**
    * @dev certificate token contract constructor 
    * @param _certificatesFactoryAddress certificate factory contract address
    * @param _tokenName token name
    * @param _tokenSymbol token symbol
    * @param _admin first admin address
    * @param _paymentToken payment token (if zero address = fiat)
    * @param _riskDegree certificate risk degree
    * @param _certificateType certificate type (web2 type)
    */
    function initialize(address _certificatesFactoryAddress, 
                string calldata _tokenName, 
                string calldata _tokenSymbol,
                address _admin, 
                address _paymentToken,
                uint256 _paymentDecs,
                uint8 _riskDegree,
                uint8 _certificateType) external initializer {
        __Ownable_init(msg.sender);
        __ERC20_init(_tokenName, _tokenSymbol);
        __AccessControl_init();
        __ReentrancyGuard_init();

        _decimals = 0;  // normally certificatres have no decimals!!!
        paymentDecimals = _paymentDecs;

        if (_certificatesFactoryAddress == address(0) || _admin == address(0)) {
            revert invalidAddress();
        }
        certificatesFactoryAddress = _certificatesFactoryAddress;
        riskDegree = _riskDegree;
        certificateType = _certificateType;

        paymentToken = _paymentToken;

        maxArrayLength = 100;

        // add admin
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    receive() external payable {
        revert();
    }

    /** @notice check if mint operations are allowed */
    modifier mintAllowance() {
        if (!mintAllowed) {
            revert mintNotAllowed();
        }
        _;
    }

    /** @notice check if token is not expired */
    modifier tokenNotExpired() {
        if (tokenExpired) {
            revert tokenIsExpired();
        }
        _;
    }

    /** @notice check if token is not paused */
    modifier whenNotPaused() {
        if (paused) {
            revert tokenAlreadyPaused();
        }
        _;
    }

    /**
    * @dev set certificate parameters (certificateAdminOnly)
    * @param _maxTotalCap max total cap
    * @param _vault distribution vault address
    * @param _token token address for distribution
    * @param _maturityDate expiration date
    */
    function setCertificateParameters(uint256 _maxTotalCap, 
                uint256 _nominalValue, 
                address _vault, 
                address _token, 
                uint256 _valStartDate,
                uint256 _valEndDate,
                uint256 _maturityDate) public onlyRole(CERTIFICATE_ADMIN_ROLE){
        maxTotalCap = _maxTotalCap;
        if (paymentToken != address(0)) {
            distributionVault = _vault;
            distributionToken = _token;
        }
        valStartDate = _valStartDate;
        valEndDate = _valEndDate;
        maturityDate = _maturityDate;
        nominalValue = _nominalValue;
    }

    /**
    * @dev set certificate parameters (certificateAdminOnly)
    * @param _isins underlying ISIN list
    * @param _strikePrices underlying ISIN strike prices
    * @param _barrierPrices uderlying ISIN barrier prices
    * @param _couponBarrierPrices underlying ISIN coupon barrier prices
    * @param _autoCall autocall feature enabled
    */
    function setCertificateOperativeParameters(string[] calldata _isins, 
                uint256[] calldata _strikePrices,
                uint256[] calldata _barrierPrices,
                uint256[] calldata _couponBarrierPrices,
                bool _autoCall) public onlyRole(CERTIFICATE_ADMIN_ROLE){
        if (_isins.length != _strikePrices.length || _isins.length != _barrierPrices.length || _isins.length != _couponBarrierPrices.length) {
            revert invalidArrayLength();
        }

        for (uint i = 0; i < isins.length; i++) {
            isins.push(_isins[i]);
            strikePrices.push(_strikePrices[i]);
            barrierPrices.push(_barrierPrices[i]);
            couponBarrierPrices.push(_couponBarrierPrices[i]);
        }
        
        autoCall = _autoCall;
    }

    /**
     * @dev set token expired (certificateAdminOnly), debt tokens only
     */
    function setTokenExpired() external tokenNotExpired onlyRole(CERTIFICATE_ADMIN_ROLE) {
        if (block.timestamp >= maturityDate) {
            tokenExpired = true;
            emit TokenExpired(block.number);
        } else {
            revert tokenCannotExpireYet();
        }
    }

    /**
     * @dev get token decimals
     * @return _decimals token decimals number
     */
    function decimals() public view override(ERC20Upgradeable) returns (uint8) {
        return _decimals;
    }

    /**
     * @dev set new max array length for txs (certificateAdminOnly)
     * @param _newLen new max array length
     */
    function setMaxArrayLen(uint256 _newLen) external onlyRole(CERTIFICATE_ADMIN_ROLE) {
        maxArrayLength = _newLen;
    }

    /**
     * @dev set token minting allowance (certificateAdminOnly)
     * @param _newVal true or false
     */
    function setMintAllowance(bool _newVal) external onlyRole(CERTIFICATE_ADMIN_ROLE) {
        mintAllowed = _newVal;
        emit MintAllowance(mintAllowed, block.number);
    }

    /**
     * @dev set token in pause (onlyTransferAgents)
     */
    function pause() external whenNotPaused tokenNotExpired onlyRole(CERTIFICATE_ADMIN_ROLE) {
        paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev remove token paused (onlyTransferAgents)
     */
    function unpause() external tokenNotExpired onlyRole(CERTIFICATE_ADMIN_ROLE) {
        if (!paused) {
            revert notPausedToken();
        }
        paused = false;
        emit Unpaused(msg.sender);
    }

    // /**
    //  * @dev set new max array length for txs (certificateAdminOnly)
    //  * @param _newValue enable or disable direct mint
    //  */
    // function setDirectMint(bool _newValue) external onlyRole(CERTIFICATE_ADMIN_ROLE) {
    //     directMint = _newValue;
    // }

    /**
     * @dev modified transfer function (onlyTransferAgents)
     * @param _to recipient address
     * @param _value tokens to transfer
     * @return success true or false
     */
    function transfer(address _to, uint256 _value) public override(ERC20Upgradeable) whenNotPaused tokenNotExpired onlyRole(TRANSFER_AGENT_ROLE)returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev modified transferFrom function (onlyTransferAgents)
     * @param _from sender address
     * @param _to recipient address
     * @param _value token amount to transfer
     * @return success true or false
     */
    function transferFrom(address _from, address _to, uint256 _value) public override(ERC20Upgradeable) whenNotPaused tokenNotExpired onlyRole(TRANSFER_AGENT_ROLE) returns (bool) {
        if (_to == address(0) || _from == address(0)) {
            revert invalidAddress();
        }
/*
        address blIdAddress = IRHIssuer(issuerContract).blockIDContract();
        (address issuer, , uint256 score, uint256 timestamp, , , ) = IRHBlockID(blIdAddress).soulIssuerProfiles(_to, issuerContract);
        bool issuerRequirements = IRHBlockID(blIdAddress).hasSoul(_to) && IRHBlockID(blIdAddress).isValidSoul(_to) && 
                timestamp >= block.timestamp && issuer == issuerContract && score >= riskDegree;

        if (!issuerRequirements) {
            revert wrongIDProcedures();
        }

        if (stEscrowAddress == _from) {
            revert notBuyerOrSeller();
        }
*/
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev investor deposit function (onlyTransferAgents)
     * @param _amount amount of tokens to deposit
     */
    function investorDeposit(uint256 _amount) public nonReentrant whenNotPaused tokenNotExpired {
        if (_amount == 0) {
            revert invalidAmount();
        }
        if (tokenAskPrice == 0) {
            revert invalidPrice();
        }

        uint256 newAmount = _amount * tokenAskPrice;

        if (paymentToken != address(0)) {
            SafeERC20.safeTransfer(IERC20(paymentToken), address(this), newAmount);

            uint256 prevToken = balanceOf(msg.sender);
            uint256 prevInv = prevToken * avgBuyPrices[msg.sender];
            avgBuyPrices[msg.sender] = calcAvgPrice(prevInv, prevToken, newAmount, _amount);
            super._mint(msg.sender, _amount);
        } else {
            investmentRequests[msg.sender].investor = msg.sender;
            investmentRequests[msg.sender].amount = _amount;
            investmentRequests[msg.sender].timestamp = block.timestamp;
        }
    }

    /**
     * @dev modified mint function (onlyTransferAgents), only if mint allowed (onlyTransferAgents)
     * @param _account recipient address
     * @param _amount amount of tokens to mint and send to recipient address
     */
    function managedMint(address _account, uint256 _amount, bytes32 _depositProof, uint256 _time) public nonReentrant whenNotPaused mintAllowance tokenNotExpired onlyRole(TRANSFER_AGENT_ROLE) {
        if (_amount == 0) {
            revert invalidAmount();
        }

        if (_account == address(0)) {
            revert invalidAddress();
        }

        if (!mintAllowed) {
            revert mintNotAllowed();
        }

        if (tokenAskPrice == 0) {
            revert invalidPrice();
        }

        InvestmentLog memory invLog = InvestmentLog({investor: _account, proofID: _depositProof, timestamp: _time});
        emit CustomMintWithLogs(_account, _amount, tokenAskPrice, invLog);

        super._mint(_account, _amount);
    }

    /**
     * @dev set transfer address (DEFAULT_ADMIN_ROLE)
     * @param allowedAddress address to be allowed
     */
    function setTransferAddress(address allowedAddress) external onlyRole(TRANSFER_AGENT_ROLE) {
        transferAddresses[allowedAddress] = true;
    }

    function _update(address from, address to, uint256 value) internal override whenNotPaused {
        if (from != address(0) && to!= address(0) && !transferAddresses[from] && !transferAddresses[to] ) {
            revert notTransferrable();
        } else if (to!= address(0)) {
            approve(to, value);
        }
        super._update(from, to, value);
    }

    /**
     * @dev buy average price calculation (external)
     * @param prevInv previous investment amount
     * @param prevToken previous token amount
     * @param newInv new investment amount
     * @param newToken new token amount
     */
    function calcAvgPrice(uint256 prevInv, uint256 prevToken, uint256 newInv, uint256 newToken) public pure returns (uint256) {
        // prima di assegnare le nuove quote!!!
        // solo investimento
            // investimento precedente
            // aggiungere nuovo investimento in euro
            // prendere nuove quote
            // dividere controvalore in euro per totale quote
        uint256 avgPrice = (prevInv + newInv) / (prevToken + newToken); // valid if token decimals = 0!!!
        return avgPrice;
    }

    /**
     * @dev distribute interests or dividends to token holders (onlyTransferAgents)
     * @param _investorWallets investor wallets array
     * @param totalDiv total dividend amount to distribute to all investors pro-quota o per token
     * @param dividendPerToken if the dividend is to divide pro-quota or to be multiplied per token
     */
    function distributeDividends(address[] calldata _investorWallets, uint256 totalDiv, bool dividendPerToken) external nonReentrant onlyRole(TRANSFER_AGENT_ROLE) {
        if(_investorWallets.length > maxArrayLength) {
            revert invalidArrayLength();
        }

        uint256 balance= 0;
        if (paymentToken != address(0)) {
            balance = IERC20(paymentToken).balanceOf(address(this));
        } else {
            balance = totalDiv;
        }

        uint256 invArrayLen = _investorWallets.length;
        uint256 tokenSupply = totalSupply();

        // uint8 blockReason;
        // address usufructuary;
        for (uint256 i = 0; i < invArrayLen; i++) {
            address investor = _investorWallets[i];
            uint256 userBal = balanceOf(investor);
            if (userBal > 0) {
                uint256 userAmount = 0;
                if (!dividendPerToken) {
                    userAmount = balance * userBal / tokenSupply;
                } else {
                    userAmount = (userBal * totalDiv);  // valid if token decimals = 0
                }

                // (blockReason, usufructuary) = investorConstraints(investor);

                // if ((blockReason == 4 || blockReason == 5) && usufructuary != address(0)) {
                //     investor = usufructuary;
                // }

                if (paymentToken != address(0)) {
                    SafeERC20.safeTransfer(IERC20(paymentToken), investor, userAmount);
                } 

                emit DistributeAmount(investor, userAmount);
            }
        }
    }

    /**
     * @dev nominal capital back to investor when token expires (onlyAdmins)
     * @param _investorWallets investor wallets array
     * @param finalPrice token exit price
     */
    function finalizeCertificate(address[] calldata _investorWallets, uint256 finalPrice) external onlyRole(TRANSFER_AGENT_ROLE) {
        if (tokenExpired) {
            revert tokenNotExpiredYet();
        }
        if(_investorWallets.length > maxArrayLength) {
            revert invalidArrayLength();
        }

        for (uint256 i = 0; i < _investorWallets.length; i ++) {
            address investor = _investorWallets[i];
            uint256 invBalance = balanceOf(investor);
            // taxAmount = 0;
            if (invBalance > 0) { 
                super._burn(investor, invBalance);
                uint256 userAmount = invBalance * finalPrice;   // valid if token decimals = 0

                if (paymentToken != address(0)) {
                    SafeERC20.safeTransfer(IERC20(paymentToken), investor, userAmount);
                } 

                emit DistributeAmount(investor, userAmount);
            } 
        }
    }

    function investorWithdraw(uint256 _amount) external {
        if (tokenBidPrice == 0) {
            revert invalidPrice();
        }

        if(balanceOf(msg.sender) < _amount) {
            revert notEnoughBalance();
        }

        if (paymentToken != address(0)) {
            uint256 balance = IERC20(paymentToken).balanceOf(address(this));
            uint256 payAmount = _amount * tokenBidPrice;    // valid if token decimals = 0

            if (balance >= payAmount) {
                super._burn(msg.sender, _amount);
                SafeERC20.safeTransfer(IERC20(paymentToken), msg.sender, payAmount);
            } else {
                disinvestmentRequests[msg.sender].investor = msg.sender;
                disinvestmentRequests[msg.sender].amount = _amount;
                disinvestmentRequests[msg.sender].timestamp = block.timestamp;
            }
        } else {
            disinvestmentRequests[msg.sender].investor = msg.sender;
            disinvestmentRequests[msg.sender].amount = _amount;
            disinvestmentRequests[msg.sender].timestamp = block.timestamp;
        }
    }

    function managedWithdraw(address _investor, uint256 _amount) external {
        if (tokenBidPrice == 0) {
            revert invalidPrice();
        }

        if(balanceOf(msg.sender) < _amount) {
            revert notEnoughBalance();
        }

        uint256 payAmount = _amount * tokenBidPrice;    // valid if token decimals = 0

        if (paymentToken != address(0)) {
            uint256 balance = IERC20(paymentToken).balanceOf(address(this));

            if (balance >= payAmount) {
                super._burn(msg.sender, _amount);
                SafeERC20.safeTransfer(IERC20(paymentToken), _investor, payAmount);
            } else {
                revert notEnoughBalance();
            }
        } 
        emit WDAmount(_investor, payAmount);
    }


    /**
     * @dev set a new document structure to store in the list, queueing it if others exist and incrementing documents counter (certificateAdminOnly)
     * @param uri document URL
     * @param documentHash Hash to add to list
     */
    function addNewDocument(string calldata uri, bytes32 documentHash) external onlyRole(CERTIFICATE_ADMIN_ROLE) {
        documents[docsCounter] = Doc({docURI: uri, docHash: documentHash, lastModified: block.timestamp});
        docsCounter++; //prepare for next doc to add
        emit DocHashAdded(docsCounter, uri, documentHash);
    }

    /**
     * @dev updates security token price (onlyPriceSetter)
     * @param _newBidPrice new security token bid price (scaled to payment tokens decimals)
     * @param _newAskPrice new security token ask price (scaled to payment tokens decimals)
     */
    function setPrice(uint256 _newBidPrice, uint256 _newAskPrice) public onlyRole(PRICE_MANAGER_ROLE) {
        if (_newBidPrice == 0 || _newAskPrice == 0) {
            revert invalidPrice();
        }
        tokenBidPrice = _newBidPrice;
        tokenAskPrice = _newAskPrice;
    }

    /**
	 * @notice Emergency function to withdraw stuck tokens (onlyAdmins)
	 * @param _token token address
	 * @param _to receiver address
	 * @param _amount token amount
	 */
	function emergencyTokenTransfer(address _token, address _to, uint256 _amount) external nonReentrant onlyRole(CERTIFICATE_ADMIN_ROLE) {
        if(_token != address(0)) {
			SafeERC20.safeTransfer(IERC20(_token), _to, _amount);
		}
    }

}