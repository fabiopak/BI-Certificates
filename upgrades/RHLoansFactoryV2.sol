// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {IRHCertificatesFactory} from "../interfaces/IRHCertificatesFactory.sol";
import {RHLoansV2, OwnableUpgradeable, IRHErrors} from "./RHLoansV2.sol";
// import {RHLoansBeacon} from "./RHLoansBeacon.sol";


abstract contract RHLoansFactoryStorage is IRHLoansFactory {
    uint256 public certificatesCounter;
    uint256 public loansFactoryAdminCounter;
    address public loansLogic;

    /// @dev admin => factory administrators
    mapping(address => bool) public loanFactoryAdmins;

    /// @dev user => deployed
    mapping(address => bool) public isLoanDeployed;

    address[] public deployedLoans;
}


contract RHLoansFactoryV2 is UUPSUpgradeable, OwnableUpgradeable, RHLoansFactoryStorage, IRHErrors {

    UpgradeableBeacon public loansBeacon;

    function initialize (address _vLogic, address _admin) external initializer onlyProxy { 
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        loansBeacon = new UpgradeableBeacon(_vLogic, address(this));
        loansLogic = _vLogic;
        certificatesCounter = 0;
        loanFactoryAdmins[_admin] = true;
        loansFactoryAdminCounter = 1;
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

    /** @notice check if msg.sender is an investor admin */
    modifier loanFactoryAdminOnly() {
        if (!isLoansFactoryAdmin(msg.sender)) {
            revert notAdministrator();
        }
        _;
    }

    /*  Loans factory Admins Roles Mngmt  */
    /**
    * @dev add an admin to this issuer
    * @param account new admin address
    */
    function addAdmin(address account) external loanFactoryAdminOnly {
        if(isLoansFactoryAdmin(account)) {
            revert alreadyAdmin();
        }
        loanFactoryAdmins[account] = true;
        loansFactoryAdminCounter++;
    }

    /**
    * @dev remove an admin from this issuer (onlyAdmins). There could be no admin
    * @param account admin address to be removed
    */
    function removeAdmin(address account) external loanFactoryAdminOnly {
        if(!loanFactoryAdmins[account]) {
            revert notAdministrator();
        }
        if (loansFactoryAdminCounter == 1) {
            revert cantRemoveLastAdmin();
        }
        loansFactoryAdminCounter--;
        loanFactoryAdmins[account] = false;
    }

    /**
    * @dev check if an address is an admin for this issuer
    * @param account admin address to check
    * @return _Admins[account] true or false
    */
    function isLoansFactoryAdmin(address account) public view returns (bool) {
        return loanFactoryAdmins[account];
    }

    /**
     * @dev create a new loan
     * @param _loanData loan data
     * @return proxy loan address
     */
    function createLoan(bytes calldata _loanData, address _loanAdmin) external loanFactoryAdminOnly returns (address) {
        if(_loanAdmin == address(0)) {
            revert invalidAddress();
        }
        BeaconProxy proxy = new BeaconProxy(address(loansBeacon), 
            abi.encodeWithSelector(RHLoansV2(payable(address(0))).initialize.selector, address(this), _loanData, _loanAdmin) );
        deployedLoans.push(address(proxy));
        isLoanDeployed[address(proxy)] = true;
        emit LoanCreated(address(proxy), address(this));
        certificatesCounter++;

        return address(proxy);
    }

    function getInfo() external pure returns (uint256) {
        return 2;
    }
}