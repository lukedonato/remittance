pragma solidity 0.5.0;

import "./SafeMath.sol";
import "./Pausable.sol";

contract Remittance is Pausable {
    using SafeMath for uint;

    uint public constant maxExpiration = 7 days;
    
    struct RemittanceStruct {
        uint balance;
        address originalSender;
        uint expiration;
    }

    mapping (bytes32 => RemittanceStruct) public remittances;

    event LogDeposit(address indexed owner, uint value, bytes32 indexed hashedCombo);
    event LogWithdrawal(address indexed withrawer, uint value, bytes32 indexed hashedCombo);
    event LogRefunded(address indexed originalSender, uint refundAmount, bytes32 indexed hashedCombo);

    function depositFunds(bytes32 hashedCombo, uint expiration) payable external returns (bool) {
        require(hashedCombo != 0);
        require(msg.value > 0);
        require(expiration <= maxExpiration);
        
        RemittanceStruct storage r = remittances[hashedCombo];
        require(r.originalSender == address(0), "hashedCombo already used");

        r.balance = msg.value;
        r.originalSender = msg.sender;
        r.expiration = now.add(expiration);

        emit LogDeposit(msg.sender, msg.value, hashedCombo);
        return true;
    }

    // offchain
    function generateHashedCombo(
        bytes32 bobsPassword,
        address withdrawerAddress
    ) public pure returns (bytes32 hashedCombo) {
        require(withdrawerAddress != address(0), 'must supply valid withdrawerAddress');
        hashedCombo = keccak256(abi.encodePacked(bobsPassword, withdrawerAddress, address(this)));
    }

    function withdrawFunds(bytes32 bobsPassword) external returns (bool) {
        bytes32 hashedCombo = generateHashedCombo(bobsPassword, msg.sender);
        RemittanceStruct storage r = remittances[hashedCombo];

        uint secretBalance = r.balance;
        require(secretBalance > 0);
        r.balance = 0;
        r.expiration = 0;

        emit LogWithdrawal(msg.sender, secretBalance, hashedCombo);
        msg.sender.transfer(secretBalance);
        
        return true;
    }

    function refundFunds(bytes32 hashedCombo) external  returns (bool) {
        require(msg.sender == remittances[hashedCombo].originalSender);
        require(remittances[hashedCombo].expiration <= now);

        uint refundAmount = remittances[hashedCombo].balance;
        require(refundAmount > 0);

        remittances[hashedCombo].balance = 0;
        remittances[hashedCombo].expiration = 0;

        emit LogRefunded(msg.sender, refundAmount, hashedCombo);
        msg.sender.transfer(refundAmount);

        return true;
    }
}