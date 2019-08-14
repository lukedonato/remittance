pragma solidity ^0.5.0;

import "./Roles.sol";

contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);
    event KillerAdded(address indexed account);
    event KillerRemoved(address indexed account);

    Roles.Role private _pausers;
    Roles.Role private _killers;

    constructor () internal {
        _addPauser(msg.sender);
        _addKiller(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender), "PauserRole: caller does not have the Pauser role");
        _;
    }

    modifier onlyKiller() {
        require(isKiller(msg.sender), "KillerRole: caller does not have the Killer role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function isKiller(address account) public view returns (bool) {
        return _killers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function addKiller(address account) public onlyKiller {
        _addKiller(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function renounceKiller() public {
        _removeKiller(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _addKiller(address account) internal {
        _killers.add(account);
        emit KillerAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }

    function _removeKiller(address account) internal {
        _killers.remove(account);
        emit KillerRemoved(account);
    }
}