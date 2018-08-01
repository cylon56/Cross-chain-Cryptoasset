const Escrow = artifacts.require('ERC721Escrow');
const Oracle = artifacts.require('HyperledgerOracle');
const should = require('should');

contract('Escrow', function(accounts) {
    
    let escrow;
    let oracle;
    let token;
    let hyperledger = accounts[0];
    let tokenOwner = accounts[1];
    let randomUser = accounts[2];

    describe('check deployed contracts', function() {
    
        beforeEach(async () => {
            oracle = await Oracle.new({from: hyperledger});
            escrow = await Escrow.new(oracle.address);
        });

        it('Oracle should be deployed', async () => {
            assert.ok(oracle);
        });
         
        it('Escrow should be deployed', async () => {
            assert.ok(escrow);
        });
    
    
    });


});
