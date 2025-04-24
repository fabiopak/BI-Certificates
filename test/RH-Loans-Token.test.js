const { BigNumber, constants, ZeroAddress } = require('ethers');

const { expect } = require('chai');

require("@nomicfoundation/hardhat-chai-matchers");

const { addDays, timeConverter, timePasses } = require('./timeManagement')

const fromWei = (x) => ethers.formatEther(x);
const toWei = (x) => ethers.parseEther(x.toString());
// const fromWei6Dec = (x) => Number(x) / Math.pow(10, 6);
// const toWei6Dec = (x) => Number(x) * Math.pow(10, 6);
// const fromWei8Dec = (x) => Number(x) / Math.pow(10, 8);
// const toWei8Dec = (x) => Number(x) * Math.pow(10, 8);

const oneDay = 24 * 60 * 60;

// const provider = new ethers.providers.JsonRpcProvider();
const provider = ethers.provider;

let RHFactoryOwner, RHFactoryOwner2, RHLoanAdmin, RHLoanAdmin2, RHDistributionVault, Company1, Company2, Company3, Company4, Company5;
let LoanFactoryAddress, loansLogicAddress, loan1Address, liqTokenAddress;


describe('RH-Loans-Token', function () {

  it ('set wallets', async function () {
    [RHFactoryOwner, RHFactoryOwner2, RHLoanAdmin, RHLoanAdmin2, RHDistributionVault, Company1, Company2, Company3, Company4, Company5] = await ethers.getSigners()
  })

  it('deploy liquidity token smart contracts', async function () {
    LiqToken = await ethers.getContractFactory("LiquidityToken");
    liquidityToken = await LiqToken.deploy("Liquidity", "LIQ", RHFactoryOwner.address);
    await liquidityToken.waitForDeployment();
    liqTokenAddress = await liquidityToken.getAddress()
    console.log("Liquidity token deployed @:", liqTokenAddress);
  })

  it('deploy loans factory smart contracts', async function () {
    RHLoans = await ethers.getContractFactory("RHLoans");
    LoansLogic = await RHLoans.deploy();
    await LoansLogic.waitForDeployment();
    loansLogicAddress = await LoansLogic.getAddress()
    console.log("Loans Logic deployed @:", loansLogicAddress);

    RHLoansFactory = await ethers.getContractFactory("RHLoansFactory");
    this.LoanFactory = await upgrades.deployProxy(RHLoansFactory, [loansLogicAddress, RHFactoryOwner.address], {kind: 'uups'}); //RHLoansFactory.deploy();
    await this.LoanFactory.waitForDeployment();
    LoanFactoryAddress = await this.LoanFactory.getAddress()
    console.log("Loans Factory deployed @:", LoanFactoryAddress);
  })

  it('send eth to loan factory', async function () {
    const tx = {
      to: LoanFactoryAddress,
      value: toWei("1.0"), // Sends exactly 1.0 Ether
    };
    await expect(RHFactoryOwner.sendTransaction(tx)).to.be.revertedWithoutReason();
  })

  it('send liquidity token to loan factory', async function () {
    await liquidityToken.connect(RHFactoryOwner).mint(RHFactoryOwner.address, toWei(100000000))
    await liquidityToken.transfer(LoanFactoryAddress, toWei(100000000));
    factoryBal = await liquidityToken.balanceOf(LoanFactoryAddress);
    expect(factoryBal).to.be.equal(toWei(100000000));

    await this.LoanFactory.connect(RHFactoryOwner).emergencyTokenTransfer(liqTokenAddress, RHLoanAdmin.address, factoryBal);
    factoryBal = await liquidityToken.balanceOf(LoanFactoryAddress);
    expect(factoryBal).to.be.equal(0);

    await liquidityToken.connect(RHLoanAdmin).burn(toWei(100000000));
    loanAdminBal = await liquidityToken.balanceOf(RHLoanAdmin.address);
    expect(factoryBal).to.be.equal(0);
  })

  it('deploy first loan smart contract', async function () {
    await this.LoanFactory.connect(RHFactoryOwner).createLoan("0x496E766573746F723120536D61727420436F6E7472616374", RHLoanAdmin.address)
    expect(await this.LoanFactory.certificatesCounter()).to.be.equal(1);
    loan1Address = await this.LoanFactory.deployedLoans(0);
    console.log("Loan 1 deployed @:", loan1Address);

    this.Loan1Contract = await RHLoans.attach(loan1Address)
    expect(await this.Loan1Contract.owner()).to.be.equal(LoanFactoryAddress);
    expect(await this.Loan1Contract.loanData()).to.be.equal(("0x496E766573746F723120536D61727420436F6E7472616374").toLowerCase());
    expect(await this.Loan1Contract.loanFactoryAddress()).to.be.equal(LoanFactoryAddress);
  })

  it('send eth to loan contract', async function () {
    const tx = {
      to: loan1Address,
      value: toWei("1.0"), // Sends exactly 1.0 Ether
    };
    await expect(RHFactoryOwner.sendTransaction(tx)).to.be.revertedWithoutReason();
  })

  it('send liquidity token to loan factory', async function () {
    await liquidityToken.connect(RHFactoryOwner).mint(RHFactoryOwner.address, toWei(100000000))
    await liquidityToken.transfer(loan1Address, toWei(100000000));
    loan1Bal = await liquidityToken.balanceOf(loan1Address);
    expect(loan1Bal).to.be.equal(toWei(100000000));

    await this.Loan1Contract.connect(RHLoanAdmin).emergencyTokenTransfer(liqTokenAddress, RHLoanAdmin.address, loan1Bal);
    loan1Bal = await liquidityToken.balanceOf(LoanFactoryAddress);
    expect(loan1Bal).to.be.equal(0);

    await liquidityToken.connect(RHLoanAdmin).burn(toWei(100000000));
    loanAdminBal = await liquidityToken.balanceOf(RHLoanAdmin.address);
    expect(factoryBal).to.be.equal(0);
  })

  it('set parameters and borrowers for first loan smart contract', async function () {
    await this.Loan1Contract.connect(RHLoanAdmin).setGlobalParameters(toWei(100000000), /*toWei(0.025),*/ RHDistributionVault.address, liqTokenAddress)
    expect(await this.Loan1Contract.distributionVault()).to.be.equal(RHDistributionVault.address)
    expect(await this.Loan1Contract.distributionToken()).to.be.equal(liqTokenAddress)

    blockNum= await ethers.provider.getBlockNumber();
    timestampNow = (await ethers.provider.getBlock(blockNum)).timestamp;

    await this.Loan1Contract.connect(RHLoanAdmin).addBorrowerParameters(Company1.address, toWei(30000000), /*-1,*/ {dateTime: timestampNow, labels:[0,3,5,17], values:[20, 10, 50, 100]})
    expect(await this.Loan1Contract.isBorrower(Company1.address)).to.be.true;
    expect(await this.Loan1Contract.loansCaps(Company1.address)).to.be.equal(toWei(30000000));
    // expect(await this.Loan1Contract.loansInterests(Company1.address)).to.be.equal(toWei(0.025));
    res = await this.Loan1Contract.getKpiStatus(Company1.address);
    console.log(res[0], res[1], res[2]);
    expect(await this.Loan1Contract.loansIssued(Company1.address)).to.be.equal(0);

    await this.Loan1Contract.connect(RHLoanAdmin).addBorrowerParameters(Company2.address, toWei(25000000), /*toWei(0.0275),*/ {dateTime: timestampNow, labels:[0,4,17], values:[20, 10, 100]})
    expect(await this.Loan1Contract.isBorrower(Company2.address)).to.be.true;
    expect(await this.Loan1Contract.loansCaps(Company2.address)).to.be.equal(toWei(25000000));
    // expect(await this.Loan1Contract.loansInterests(Company2.address)).to.be.equal(toWei(0.0275));
    res = await this.Loan1Contract.getKpiStatus(Company2.address);
    console.log(res[0], res[1], res[2]);
    expect(await this.Loan1Contract.loansIssued(Company2.address)).to.be.equal(0);

    await this.Loan1Contract.connect(RHLoanAdmin).addBorrowerParameters(Company3.address, toWei(25000000), /*toWei(0.03),*/ {dateTime: timestampNow, labels:[0,4, 17, 8], values:[20, 10, 100, 8]})
    expect(await this.Loan1Contract.isBorrower(Company3.address)).to.be.true;
    expect(await this.Loan1Contract.loansCaps(Company3.address)).to.be.equal(toWei(25000000));
    // expect(await this.Loan1Contract.loansInterests(Company3.address)).to.be.equal(toWei(0.03));
    res = await this.Loan1Contract.getKpiStatus(Company3.address);
    console.log(res[0], res[1], res[2]);
    expect(await this.Loan1Contract.loansIssued(Company3.address)).to.be.equal(0);

    await this.Loan1Contract.connect(RHLoanAdmin).addBorrowerParameters(Company4.address, toWei(40000000), /*toWei(0.0325),*/ {dateTime: timestampNow, labels:[0,4,17], values:[20, 10, 100]})
    expect(await this.Loan1Contract.isBorrower(Company4.address)).to.be.true;
    expect(await this.Loan1Contract.loansCaps(Company4.address)).to.be.equal(toWei(20000000));
    // expect(await this.Loan1Contract.loansInterests(Company4.address)).to.be.equal(toWei(0.0325));
    res = await this.Loan1Contract.getKpiStatus(Company4.address);
    console.log(res[0], res[1], res[2]);
    expect(await this.Loan1Contract.loansIssued(Company4.address)).to.be.equal(0);

    await expect(this.Loan1Contract.connect(RHLoanAdmin).addBorrowerParameters(Company4.address, toWei(20000000), /*toWei(0.0325),*/ {dateTime: timestampNow, labels:[0,4,17], values:[20, 10, 100]})).to.be.revertedWithCustomError(this.Loan1Contract, "existingBorrower");

    // max total cap reached, so loansCaps for other borrowers will be 0 and it reverts, not allowing any new borrower
    await expect(this.Loan1Contract.connect(RHLoanAdmin).addBorrowerParameters(Company5.address, toWei(20000000), /*toWei(0.0325),*/ {dateTime: timestampNow, labels:[0,4,17], values:[20, 10, 100]})).to.be.revertedWithCustomError(this.Loan1Contract, "maxTotalCapReached");
    expect(await this.Loan1Contract.isBorrower(Company5.address)).to.be.false;
    expect(await this.Loan1Contract.borrowersCounter()).to.be.equal(4);
  })

  timePasses(7 * oneDay);

  it('update borrower', async function () {
    blockNum= await ethers.provider.getBlockNumber();
    timestampNow = (await ethers.provider.getBlock(blockNum)).timestamp;

    await this.Loan1Contract.connect(RHLoanAdmin).updateBorrowerParameters(Company4.address, toWei(15000000), /*toWei(0.0325),*/ 0, {dateTime: timestampNow, labels:[0,4,17,22,37,41,89], values:[20, 10, 100, 20, 10, 100, 20]})
    await this.Loan1Contract.connect(RHLoanAdmin).updateBorrowerParameters(Company3.address, toWei(30000000), /*toWei(0.03),*/ 0, {dateTime: timestampNow, labels:[0,4,17,22,37,41,89], values:[20, 10, 100, 20, 10, 100, 20]})
    // console.log(await this.Loan1Contract.loansCaps(Company3.address))
    // max total cap reached, so loansCaps for other borrowers will be 0 and it reverts, not allowing any new borrower
    await expect(this.Loan1Contract.connect(RHLoanAdmin).addBorrowerParameters(Company5.address, toWei(20000000), /*toWei(0.0325),*/ {dateTime: timestampNow, labels:[2,8,12,24,27,31,101], values:[20, 10, 100, 20, 10, 100, 20]})).to.be.revertedWithCustomError(this.Loan1Contract, "maxTotalCapReached");
    expect(await this.Loan1Contract.isBorrower(Company5.address)).to.be.false;
    expect(await this.Loan1Contract.borrowersCounter()).to.be.equal(4);
  })

  it('delete and add borrower', async function () {
    await this.Loan1Contract.connect(RHLoanAdmin).removeBorrowerParameters(Company2.address);
    expect(await this.Loan1Contract.isBorrower(Company2.address)).to.be.false;
    expect(await this.Loan1Contract.borrowersCounter()).to.be.equal(3);
    expect(await this.Loan1Contract.residualTotalCap()).to.be.equal(toWei(25000000));

    await this.Loan1Contract.connect(RHLoanAdmin).addBorrowerParameters(Company5.address, toWei(20000000), /*toWei(0.0325),*/ {dateTime: timestampNow, labels:[2,8,12,24,27,31,101], values:[20, 10, 100, 20, 10, 100, 20]})
    expect(await this.Loan1Contract.isBorrower(Company5.address)).to.be.true;
    expect(await this.Loan1Contract.borrowersCounter()).to.be.equal(4);
    expect(await this.Loan1Contract.residualTotalCap()).to.be.equal(toWei(5000000));
  })

  it('mint tokens to the vault and approve loan contract to spend money', async function () {
    await liquidityToken.connect(RHFactoryOwner).mint(RHDistributionVault.address, toWei(100000000))
    expect(await liquidityToken.balanceOf(RHDistributionVault.address)).to.be.equal(toWei(100000000));
    await liquidityToken.connect(RHDistributionVault).approve(loan1Address, toWei(100000000));
    console.log("Distribution vault token balance:", fromWei(await liquidityToken.balanceOf(RHDistributionVault.address)))
  })

  timePasses(30 * oneDay);

  it('send money to borrowers', async function () {
    blockNum= await ethers.provider.getBlockNumber();
    timestampNow = (await ethers.provider.getBlock(blockNum)).timestamp;

    expect(await this.Loan1Contract.issuedTotalLoansAmount()).to.be.equal(toWei(0));
    expect(await liquidityToken.allowance(RHDistributionVault.address, loan1Address)).to.be.equal(toWei(100000000))

    await this.Loan1Contract.connect(RHLoanAdmin).issueLoans(Company1.address, toWei(40000000), /*toWei(0.0275),*/ {dateTime: timestampNow, labels:[0,3,5,17], values:[25, 15, 55, 105]})
    expect(await this.Loan1Contract.loansIssued(Company1.address)).to.be.equal(toWei(30000000));
    expect(await this.Loan1Contract.issuedTotalLoansAmount()).to.be.equal(toWei(30000000));
    console.log("Company1 token balance:", fromWei(await liquidityToken.balanceOf(Company1.address)))

    await this.Loan1Contract.connect(RHLoanAdmin).issueLoans(Company5.address, toWei(15000000), /*toWei(0.0275),*/ {dateTime: timestampNow, labels:[2,8,12,24,27,31,101], values:[20, 10, 100, 20, 10, 100, 20]})
    expect(await this.Loan1Contract.loansIssued(Company5.address)).to.be.equal(toWei(15000000));
    expect(await this.Loan1Contract.issuedTotalLoansAmount()).to.be.equal(toWei(45000000));
    await this.Loan1Contract.connect(RHLoanAdmin).issueLoans(Company5.address, toWei(40000000), /*toWei(0.0275),*/ {dateTime: timestampNow, labels:[2,8,12,24,27,31,101], values:[20, 10, 100, 20, 10, 100, 20]})
    expect(await this.Loan1Contract.loansIssued(Company5.address)).to.be.equal(toWei(20000000));
    expect(await this.Loan1Contract.issuedTotalLoansAmount()).to.be.equal(toWei(50000000));
    console.log("Company5 token balance:", fromWei(await liquidityToken.balanceOf(Company5.address)))
    
    await this.Loan1Contract.connect(RHLoanAdmin).issueLoans(Company3.address, toWei(35000000), /*toWei(0.03),*/ {dateTime: timestampNow, labels:[0,4,17], values:[26, 16, 106]})
    expect(await this.Loan1Contract.loansIssued(Company3.address)).to.be.equal(toWei(30000000));
    expect(await this.Loan1Contract.issuedTotalLoansAmount()).to.be.equal(toWei(80000000));
    console.log("Company3 token balance:", fromWei(await liquidityToken.balanceOf(Company3.address)))

    await this.Loan1Contract.connect(RHLoanAdmin).issueLoans(Company4.address, toWei(35000000), /*toWei(0.03),*/ {dateTime: timestampNow, labels:[0,4,17], values:[27, 17, 107]})
    expect(await this.Loan1Contract.loansIssued(Company4.address)).to.be.equal(toWei(15000000));
    expect(await this.Loan1Contract.issuedTotalLoansAmount()).to.be.equal(toWei(95000000));
    console.log("Company4 token balance:", fromWei(await liquidityToken.balanceOf(Company4.address)))

    await expect(this.Loan1Contract.connect(RHLoanAdmin).issueLoans(Company2.address, toWei(35000000), /*toWei(0.03),*/ {dateTime: timestampNow, labels:[0,4, 17, 8], values:[20, 10, 100, 8]})).to.be.revertedWithCustomError(this.Loan1Contract, "nonExistingBorrower")
    // console.log(await this.Loan1Contract.loansCaps(Company2.address))
    // console.log(await this.Loan1Contract.residualTotalCap())
    await this.Loan1Contract.connect(RHLoanAdmin).addBorrowerParameters(Company2.address, toWei(10000000), /*toWei(0.0325),*/ {dateTime: timestampNow, labels:[0,4, 17, 8], values:[20, 10, 100, 8]})
    expect(await this.Loan1Contract.loansCaps(Company2.address)).to.be.equal(toWei(5000000));

    await this.Loan1Contract.connect(RHLoanAdmin).issueLoans(Company2.address, toWei(15000000), /*toWei(0.03),*/ {dateTime: timestampNow, labels:[0,4, 17, 8], values:[20, 10, 100, 8]})
    expect(await this.Loan1Contract.loansIssued(Company2.address)).to.be.equal(toWei(5000000));
    expect(await this.Loan1Contract.issuedTotalLoansAmount()).to.be.equal(toWei(100000000));
    console.log("Company2 token balance:", fromWei(await liquidityToken.balanceOf(Company2.address)))
    console.log("Distribution vault token balance:", fromWei(await liquidityToken.balanceOf(RHDistributionVault.address)))
  })

  it('loan admin adds a document hash to loan contract', async function () {
    await expect(this.Loan1Contract.connect(RHLoanAdmin).addNewDocument("https://realhouse.io", "0x17eeb81dbac9390aad6478cc738f130ca89255db7d2d65c869c6cb3f6f1a2fa9")).
            to.emit(this.Loan1Contract, "DocHashAdded").withArgs(1, "https://realhouse.io", "0x17eeb81dbac9390aad6478cc738f130ca89255db7d2d65c869c6cb3f6f1a2fa9");
    res = await this.Loan1Contract.documents(0)
    expect(res[0]).to.be.equal("https://realhouse.io")
    expect(res[1]).to.be.equal("0x17eeb81dbac9390aad6478cc738f130ca89255db7d2d65c869c6cb3f6f1a2fa9")
    expect(await this.Loan1Contract.docsCounter()).to.be.equal(1)
  });



  it('add and remove factory admins', async function () {
    await this.LoanFactory.connect(RHFactoryOwner).addAdmin(RHFactoryOwner2.address);
    expect(await this.LoanFactory.isLoansFactoryAdmin(RHFactoryOwner2.address)).to.be.true;
    expect(await this.LoanFactory.loansFactoryAdminCounter()).to.be.equal(2);
    await this.LoanFactory.connect(RHFactoryOwner).removeAdmin(RHFactoryOwner2.address);
    expect(await this.LoanFactory.isLoansFactoryAdmin(RHFactoryOwner2.address)).to.be.false;
    expect(await this.LoanFactory.loansFactoryAdminCounter()).to.be.equal(1);
    await expect(this.LoanFactory.connect(RHFactoryOwner).removeAdmin(RHFactoryOwner.address)).to.be.revertedWithCustomError(this.LoanFactory, "cantRemoveLastAdmin");
  })

  it('add and remove loan admins', async function () {
    await this.Loan1Contract.connect(RHLoanAdmin).addLoanAdmin(RHLoanAdmin2.address);
    expect(await this.Loan1Contract.isLoanAdmin(RHLoanAdmin2.address)).to.be.true;
    expect(await this.Loan1Contract.loanAdminsCounter()).to.be.equal(2);
    await this.Loan1Contract.connect(RHLoanAdmin).removeLoanAdmin(RHLoanAdmin2.address);
    expect(await this.Loan1Contract.isLoanAdmin(RHLoanAdmin2.address)).to.be.false;
    expect(await this.Loan1Contract.loanAdminsCounter()).to.be.equal(1);
    await expect(this.Loan1Contract.connect(RHLoanAdmin).removeLoanAdmin(RHLoanAdmin.address)).to.be.revertedWithCustomError(this.Loan1Contract, "cantRemoveLastAdmin");
  })

  it('update loans smart contracts', async function () {
    // expect(await this.LoanFactory.getInfo()).to.be.revertedWithoutReason();
    const LoansV2 = await hre.ethers.getContractFactory("RHLoansV2");
    // console.log("Loan proxy address", loan1Address)
    // console.log("Loan implementation address", await upgrades.erc1967.getImplementationAddress(loan1Address))
    // console.log("Loan implementation address", await upgrades.erc1967.getAdminAddress(loan1Address))
    // upgradedLoan = await upgrades.upgradeProxy(loan1Address, LoansV2);  // {kind: 'uups', /*unsafeAllow: ['constructor'],*/ call: {fn: 'initialize', args: []} });
    // loan1AddressV2 = await upgradedLoan.getAddress()
    // console.log("Loan proxy address", loan1AddressV2)
    // console.log("New Loan implementation address", await upgrades.erc1967.getImplementationAddress(loan1AddressV2))
    // console.log("Loan implementation address", await upgrades.erc1967.getAdminAddress(loan1AddressV2))
    // expect(loan1Address).to.be.equal(loan1AddressV2)

    LoansLogicV2 = await LoansV2.deploy();
    loansLogicV2Address = await LoansLogicV2.getAddress()
    console.log("Loans Logic V2 @:", loansLogicV2Address);
    loansLogicImplementation = await this.LoanFactory.loansLogic();
    console.log("Loans Logic V1 @:", loansLogicImplementation);
    loansBeaconAddress = await this.LoanFactory.loansBeacon();
    console.log("Loans Factory beacon @:", loansBeaconAddress);
    await this.LoanFactory.update(loansLogicV2Address)
    loansLogicImplementation = await this.LoanFactory.loansLogic();
    console.log("New Loans Logic V2 @:", loansLogicImplementation);
    expect(loansLogicImplementation).to.be.equal(loansLogicV2Address);

    const LoanFactoryV2 = await hre.ethers.getContractFactory("RHLoansFactoryV2");
    this.LoanFactoryV2 = await upgrades.upgradeProxy(LoanFactoryAddress, LoanFactoryV2); //RHLoansFactory.deploy();
    await this.LoanFactoryV2.waitForDeployment();
    LoanFactoryAddressV2 = await this.LoanFactoryV2.getAddress()
    console.log("Loans Factory V2 deployed @:", LoanFactoryAddressV2);
    expect(LoanFactoryAddressV2).to.be.equal(LoanFactoryAddress);
    loansBeaconAddressV2 = await this.LoanFactoryV2.loansBeacon();
    console.log("Loans Factory V2 beacon @:", loansBeaconAddressV2)
    expect(loansBeaconAddressV2).to.be.equal(loansBeaconAddress);
    loansLogicImplementationV2 = await this.LoanFactoryV2.loansLogic()
    console.log("Loans Factory V2 logic @:", loansLogicImplementationV2)
    expect(loansLogicImplementation).to.be.equal(loansLogicImplementationV2);
    
    console.log("Loans Factory V2 info:", await this.LoanFactoryV2.getInfo())
  })

});
