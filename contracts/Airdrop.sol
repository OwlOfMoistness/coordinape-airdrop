pragma solidity 0.6.12;

import "@openzeppelin/contracts/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CoordinapeAirdrop {
	using MerkleProof for bytes32[];

	IERC20 public token;

	bytes32 public merkleRoot;
	mapping(uint256 => uint256) public claimedBitMap;
	uint256 expiryDate;
	address owner;

	event Claimed(uint256 index, address account, uint256 amount);

	constructor(address _token, bytes32 _root, uint256 _expiry, address _owner) public {
		token = IERC20(_token);
		merkleRoot = _root;
		expiryDate = _expiry;
		owner = _owner;
	}

	function fetchUnclaimed() external {
		require(block.timestamp > expiryDate, "!date");
		require(token.transfer(owner, token.balanceOf(address(this))), "Token transfer failed");
	}

	function isClaimed(uint256 _index) public view returns(bool) {
		uint256 wordIndex = _index / 256;
		uint256 bitIndex = _index % 256;
		uint256 word = claimedBitMap[wordIndex];
		uint256 bitMask = 1 << bitIndex;
		return word & bitMask == bitMask;
	}

	function _setClaimed(uint256 _index) internal {
		uint256 wordIndex = _index / 256;
		uint256 bitIndex = _index % 256;
		claimedBitMap[wordIndex] |= 1 << bitIndex;
	}

	function claim(uint256 _index, address _account, uint256 _amount, bytes32[] memory _proof) external {
		require(!isClaimed(_index), "CoordinapeAirdrop: Claimed already");
		bytes32 node = keccak256(abi.encodePacked(_account, _amount, _index));
		require(_proof.verify(merkleRoot, node), "CoordinapeAirdrop: Wrong proof");
		
		_setClaimed(_index);
		require(token.transfer(_account, _amount), "CoordinapeAirdrop: Token transfer failed");
		emit Claimed(_index, _account, _amount);
	}
}