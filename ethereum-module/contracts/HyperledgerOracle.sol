pragma solidity ^0.4.23;

import "./ERC721Escrow.sol";
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol';

contract HyperledgerOracle is Ownable {

    mapping(uint => tokenSubmission) public submissions;
    mapping(address => bool) public approvedEscrow;

    struct tokenSubmission {
        ERC721Token submittedToken;
        ERC721Escrow escrowContract;
        uint tokenId;
        bool deposited;
        bool withdrawAvailible;
    }

    uint numSubmissions;

    event TokenSubmitted(address indexed tokenAddress, uint indexed tokenId, uint indexed submissionId);
    event SubmissionAccepted(uint indexed submissionId);
    event WithdrawApproved(uint indexed submissionId);
    event ApprovedEscrowContract(address indexed approvedEscrowContract);

    modifier onlyApproved {
        require(approvedEscrow[msg.sender]);
        _;
    }

    function submitToken(ERC721Token _submittedToken, uint _tokenId)
        public onlyApproved returns (uint submissionId) {
        numSubmissions++;
        submissions[numSubmissions] = tokenSubmission(_submittedToken, ERC721Escrow(msg.sender), _tokenId, false, false);
        emit TokenSubmitted(_submittedToken, _tokenId, numSubmissions);
        return numSubmissions;
    }

    function acceptSubmission(uint _submissionId)
        public onlyOwner returns (bool success) {
        require(submissions[_submissionId].deposited == false);
        require(submissions[_submissionId].escrowContract.isLocked(
            submissions[_submissionId].submittedToken, 
            submissions[_submissionId].tokenId));
        submissions[_submissionId].deposited = true;
        emit SubmissionAccepted(_submissionId);
        return true;
    }
    
    function approveWithdraw(uint _submissionId)
        public onlyOwner returns (bool success) {
        require(submissions[_submissionId].deposited); 
        require(!submissions[_submissionId].withdrawAvailible);
        submissions[_submissionId].withdrawAvailible = true;
        emit WithdrawApproved(_submissionId);
        return true;
    }

    function setApprovedEscrow(address _escrowAddress)
        public onlyOwner returns (bool success) {
        require(approvedEscrow[_escrowAddress] == false);
        approvedEscrow[_escrowAddress] = true;
        emit ApprovedEscrowContract(_escrowAddress);
        return true;
    }

    function canWithdraw(uint _submissionId) 
        view public returns (bool)
    {
        return submissions[_submissionId].withdrawAvailible;
    }

}
