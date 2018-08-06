pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";

contract Cryptoasset is ERC721Token, Ownable {

    constructor() ERC721Token("Cryptoasset", "CRY") public { }

    function mintTo(address _to, string _tokenURI) 
        public onlyOwner {
        uint256 newTokenId = getNextTokenId();
        _mint(_to, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
    } 

    function getNextTokenId ()
        private view returns (uint256) {
        return totalSupply().add(1);
    }

}
