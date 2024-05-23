// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        //fundMe = new FundMe(0x5FFc014343cd971B7EB7073F6859dDc555BB07D7);
        DeployFundMe deployFundMe = new DeployFundMe(); 
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);

    }

    function testMinimumDollarIsFive() public view{
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    } 

    function testPriceFeedVersionIsAccurate() public view{
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnuoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }
    function testAddsFunderToArrayOfFunders() public funded{

        address funder = fundMe.getFunder(0); 
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded{
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
        }

    function testWithdrawWithASingleFunder() public funded{
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
}
        function testWithdrawFromMultipleFunders() public funded {
            //Arrange
            uint160 numberOfFunders = 10;
            uint160 startingFunderIndex = 1;
            for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
                //hoax(address(i), SEND_VALUE);
                deal(address(i), SEND_VALUE); assertEq(address(i).balance, SEND_VALUE);
                fundMe.fund{value: SEND_VALUE};
            }
         
            uint256 startingOwnerBalance = fundMe.getOwner().balance;
            uint256 startingFundMeBalance = address(fundMe).balance;
        

            //Act
            vm.startPrank(fundMe.getOwner());
            fundMe.withdraw();
            vm.stopPrank();

            //Assert 
            assert(address(fundMe).balance ==0);
            assert(startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance);
        }


function testWithdrawFromMultipleFundersCheaper() public funded {
            //Arrange
            uint160 numberOfFunders = 10;
            uint160 startingFunderIndex = 1;
            for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
                //hoax(address(i), SEND_VALUE);
                deal(address(i), SEND_VALUE); assertEq(address(i).balance, SEND_VALUE);
                fundMe.fund{value: SEND_VALUE};
            }
         
            uint256 startingOwnerBalance = fundMe.getOwner().balance;
            uint256 startingFundMeBalance = address(fundMe).balance;
        

            //Act
            vm.startPrank(fundMe.getOwner());
            fundMe.cheaperWithdraw();
            vm.stopPrank();

            //Assert 
            assert(address(fundMe).balance ==0);
            assert(startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance);
        }
}