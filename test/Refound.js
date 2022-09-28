const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-network-helpers");
  //const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");
  
  describe("UserProfile", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deployContract() {
    
      // Contracts are deployed using the first signer/account by default
      //var supply = 10000 * 10^18;

      const [owner] = await ethers.getSigners();

      const FakeUSDC = await ethers.getContractFactory("fakeUSDC");
      const fakeUSDC = await FakeUSDC.deploy(1000000000);
    
      const Refound = await ethers.getContractFactory("Refound");
      const refound = await Refound.deploy();
    
      await fakeUSDC.deployed();
      const RefoundUSD = await ethers.getContractFactory("RefoundUSD");
      const refoundUSD = await RefoundUSD.deploy(fakeUSDC.address);
    
      await refoundUSD.deployed();
      const FundingPool = await ethers.getContractFactory("FundingPool");
      const fundingPool = await FundingPool.deploy(refoundUSD.address, 10000);
    
      const RefoundPost = await ethers.getContractFactory("RefoundPost");
      const refoundPost = await RefoundPost.deploy(refound.address, refoundUSD.address);
      
      await fundingPool.deployed();
      await refound.deployed();
      await refound.changeAddresses(refoundPost.address);
      await refoundPost.deployed();
      await refoundPost.updatePrice(0, 100);
      await refoundPost.updatePrice(1, 250);
      await refoundPost.updatePrice(2, 1000);

      console.log('contract deployed')
      //console.log('addresses: ', owner.address, ', ', otherAccount.address)
      return {refound, refoundPost, fakeUSDC, refoundUSD};
    }
  
    describe("DeployContract", function () {
      it("test contract deployment", async function () {
        const {refound, refoundPost} = await loadFixture(deployContract);

        expect(await refound.name()).to.equal("RefoundUser");
        expect(await refound.symbol()).to.equal("FOUNDU");
        expect(await refoundPost.name()).to.equal("RefoundPost");
        expect(await refoundPost.symbol()).to.equal("FOUNDP");
      });
    });
    describe("MintProfile", function () {
      it("test profile creation", async function () {
        const {refound} = await loadFixture(deployContract);

        await refound.makeRefoundProfile("profileName", "{(ツ)}");//tokenURI
        expect(await refound.profiles()).to.equal(1);
        expect(await refound.tokenURI(0)).to.equal('{"Handle": profileName, "ProfileData": {(ツ)}}');
      });
    });
    describe("MintPost", function () {
      it("test profile creation", async function () {
        const {refound, refoundPost} = await loadFixture(deployContract);

        await refound.makeRefoundProfile("profileName", "{(ツ)}");//tokenURI
        await refound.makeRefoundPost(0, "{(ツ)}");//tokenURI
        expect(await refoundPost.posts()).to.equal(1);
        expect(await refoundPost.tokenURI(0)).to.equal('{"posterID": 0, "postData": {(ツ)}}');
      });
    });
    describe("DepositAndWithdrawal", function () {
      it("test deposits and withdrawals", async function () {
        const {refound, refoundPost, fakeUSDC, refoundUSD} = await loadFixture(deployContract);
        const [owner, otherAccount] = await ethers.getSigners();
        await fakeUSDC.approve(refoundUSD.address, 1000000000);
        await refoundUSD.deposit(1000000000);
        expect(await refoundUSD.balanceOf(owner.address)).to.equal(1000000000);
        await refoundUSD.withdrawal(100000000);
        await refoundUSD.transfer(otherAccount.address, 100000000);
        expect(await refoundUSD.balanceOf(owner.address)).to.equal(800000000);
        expect(await fakeUSDC.balanceOf(owner.address)).to.equal(100000000);
        
        
        await refound.makeRefoundProfile("profileName", "{(ツ)}");
        await refound.makeRefoundPost(0, "{(ツ)}");
        await refoundUSD.connect(otherAccount).approve(refoundPost.address, 1000000000);
        await refoundPost.connect(otherAccount).purchaseLicense(0, 1);

        expect(await refoundUSD.balanceOf(owner.address)).to.equal(800000000 + 250);
        expect(await refoundUSD.balanceOf(otherAccount.address)).to.equal(100000000 - 250);

      });
    });
    /*
    describe("purchaseLicense", function () {
      it("test license purchase", async function () {
        const {refound, refoundPost, owner} = await loadFixture(deployContract);

        await refound.makeRefoundProfile("profileName", "{(ツ)}");//tokenURI
        await refound.makeRefoundPost(0, "{(ツ)}");//tokenURI
        await refound.makeRefoundPost(0, "{(-ツ-)}");//tokenURI
        await refoundPost.purchaseLicense(1, 3);
        var license = await refoundPost.getLicensesByAddress(owner.address);
        expect(license[0][0]).to.equal(1);
        expect(license[0][1]).to.equal(3);
      });
    });
    */
  });
  