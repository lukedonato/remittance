pragma solidity 0.5.0;

import "./SafeMath.sol";
import "./Pausable.sol";

contract Remittance is Pausable {
    using SafeMath for uint;

    struct RemittanceStruct {
        uint balance;
        address recipient;
    }

    mapping (bytes32 => RemittanceStruct) remittances;

    event LogDeposit(address owner, uint value, bytes32 hashedCombo);
    event LogWithdrawal(address withrawer, uint value);

    function depositFunds(bytes32 hashedCombo, address withdrawerAddress) payable external returns (bool) {
        require(hashedCombo > 0);
        RemittanceStruct storage r = remittances[hashedCombo];
        require(r.recipient == address(0), "Sorry. Taken.");
        r.recipient = withdrawerAddress;
        r.balance = r.balance.add(msg.value);

        emit LogDeposit(msg.sender, msg.value, hashedCombo);
        return true;
    }

    // offchain
    function generateHashedCombo(
        bytes32 bobsPassword,
        address withdrawerAddress
    ) public pure returns (bytes32 hashedCombo) {
         hashedCombo = keccak256(abi.encodePacked(bobsPassword, withdrawerAddress, address(this)));
    }

    function withdrawFunds(bytes32 bobsPassword) external returns (bool) {
        bytes32 hashedCombo = keccak256(abi.encodePacked(bobsPassword, msg.sender, address(this)));
        RemittanceStruct storage r = remittances[hashedCombo];
        
        require(r.recipient == msg.sender, "This is not for you.");
        uint secretBalance = r.balance;
        require(secretBalance > 0);
        r.balance = 0;

        msg.sender.transfer(secretBalance);
        emit LogWithdrawal(msg.sender, secretBalance);
        return true;
    }
}