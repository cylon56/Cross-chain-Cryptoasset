pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/token/ERC721/ERC721Holder.sol";
import "zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "./HyperledgerOracle.sol";

contract ERC721Escrow is ERC721Holder {

    HyperledgerOracle public oracleContract;
    mapping(address => TokenDeposits) deposits;

    struct TokenDeposits {
        bool exists;
        mapping(uint => address) owner;
        mapping(uint => bool) isWithdrawn;
        mapping(uint => uint) submissionId;
    }

    event TokenDeposited(address indexed tokenAddress, uint indexed tokenId, uint submissionId);
    event TokenWithdrawn(address indexed tokenAddress, uint indexed tokenId, address reciever);

    constructor (address _oracleAddress) public {
        oracleContract = HyperledgerOracle(_oracleAddress);
    }

    function depositToken(address _tokenAddress, uint _tokenId)
        public returns (uint submissionId) {
        ERC721Token tokenContract = ERC721Token(_tokenAddress);
        tokenContract.safeTransferFrom(msg.sender, this, _tokenId);
        submissionId = oracleContract.submitToken(tokenContract, _tokenId);
        emit TokenDeposited(_tokenAddress, _tokenId, submissionId);
        if(!deposits[tokenContract].exists){
            deposits[tokenContract] = TokenDeposits(true);
        }
        deposits[tokenContract].owner[_tokenId] = msg.sender;
        deposits[tokenContract].isWithdrawn[_tokenId] = false;
        deposits[tokenContract].submissionId[_tokenId] = submissionId;
        return submissionId;
    } 

    function isLocked(ERC721Token _lockedToken, uint _tokenId) 
        public view returns (bool locked) {
        if(deposits[_lockedToken].exists) {
            return deposits[_lockedToken].isWithdrawn[_tokenId];
        }
        else return false;
    }

    function withdrawToken(ERC721Token _tokenContract, uint _tokenId)
        public returns (bool success) {
        require(msg.sender == deposits[_tokenContract].owner[_tokenId]);
        require(oracleContract.canWithdraw(deposits[_tokenContract].submissionId[_tokenId]));
        _tokenContract.safeTransferFrom(this, msg.sender, _tokenId);
        emit TokenWithdrawn(_tokenContract, _tokenId, msg.sender);
        return true;
    }

}
