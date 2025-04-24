// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface IRHErrors {
    error invalidAddress();
    error invalidArrayLength();
    error notTransferrable();

    /** certificates */
    error mintNotAllowed();
    error tokenIsExpired();
    error tokenCannotExpireYet();
    error tokenAlreadyPaused();
    error notPausedToken();
    error invalidAmount();
    error invalidPrice();
    error tokenNotExpiredYet();
    error notEnoughBalance();

}