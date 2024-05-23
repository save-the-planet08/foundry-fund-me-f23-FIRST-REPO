// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionTest is Test{
       FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        //startPrank(USER);
        vm.prank(USER);
        vm.deal(USER, 1e18);
        fundFundMe.fundFundMe{value: SEND_VALUE}(address(fundMe));
        //vm.stopPrank();

        address funder = fundMe.getFunder(0); 
        assertEq(funder, USER);
        //WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        //withdrawFundMe.withdrawFundMe(address(fundMe));

        //assert(address(fundMe).balance == 0);
    }
}