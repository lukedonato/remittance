pragma solidity 0.5.0;

import "./SafeMath.sol";
import "./Pausable.sol";

contract Remittance is Pausable {
    using SafeMath for uint;

    mapping (bytes32 => uint) balances;

    event LogDeposit(address owner, uint value);
    event LogWithdrawal(address withrawer, uint value);

    function depositFunds(bytes32 hashedCombo) payable external returns (bool) {
        /* 
            hashedCombo is the keccak256 hash of carol's password + bob's password + carol's address
            calculated offchain
        */ 
        require(hashedCombo > 0);
        balances[hashedCombo] = balances[hashedCombo].add(msg.value);

        emit LogDeposit(msg.sender, msg.value);
        return true;
    }

    function withdrawFunds(bytes32 carolsPassword, bytes32 bobsPassword) external returns (bool) {
        bytes32 hashedCombo = keccak256(abi.encodePacked(carolsPassword, bobsPassword, msg.sender));
        
        uint secretBalance = balances[hashedCombo];

        require(secretBalance > 0);

        balances[hashedCombo] = 0;
        msg.sender.transfer(secretBalance);
        
        emit LogWithdrawal(msg.sender, secretBalance);
        return true;
    }
}