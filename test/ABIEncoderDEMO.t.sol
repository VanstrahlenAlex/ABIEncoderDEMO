// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import "forge-std/Test.sol";
import "../src/ABIEncoderDEMO.sol";


/// @title ABIEncoderDEMOTest
/// @author Alex Van Strahalen
/// @notice This test contract shows different uses of abi.encodePacked in DeFi protocols
/// 
contract ABIEncoderDEMOTest is Test {
	ABIEncoderDEMO private demo;

	/// @dev Deploy a fresh contract before each test 
	function setUp() external {
		demo = new ABIEncoderDEMO();
	}

	function test_createPoolIdentifier_SameForBothTokenOrders() external view {
		address tokenA = address(0x1000);
		address tokenB = address(0x2000);
		uint24 fee = 3000;

		bytes32 idAB = demo.createPoolIdentifier(tokenA, tokenB, fee);
		bytes32 idBA = demo.createPoolIdentifier(tokenB, tokenA, fee);
		
		// The hash must be the same regardless of the order of the tokens
		assertEq(idAB, idBA, "Tokens are not correctly sorted");
	}
}