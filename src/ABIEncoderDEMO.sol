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

	/**
	 * @dev Encodes data for a limit order
	 * @param maker Maker address 
	 * @param taker Taker address 
	 * @param tokenIn Input token
	 * @param tokenOut Output token
	 * @param amountIn Input amount
	 * @param amountOut Output amount
	 * @param nonce Unique nonce 
	 * @return orderHash 
	 * @return orderData 
	 */

	function encodeLimitOrder(address maker, address taker, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut, uint256 nonce) external pure returns(bytes32 orderHash, bytes memory orderData) {
		//Encode the order data
		orderData = abi.encodePacked(maker, taker, tokenIn, tokenOut, amountIn, amountOut, nonce, "LIMIT_ORDER_V1");

		//Create the order hash
		orderHash = keccak256(orderData);
	}

	/**
	 * @dev Econdes data for a yield position 
	 * @param user Address of the user 
	 * @param poolId Identifier of the pool 
	 * @param amount Amount to be deposited 
	 * @param startTime Start time of the position 
	 * @return positionId Identifier (unique for this position)
	 */

	function encodeYieldPosition(address user, bytes32 poolId, uint256 amount, uint256 startTime) external pure returns(bytes32 positionId) {
		positionId = keccak256(abi.encodePacked(user, poolId, amount, startTime, "YIELD_POSITION"));
	}


	/**
	 * @dev Encodes data for a flash loan 
	 * @param token Token to be borrowed 
	 * @param amount Amount to be borrowed 
	 * @param callbackData Data to be passed to the callback function 
	 * @return flashData Encoded flash loan data
	 */


	function encodeFlashLoadData(address token, uint256 amount, bytes calldata callbackData) external pure returns(bytes memory flashData) {
		flashData = abi.encodePacked(token, amount, callbackData, "FLASH_LOAN_V1");
	}

	/**
	 * @dev Encodes parameters for a staking pool 
	 * @param token Token address
	 * @param rewardRate Reward rate
	 * @param lockPeriod Lock period
	 * @param maxStakers Maximum number of stakers
	 * @return poolConfig Encoded configuration data
	 */

	function encodeStakingPoolConfig(address token, uint256 rewardRate, uint256 lockPeriod, uint256 maxStakers) external view returns(bytes memory poolConfig) {
		poolConfig = abi.encodePacked(token, rewardRate, lockPeriod, maxStakers, block.timestamp);

	}

	/**
	 * @dev Creates a unique hash for a user across multiple pools
	 * @param user User address
	 * @param poolIds Array of pool identifiers
	 * @return userHash Unique user hash 
	 */

	function createUserMultiPoolHash(address user, bytes32[] calldata poolIds) external pure returns (bytes32 userHash) {
		bytes memory data = abi.encodePacked(user);

		//Encode all pool ids
		for(uint i = 0; i < poolIds.length; i++){
			data = abi.encodePacked(data, poolIds[i]);
		}

		//Hash the data 
		data = abi.encodePacked(data, "MULTI_POOL_USER");
		userHash = keccak256(data);
	}

	/**
	 * @dev Encodes data for a yield farming strategy
	 * @param strategyName Name of the strategy
	 * @param pools Array of involved pools
	 * @param weights Array of weights for each pool
	 * @return strategyData Encoded strategy data
	 */

	function encodeYieldStrategy(
		string calldata strategyName,
		address[] calldata pools,
		uint256[] calldata weights
	) external pure returns(bytes memory strategyData) {
		require(pools.length == weights.length, "Arrays length mismatch");

		//Encode strategy name
		bytes memory nameData = abi.encodePacked(strategyName);

		//Encode pools
		bytes memory poolsData;
		for (uint i = 0; i < pools.length; i++) {
			poolsData = abi.encodePacked(poolsData, pools[i]);
		}

		//Encode weights
		bytes memory weightsData;
		for (uint i = 0; i < weights.length; i++) {
			weightsData = abi.encodePacked(weightsData, weights[i]);
		}

		//Combine everything
		strategyData = abi.encodePacked(nameData, poolsData, weightsData, "YIELD_STRATEGY_V1");
	}

}