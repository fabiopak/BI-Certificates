// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface IRHCertificatesFactory {
    /**
     * @dev loan created event
     * @param account new investor account deployed
     * @param loanFactory investor factory address 
     */
    event LoanCreated(address indexed account, address loanFactory);
}