pragma solidity ^0.4.9;

import "ds-auth/auth.sol";

contract DSRobot is DSAuth {
	event FirmwareUpdated(address, bytes);
	address firmware;

	function setFirmware(bytes _code) auth {
		assembly {
			let target := create(0, add(_code, 0x20), mload(_code))	//deploy contract
			jumpi(invalidJumpLabel, iszero(extcodesize(target)))	//throw if deployed contract contains code
			sstore(firmware, target)								//save contract address to storage
		}
		FirmwareUpdated(msg.sender, _code);
	}
	function execute(bytes _data) 
		auth
		payable
		returns (bytes32 response) {
		assembly {
			let target := sload(firmware)							//load address of firmware contract
			let succeeded := delegatecall(sub(gas, 5000), target, add(_data, 0x20), mload(_data), 0, 32)	//call deployed contract in current context
			response := mload(0)									//load delegatecall output to response
			jumpi(invalidJumpLabel, iszero(succeeded))             	//throw if delegatecall failed
		}
		return response;
	}
}

contract DSRobotFactory {
	event Created(address sender, address robot);
	mapping(address=>bool) isRobot;
	function build() returns (DSRobot) {
		var robot = new DSRobot();
		Created(msg.sender, robot);
		robot.setOwner(msg.sender);
		isRobot[robot] = true;
		return robot;
	}
}