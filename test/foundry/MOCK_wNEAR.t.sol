import "forge-std/Test.sol";
import { console } from "forge-std/console.sol";

import "../../contracts/MOCK_WNEAR.sol";
import "../../contracts/MOCK_NEAR.sol";

pragma solidity ^0.8.0;

contract MOCK_WNEAR_Test is Test {
    MOCK_NEAR internal near;
    MOCK_WNEAR internal wnear;
    address internal deployer = vm.addr(1);
    address internal random = vm.addr(2);

    function setUp() public {
        vm.startPrank(deployer);
        near = new MOCK_NEAR();
        wnear = new MOCK_WNEAR(address(near));
        vm.stopPrank();
    }

    function test_MOCK_NEAR_state_variables_at_deploy() public {
        assertEq(near.decimals(), 24);
        assertEq(near.name(), "NEAR");
        assertEq(near.symbol(), "NEAR");
        assertEq(near.totalSupply(), 0);
    }

    function test_MOCK_WNEAR_state_variables_at_deploy() public {
        assertEq(wnear.decimals(), 18);
        assertEq(wnear.name(), "Wrapped NEAR");
        assertEq(wnear.symbol(), "wNEAR");
        assertEq(wnear.totalSupply(), 0);
        assertEq(wnear.NEAR(), address(near));
        assertEq(wnear.SCALE_FACTOR(), 1e6);
    }

    function testFuzzIntegration_wrapping_and_unwrapping_NEAR_should_result_in_unchanged_NEAR_balance(uint256 amount) public {
        // Deployer mint NEAR and wrap minted NEAR into wNEAR
        vm.startPrank(deployer);
        near.mint(deployer, amount);
        assertEq(near.balanceOf(deployer), amount);
        uint256 SCALE_FACTOR = wnear.SCALE_FACTOR();
        near.approve(address(wnear), amount);
        wnear.deposit(amount);
        assertEq(near.balanceOf(deployer), amount - (amount / SCALE_FACTOR * SCALE_FACTOR));
        assertEq(wnear.balanceOf(deployer), amount / SCALE_FACTOR);
        assertEq(wnear.totalSupply(), amount / SCALE_FACTOR);
        assertEq(near.totalSupply(), amount);
        // Deployer attempts to unwrap more wNEAR than they have
        vm.expectRevert(bytes("ERC20: burn amount exceeds balance"));
        wnear.withdraw((amount / SCALE_FACTOR) + 1);
        // Deployer unwraps entire wNEAR balance
        wnear.withdraw(amount / SCALE_FACTOR);
        assertEq(wnear.totalSupply(), 0);
        assertEq(wnear.balanceOf(deployer), 0);
        assertEq(near.totalSupply(), amount);
        assertEq(near.balanceOf(deployer), amount);
    }

    function testFuzzIntegration_deposit_revert_when_user_has_0_NEAR(uint256 amount) public {
        vm.startPrank(deployer);
        vm.assume(amount > 0);
        assertEq(near.balanceOf(deployer), 0);
        near.approve(address(wnear), amount);
        vm.expectRevert(bytes("insufficient NEAR balance"));
        wnear.deposit(amount);
    }

    function testFuzzIntegration_withdraw_revert_when_user_has_0_WNEAR(uint256 amount) public {
        vm.startPrank(deployer);
        vm.assume(amount > 0);
        assertEq(wnear.balanceOf(deployer), 0);
        vm.expectRevert();
        vm.expectRevert(bytes("ERC20: burn amount exceeds balance"));
        wnear.withdraw(amount);
    }

    function testFuzzIntegration_wrap_NEAR_transfer_WNEAR(uint256 amount) public {
        // Deployer mint NEAR and wrap minted NEAR into wNEAR
        vm.startPrank(deployer);
        near.mint(deployer, amount);
        assertEq(near.balanceOf(deployer), amount);
        uint256 SCALE_FACTOR = wnear.SCALE_FACTOR();
        near.approve(address(wnear), amount);
        wnear.deposit(amount);
        assertEq(near.balanceOf(deployer), amount - (amount / SCALE_FACTOR * SCALE_FACTOR));
        assertEq(wnear.balanceOf(deployer), amount / SCALE_FACTOR);
        assertEq(near.balanceOf(random), 0);
        assertEq(wnear.balanceOf(random), 0);
        assertEq(wnear.totalSupply(), amount / SCALE_FACTOR);
        assertEq(near.totalSupply(), amount);

        // Deployer transfer wNEAR to random
        wnear.transfer(random, amount / SCALE_FACTOR);
        assertEq(wnear.totalSupply(), amount / SCALE_FACTOR);
        assertEq(near.totalSupply(), amount);
        assertEq(near.balanceOf(deployer), amount - (amount / SCALE_FACTOR * SCALE_FACTOR));
        assertEq(near.balanceOf(random), 0);
        assertEq(wnear.balanceOf(random), amount / SCALE_FACTOR);
        assertEq(wnear.balanceOf(deployer), 0);
    
        // Deployer attempt to unwrap wNEAR (which they currently have none)
        vm.expectRevert(bytes("ERC20: burn amount exceeds balance"));
        wnear.withdraw(1);
        vm.stopPrank();

        vm.startPrank(random);
        // Random attempt to unwrap more wNEAR than they have
        vm.expectRevert(bytes("ERC20: burn amount exceeds balance"));

        // Random unwraps all their wNEAR
        wnear.withdraw((amount / SCALE_FACTOR) + 1);
        wnear.withdraw(amount / SCALE_FACTOR);
        assertEq(wnear.totalSupply(), 0);
        assertEq(near.totalSupply(), amount);
        assertEq(near.balanceOf(deployer), amount - (amount / SCALE_FACTOR * SCALE_FACTOR));
        assertEq(near.balanceOf(random), amount / SCALE_FACTOR * SCALE_FACTOR);
        assertEq(wnear.balanceOf(deployer), 0);
        assertEq(wnear.balanceOf(random), 0);
    }
}