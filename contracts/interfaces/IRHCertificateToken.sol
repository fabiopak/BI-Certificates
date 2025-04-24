// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface IRHCertificateToken {
    struct InvestmentRequest {
        address investor;   // investor address
        uint256 amount;     // requested token amount
        uint256 timestamp;  // timestamp
    }

    struct DisinvestmentRequest {
        address investor;   // investor address
        uint256 amount;     // requested token amount
        uint256 timestamp;  // timestamp
    }

    struct InvestmentLog {
        address investor;   // investor address
        bytes32 proofID;    // bank transfer proof ID (CRO)
        uint256 timestamp;  // timestamp
    }

    struct Doc {
        string docURI;          // URI of the document that exist off-chain
        bytes32 docHash;        // Hash of the document
        uint256 lastModified;   // Timestamp at which document details was last modified
    }

    /**
     * @dev new doc with hash added
     * @param num counter for document
     * @param docuri link to external document
     * @param dochash document hash
     */
    event DocHashAdded(uint256 indexed num, string docuri, bytes32 dochash);

    /**
     * @dev token expired event
     * @param expirationBlock block number
     */
    event TokenExpired(uint256 expirationBlock);

        /**
     * @dev token paused event
     * @param account pauser account
     */
    event Paused(address account);

    /**
     * @dev token unpaused event
     * @param account unpauser account
     */
    event Unpaused(address account);

    /**
     * @dev token mint allowance event
     * @param status true if mint operations allowed, false otherwise
     * @param newStatusBlock block number
     */
    event MintAllowance(bool status, uint256 newStatusBlock);

    /**
     * @dev token mint with investment log number
     * @param _account investor account
     * @param newAmount token amount
     * @param invLogLength investor investments log length (0 = no log registered)
     * @param invLogs investment logs structs array 
     */
    event CustomMintWithLogs(address _account, uint256 newAmount, uint256 invLogLength, InvestmentLog invLogs);

    /**
     * @dev token mint with investment log number
     * @param investor investor account
     * @param grossAmount gross amount
     */
    event DistributeAmount(address investor, uint256 grossAmount);

    /**
     * @dev operations allowed event
     * @param investor investor address
     * @param grossAmount gross amount
     */
    event WDAmount(address investor, uint256 grossAmount);
}