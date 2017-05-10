pragma solidity ^0.4.9;

import "ds-auth/auth.sol";

contract DSRobot is DSAuth {
	address firmware;

	function setFirmware(bytes _code) auth {
		assembly {
			firmware := create(0, add(_code, 0x20), mload(_code))	//deploy contract
			jumpi(invalidJumpLabel, iszero(extcodesize(firmware)))	//throw if deployed contract contains code
		}
	}

	//fallback
	function () {}
}

contract DSRobotFactory {
	event Created(address sender, address robot);
	mapping(address=>bool) isRobot;
	function build() {
		var robot = new DSRobot();
		Created(msg.sender, robot);
		robot.setAuthority(msg.sender);
		isRobot[robot] = true;
		return robot;
	}
}