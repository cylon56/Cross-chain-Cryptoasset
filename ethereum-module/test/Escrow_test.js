const Escrow = artifacts.require('ERC721Escrow');
const Oracle = artifacts.require('HyperledgerOracle');
const Asset = artifacts.require('Cryptoasset');
const should = require('should');

contract('Escrow', function(accounts) {
    
    let escrow;
    let oracle;
    let token;
    let tokenId;
    let hyperledger = accounts[0];
    let tokenOwner = accounts[1];
    let randomUser = accounts[2];

    describe('check deployed contracts', function() {
    
        beforeEach(async () => {
            oracle = await Oracle.new({from: hyperledger});
            escrow = await Escrow.new(oracle.address);
            asset = await Asset.new({from : tokenOwner});
        });

        it('Oracle should be deployed', async () => {
            assert.ok(oracle);
            let owner = await oracle.owner();
            assert.equal(hyperledger, owner, "hyperledger account doesn't own Oracle contract");
        });
         
        it('Escrow should be deployed', async () => {
            assert.ok(escrow);
        });

        it('Escrow should reference Oracle contract', async () => {
            let address = await escrow.oracleContract();
            assert.equal(address, oracle.address, "Escrow does not reference Oracle contract");
        });  
  
        it('Cryptoasset should be deployed', async () => {
            assert.ok(asset);
            let owner = await asset.owner();
            assert.equal(tokenOwner, owner, "tokenOwner doesn't own Cryptoasset contract");
        });
    });


    describe('Deposit NFT Token', function() {
    
        beforeEach(async () => {
            oracle = await Oracle.new({from: hyperledger});
            escrow = await Escrow.new(oracle.address);
            asset = await Asset.new({from : tokenOwner});
            await asset.mintTo(tokenOwner, "test", {from: tokenOwner});
            await oracle.setApprovedEscrow(escrow.address, {from: hyperledger});
        });
           
        it('tokenOwner should have 1 cryptoasset', async () => {
            let owner = await asset.ownerOf(1);
            assert.equal(tokenOwner, owner, "tokenOwner does not own the cryptoasset with Id 1");
        });  

        it('Escrow contract should be approved', async () => {
            let approved = await oracle.approvedEscrow(escrow.address);
            assert(approved, "Escrow contract is not approved by Oracle");
        });

        it('Deposit should be submitted and approved', async () => {
            await asset.transferFrom(tokenOwner, escrow.address, 1, {from: tokenOwner});
            let owner = await asset.ownerOf(1);
            assert.equal(owner, escrow.address, "escrow contract doesn't own NFT");
            let submitId = await escrow.depositToken.call(asset.address, 1, {from: tokenOwner});
            assert.equal(submitId, 1, "depositToken function does not return 1");
            await escrow.depositToken(asset.address, 1, {from: tokenOwner});

            let approval = await oracle.acceptSubmission(1, {from: hyperledger});
            assert(approval, 'hyperledger did not approve acceptSubmission');


        });

        it('Oracle should approve deposit submission', async () => {

        });

    });
});
