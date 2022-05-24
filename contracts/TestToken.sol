pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20('Test', 'TEST') {
	constructor(uint256 _amount) public {
		_mint(msg.sender, _amount);
	}
}