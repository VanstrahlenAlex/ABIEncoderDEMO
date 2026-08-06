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

	function test_createPoolIdentifier_DifferentFeeDifferentId() external view { 
		address tokenA = address(0x1000);
		address tokenB = address(0x2000);
		uint24 fee0 = 3000;
		uint24 fee1 = 500; 

		bytes32 idLow = demo.createPoolIdentifier(tokenA, tokenB, fee0);
		bytes32 idHigh = demo.createPoolIdentifier(tokenB, tokenA, fee1);

		assertTrue(idLow != idHigh, "different fees must yield different ids");
	}

	function test_encodeTradingPosition_ReturnsExpectedDataAndHash() external {
		address user = address(0x1234);
		address tokenIn = address(0xA1);
		address tokenOut = address(0xB2);
		uint256 amountIn = 1 ether; 
		uint256 minAmountOut = 2 ether; 

		//Freeze block timestamp to a know value 
		uint256 fixedTs = 1_700_000_000;
		vm.warp(fixedTs);

		(bytes32 positionId, bytes memory encodedData) = demo.encodeTradingPosition(user, tokenIn, tokenOut, amountIn, minAmountOut);

		bytes memory expected = abi.encodePacked(user, tokenIn, tokenOut, amountIn, minAmountOut, fixedTs);

		assertEq(encodedData, expected, "encoded trading position mismatch");
		assertEq(positionId, keccak256(expected), "position id must be keccak of encodedData"); 
	}
}