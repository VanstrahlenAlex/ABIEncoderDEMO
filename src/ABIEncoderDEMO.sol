// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;


/**
 * @title ABIEncoderDEMO
 * @author Alexander Van strahlen
 * @notice This smart contract shows different uses of abi.encodePacked in DeFi protocols 
 */

contract ABIEncoderDEMO {

	//Events to show the codification 
	event DataEncoded(bytes32 indexed hash, bytes encodedData);
	event PoolIdentifierCreated(bytes32 indexed poolId, address token, uint256 rate);
	event UserPositionEncoded(bytes32 indexed positionId, address user, uint256 amount);


	/**
	 * 
	 * @dev This function encodes the pool parameters
	 * @param tokenA first pool token
	 * @param tokenB second pool token
	 * @param fee pool fee
	 * @return poolId identifier (unique for this pool)
	 */

	function createPoolIdentifier(address tokenA, address tokenB, uint24 fee) external pure returns(bytes32 poolId){ 
		// We order the tokens 
		(address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
		
		//User of ABI.ENCODEPACKED: Create unique pool identifier
		poolId = keccak256(abi.encodePacked(token0, token1, fee));
	}

	/**
	 * 
	 * @dev Encodes data for a trading position
	 * @param user Address of the user 
	 * @param tokenIn Address of the token to be swapped 
	 * @param tokenOut Address of the token to be received 
	 * @param amountIn Amount of the token to be swapped 
	 * @param minAmountOut Minimum amount of the token to be received 
	 * @return positionId identifier (unique for this position)
	 */

	function encodeTradingPosition(address user, address tokenIn, address tokenOut, uint256 amountIn, uint256 minAmountOut) external view returns(bytes32 positionId, bytes memory encodedData){
		//Encode the position data 
		encodedData = abi.encodePacked(user, tokenIn, tokenOut, amountIn, minAmountOut, block.timestamp);

		// Create a unique identifier for the position 
		positionId = keccak256(encodedData);
	}


	/**
	 * @dev Encodes parameters for a swap on a DEX
	 * @param path Array of tokens for the swap 
	 * @param amount array of amount 
	 * @param deadline Transaction deadline
	 * @return swapData Encoded swap data
	 */
	function encodeSwapData(address[] calldata path, uint256[] calldata amount, uint256 deadline) external pure returns(bytes memory swapData) {
		require(path.length == amount.length, "Array length mismatch"); 

		//Encode the path 
		bytes memory pathData; 
		for (uint i = 0; i < path.length; i++) {
			pathData = abi.encodePacked(pathData, path[i]); 
		}

		//Encode the amounts 
		bytes memory amountData; 
		for (uint i = 0; i < amount.length; i++) {
			amountData = abi.encodePacked(amountData, amount[i]);
		}

		//Combine everything 
		swapData = abi.encodePacked(pathData, amountData, deadline);
	}
}