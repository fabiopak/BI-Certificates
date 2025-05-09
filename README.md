# BI-Loans
Loans project

## Main contracts - Name and Description

<table>
    <thead>
      <tr>
        <th>Name</th>
        <th>Description</th>
      </tr>
    </thead>
    <tbody>
        <tr>
            <td>RHLoans</td>
            <td>Loans contract</td>
        </tr>
        <tr>
            <td>RHLoansFactory</td>
            <td>Loans contracts factory</td>
        </tr>
        <tr>
    </tbody>
</table>


## Compiler & Optimizer results

```
 ·------------------------|--------------------------------|--------------------------------·
 |  Solc version: 0.8.27  ·  Optimizer enabled: true       ·  Runs: 1000                    │
 ·························|································|·································
 |  Contract Name         ·  Deployed size (KiB) (change)  ·  Initcode size (KiB) (change)  │
 ·························|································|·································
 |  Address               ·                 0.084 (0.000)  ·                 0.138 (0.000)  │
 ·························|································|·································
 |  BeaconProxy           ·                 0.325 (0.000)  ·                 1.479 (0.000)  │
 ·························|································|·································
 |  EnumerableSet         ·                 0.084 (0.000)  ·                 0.138 (0.000)  │
 ·························|································|·································
 |  ERC1967Utils          ·                 0.084 (0.000)  ·                 0.138 (0.000)  │
 ·························|································|·································
 |  Errors                ·                 0.084 (0.000)  ·                 0.138 (0.000)  │
 ·························|································|·································
 |  LiquidityToken        ·                 2.723 (0.000)  ·                 3.592 (0.000)  │
 ·························|································|·································
 |  RHLoans               ·                 8.268 (0.000)  ·                 8.479 (0.000)  │
 ·························|································|·································
 |  RHLoansFactory        ·                 8.236 (0.000)  ·                 8.296 (0.000)  │
 ·························|································|·································
 |  RHLoansFactoryV2      ·                 7.794 (0.000)  ·                 7.854 (0.000)  │
 ·························|································|·································
 |  RHLoansV2             ·                 6.745 (0.000)  ·                 6.957 (0.000)  │
 ·························|································|·································
 |  SafeERC20             ·                 0.084 (0.000)  ·                 0.138 (0.000)  │
 ·························|································|·································
 |  StableCoin18Decs      ·                 6.348 (0.000)  ·                 7.660 (0.000)  │
 ·························|································|·································
 |  StableCoin6Decs       ·                 6.448 (0.000)  ·                 7.784 (0.000)  │
 ·························|································|·································
 |  StorageSlot           ·                 0.084 (0.000)  ·                 0.138 (0.000)  │
 ·························|································|·································
 |  UpgradeableBeacon     ·                 0.756 (0.000)  ·                 1.169 (0.000)  │
 ·------------------------|--------------------------------|--------------------------------·
```


## Test percentage via solidity coverage

```
-----------------------|----------|----------|----------|----------|----------------|
File                   |  % Stmts | % Branch |  % Funcs |  % Lines |Uncovered Lines |
-----------------------|----------|----------|----------|----------|----------------|
 contracts/            |      100 |    56.38 |      100 |     87.4 |                |
  RHLoans.sol          |      100 |    59.68 |      100 |    87.91 |... 245,253,299 |
  RHLoansFactory.sol   |      100 |       50 |      100 |    86.11 |34,64,76,88,113 |
 contracts/interfaces/ |      100 |      100 |      100 |      100 |                |
  IRHErrors.sol        |      100 |      100 |      100 |      100 |                |
  IRHLoans.sol         |      100 |      100 |      100 |      100 |                |
  IRHLoansFactory.sol  |      100 |      100 |      100 |      100 |                |
 contracts/mocks/      |     2.78 |     1.52 |      8.7 |        2 |                |
  IStableCoin.sol      |      100 |      100 |      100 |      100 |                |
  LiquidityToken.sol   |      100 |       50 |      100 |       50 |             12 |
  StableCoin18Decs.sol |        0 |        0 |        0 |        0 |... 108,117,124 |
  StableCoin6Decs.sol  |        0 |        0 |        0 |        0 |... 120,129,136 |
 contracts/upgrades/   |     5.56 |        0 |    10.53 |     2.08 |                |
  RHLoansFactoryV2.sol |     7.14 |        0 |    11.11 |     3.03 |... 117,118,120 |
  RHLoansV2.sol        |     4.55 |        0 |       10 |     1.59 |... 213,216,220 |
-----------------------|----------|----------|----------|----------|----------------|
All files              |    44.35 |    24.11 |    44.12 |    41.76 |                |
-----------------------|----------|----------|----------|----------|----------------|
```


## Gas report

