// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {IRHCertificatesFactory} from "./interfaces/IRHCertificatesFactory.sol";
import {RHCertificateToken, OwnableUpgradeable, IRHErrors} from "./RHCertificateToken.sol";

abstract contract RHCertificatesFactoryStorage is IRHCertificatesFactory {
    bytes32 public constant FACTORY_ADMIN_ROLE = keccak256("FACTORY_ADMIN_ROLE");

    uint256 public certificatesCounter;

    address public loansLogic;

    /// @dev user => deployed
    mapping(address => bool) public isCertificateDeployed;

    address[] public deployedCertificates;
}


contract RHCertificatesFactory is UUPSUpgradeable, AccessControlUpgradeable, OwnableUpgradeable, RHCertificatesFactoryStorage, IRHErrors {

    UpgradeableBeacon public loansBeacon;
    
    function initialize (address _vLogic, address _admin) external initializer onlyProxy { 
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        if (_vLogic == address(0) || _admin == address(0)) {
            revert invalidAddress();
        }
        loansBeacon = new UpgradeableBeacon(_vLogic, address(this));
        loansLogic = _vLogic;
        certificatesCounter = 0;

        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    /** 
     * @dev required by the UUPS module
     */
    function _authorizeUpgrade(address) internal override onlyOwner {}

    /**
     * @dev Beacon: update procedures 
     * @param _vLogic new logic implementation
     */
    function update(address _vLogic) external onlyOwner {
        loansBeacon.upgradeTo(_vLogic);
        loansLogic = _vLogic;
    }

    receive() external payable {
        revert();
    }    

    /**
     * @dev create a new certificate
     * @param _tokenName token name
     * @param _tokenSymbol token symbol
     * @param _decs token decimals
     * @return proxy loan address
     */
    function createCertificate(string calldata _tokenName, 
                string calldata _tokenSymbol,
                address _admin, 
                address _paymentToken,
                uint8 _decs,
                uint8 _riskDegree,
                uint8 _certificateType)  external onlyRole(FACTORY_ADMIN_ROLE) returns (address) {

        BeaconProxy proxy = new BeaconProxy(address(loansBeacon), 
            abi.encodeWithSelector(RHCertificateToken(payable(address(0))).initialize.selector, address(this), _tokenName, _tokenSymbol, _admin, _paymentToken, _decs, _riskDegree, _certificateType) );
        deployedCertificates.push(address(proxy));
        isCertificateDeployed[address(proxy)] = true;
        emit LoanCreated(address(proxy), address(this));
        certificatesCounter++;

        return address(proxy);
    }

    /**
	 * @notice Emergency function to withdraw stuck tokens (onlyAdmins)
	 * @param _token token address
	 * @param _to receiver address
	 * @param _amount token amount
	 */
	function emergencyTokenTransfer(address _token, address _to, uint256 _amount) external onlyRole(FACTORY_ADMIN_ROLE) {
        if(_token != address(0)) {
			SafeERC20.safeTransfer(IERC20(_token), _to, _amount);
		}
    }
}