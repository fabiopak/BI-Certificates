// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IRHErrors} from "../interfaces/IRHErrors.sol";
import {IRHLoansFactory} from "../interfaces/IRHLoansFactory.sol";
import {IRHLoans} from "../interfaces/IRHLoans.sol";


abstract contract RHLoansStorage is IRHLoans {
    address public loanFactoryAddress;
    address public distributionVault;
    address public distributionToken;

    bytes public loanData;

    uint256 public maxTotalCap;
    uint256 public residualTotalCap;
    uint256 public issuedTotalLoansAmount;
    // uint256 public baseInterest; //scaled by 1e18
    uint256 public borrowersCounter;
    uint256 public loanAdminsCounter;

    /// @dev company => loan cap
    mapping(address => uint256) public loansCaps;
    /// @dev company => loan issued
    mapping(address => uint256) public loansIssued;
    /// @dev company => outstanding loan amount
    mapping(address => uint256) public outstandingAmounts;
    /// @dev admin => loan administrators
    mapping(address => bool) public loanAdmins;
    /// @dev company => is borrower
    mapping(address => bool) public isBorrower;
    /// @dev company => goal result
    mapping(address => ImpactKPIs) public kpiStatuses;

    //* New storage variables */
    uint256 public baseInterest; //scaled by 1e18
    mapping(address => uint256) public loansInterests;
    mapping(address => ImpactKPIs) public goalResults;
}


contract RHLoansV2 is Initializable, OwnableUpgradeable, RHLoansStorage, IRHErrors, ReentrancyGuardUpgradeable {

    constructor() {
        _disableInitializers();
    }

    /**
    * @dev investor contract constructor 
    * @param _loanFactoryAddress investor factory contract address
    * @param _data investor contract data
    */
    function initialize(address _loanFactoryAddress, bytes calldata _data) external initializer {
        __Ownable_init(msg.sender);
        __ReentrancyGuard_init();
        loanFactoryAddress = _loanFactoryAddress;
        loanData = _data;
    }

    receive() external payable {
        revert();
    }

    /** @notice check if msg.sender is an owner or an admin */
    modifier adminOrOwnerOnly() {
        if (!IRHLoansFactory(loanFactoryAddress).isLoansFactoryAdmin(msg.sender) && msg.sender != owner() && msg.sender != loanFactoryAddress) {
            revert notAdministrator();
        }
        _;
    }

    /**
    * @dev add global parameters
    * @param _maxTotalCap max total cap
    * @param _baseInterest base interest
    * @param _vault distribution vault address
    * @param _token token address for distribution
    */
    function setGlobalParameters(uint256 _maxTotalCap, uint256 _baseInterest, address _vault, address _token) public adminOrOwnerOnly{
        maxTotalCap = _maxTotalCap;
        baseInterest = _baseInterest;
        residualTotalCap = maxTotalCap;
        distributionVault = _vault;
        distributionToken = _token;
    }

    /**
     * @dev set borrower parameters (internal)
     * @param _borrower borrower address
     * @param _maxLoanCap max loan cap
     * @param _interest loan interest
     * @param _status loan initial status
     */
    function setBorrowerParameters(address _borrower, uint256 _maxLoanCap, int256 _interest, ImpactKPIs calldata _status) internal adminOrOwnerOnly {
        residualTotalCap += loansCaps[_borrower];

        if (_maxLoanCap > residualTotalCap) {
            loansCaps[_borrower] = residualTotalCap;
            if(loansCaps[_borrower] == 0) {
                revert maxTotalCapReached();
            }
        } else {
            loansCaps[_borrower] = _maxLoanCap;
        }
        residualTotalCap -= loansCaps[_borrower];

        if(_interest < 0) {
            loansInterests[_borrower] = baseInterest;
        } else {
            loansInterests[_borrower] = uint256(_interest);
        }

        goalResults[_borrower] = _status;
    }

    /**
     * @dev add loan parameters
     * @param _borrower borrower address
     * @param _maxLoanCap max loan cap
     * @param _interest loan interest
     * @param _status loan initial status
     */
    function addBorrowerParameters(address _borrower, uint256 _maxLoanCap, int256 _interest, ImpactKPIs calldata _status) public adminOrOwnerOnly {
        if(isBorrower[_borrower]) {
            revert existingBorrower();
        }
        isBorrower[_borrower] = true;

        setBorrowerParameters(_borrower, _maxLoanCap, _interest, _status);

        loansIssued[_borrower] = 0;

        borrowersCounter++;
    }

    /**
     * @dev remove loan parameters
     * @param _borrower borrower address
     */
    function removeBorrowerParameters(address _borrower) public adminOrOwnerOnly {
        if(!isBorrower[_borrower]) {
            revert nonExistingBorrower();
        }

        isBorrower[_borrower] = false;
        residualTotalCap += loansCaps[_borrower];

        delete loansCaps[_borrower];
        delete loansIssued[_borrower];
        delete loansInterests[_borrower];
        delete goalResults[_borrower];

        if(borrowersCounter > 0) {
            borrowersCounter--;
        } else {
            borrowersCounter = 0;
        }
    }

    /**
     * @dev update loan parameters
     * @param _borrower borrower address
     * @param _maxLoanCap max loan cap
     * @param _interest loan interest
     * @param _status update loan status
     */
    function updateBorrowerParameters(address _borrower, uint256 _maxLoanCap, int256 _interest, ImpactKPIs calldata _status) public adminOrOwnerOnly {
        if(!isBorrower[_borrower]) {
            revert nonExistingBorrower();
        }

        setBorrowerParameters(_borrower, _maxLoanCap, _interest, _status);
    }

    /**
     * @dev add money to borrower loan
     * @param _borrower borrower address
     * @param _newAmount new amount
     * @param _interest loan interest
     * @param _status loan status
     */
    function issueLoans(address _borrower, uint256 _newAmount, int256 _interest, ImpactKPIs calldata _status) public adminOrOwnerOnly {
        if(!isBorrower[_borrower]) {
            revert nonExistingBorrower();
        }
        
        uint256 newIssuedAmount = loansIssued[_borrower] + _newAmount;
        uint256 newAmount = _newAmount;
        if (newIssuedAmount > loansCaps[_borrower]) {
            newIssuedAmount = loansCaps[_borrower] - loansIssued[_borrower];
            newAmount = newIssuedAmount;
        }
        loansIssued[_borrower] += newAmount;

        if (distributionToken != address(0)) {
            SafeERC20.safeTransferFrom(IERC20(distributionToken), distributionVault, _borrower, newAmount);
        }

        if (issuedTotalLoansAmount < maxTotalCap) {
            issuedTotalLoansAmount += newAmount;
        } else {
            issuedTotalLoansAmount = maxTotalCap;
        }

        if (_interest < 0) {
            loansInterests[_borrower] = baseInterest;
        } else {
            loansInterests[_borrower] = uint256(_interest);
        }

        goalResults[_borrower] = _status;
    }

    function getInfo() external pure returns (uint256) {
        return 2;
    }

// ... rest of the code
}