```
······················································································································
|  Solidity and Network Configuration                                                                                │
·································|················|················|·················|································
|  Solidity: 0.8.27              ·  Optim: true   ·  Runs: 1000    ·  viaIR: false   ·     Block: 30,000,000 gas     │
·································|················|················|·················|································
|  Network: POLYGON              ·  L1: 26 gwei                    ·                 ·         0.16 eur/pol          │
·································|················|················|·················|················|···············
|  Contracts / Methods           ·  Min           ·  Max           ·  Avg            ·  # calls       ·  eur (avg)   │
·································|················|················|·················|················|···············
|  LiquidityToken                ·                                                                                   │
·································|················|················|·················|················|···············
|      approve                   ·             -  ·             -  ·         46,418  ·             1  ·           △  │
·································|················|················|·················|················|···············
|      burn                      ·             -  ·             -  ·         27,119  ·             2  ·           △  │
·································|················|················|·················|················|···············
|      mint                      ·             -  ·             -  ·         70,676  ·             3  ·           △  │
·································|················|················|·················|················|···············
|      transfer                  ·             -  ·             -  ·         46,822  ·             2  ·           △  │
·································|················|················|·················|················|···············
|  RHLoans                       ·                                                                                   │
·································|················|················|·················|················|···············
|      addBorrowerParameters     ·       271,286  ·       475,817  ·        333,052  ·            12  ·           △  │
·································|················|················|·················|················|···············
|      addLoanAdmin              ·             -  ·             -  ·         59,480  ·             2  ·           △  │
·································|················|················|·················|················|···············
|      addNewDocument            ·             -  ·             -  ·        124,729  ·             4  ·           △  │
·································|················|················|·················|················|···············
|      emergencyTokenTransfer    ·             -  ·             -  ·         63,237  ·             1  ·           △  │
·································|················|················|·················|················|···············
|      issueLoans                ·       123,317  ·       195,429  ·        157,883  ·            11  ·           △  │
·································|················|················|·················|················|···············
|      removeBorrowerParameters  ·             -  ·             -  ·         92,052  ·             2  ·           △  │
·································|················|················|·················|················|···············
|      removeLoanAdmin           ·             -  ·             -  ·         37,645  ·             2  ·           △  │
·································|················|················|·················|················|···············
|      setGlobalParameters       ·        80,872  ·       121,152  ·        101,012  ·             2  ·           △  │
·································|················|················|·················|················|···············
|      updateBorrowerParameters  ·       223,861  ·       279,961  ·        258,289  ·             4  ·           △  │
·································|················|················|·················|················|···············
|  RHLoansFactory                ·                                                                                   │
·································|················|················|·················|················|···············
|      addAdmin                  ·             -  ·             -  ·         56,402  ·             2  ·           △  │
·································|················|················|·················|················|···············
|      createLoan                ·             -  ·             -  ·        417,133  ·             2  ·           △  │
·································|················|················|·················|················|···············
|      emergencyTokenTransfer    ·             -  ·             -  ·         57,804  ·             1  ·           △  │
·································|················|················|·················|················|···············
|      removeAdmin               ·        32,607  ·        34,607  ·         33,607  ·             2  ·           △  │
·································|················|················|·················|················|···············
|      update                    ·             -  ·             -  ·         50,217  ·             2  ·           △  │
·································|················|················|·················|················|···············
|  RHLoansFactoryV2              ·                                                                                   │
·································|················|················|·················|················|···············
|      upgradeToAndCall          ·             -  ·             -  ·         37,534  ·             2  ·           △  │
·································|················|················|·················|················|···············
|  Deployments                                    ·                                  ·  % of limit    ·              │
·································|················|················|·················|················|···············
|  LiquidityToken                ·             -  ·             -  ·        737,930  ·         2.5 %  ·           △  │
·································|················|················|·················|················|···············
|  RHLoans                       ·             -  ·             -  ·      1,904,458  ·         6.3 %  ·        0.01  │
·································|················|················|·················|················|···············
|  RHLoansFactory                ·             -  ·             -  ·      1,866,583  ·         6.2 %  ·        0.01  │
·································|················|················|·················|················|···············
|  RHLoansFactoryV2              ·             -  ·             -  ·      1,769,065  ·         5.9 %  ·        0.01  │
·································|················|················|·················|················|···············
|  RHLoansV2                     ·             -  ·             -  ·      1,567,996  ·         5.2 %  ·        0.01  │
·································|················|················|·················|················|···············
|  Key                                                                                                               │
······················································································································
|  ◯  Execution gas for this method does not include intrinsic gas overhead                                          │
······················································································································
|  △  Cost was non-zero but below the precision setting for the currency display (see options)                       │
······················································································································
|  Toolchain:  hardhat                                                                                               │
······················································································································
```