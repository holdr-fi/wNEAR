import "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../contracts/WNEAR.sol";

pragma solidity ^0.8.0;

contract NEAR_Aurora_Fork_Test is Test {
    WNEAR internal wnear;
    address internal deployer = vm.addr(1);
    address internal random = vm.addr(2);
    IERC20 internal near = IERC20(0xC42C30aC6Cc15faC9bD938618BcaA1a1FaE8501d);
    address internal nearWhale = 0xC84E29955D4Fc6e71189558529E3d66fDC2402F6;
    uint256 internal nearWhaleBalance;
    uint256 internal SCALE_FACTOR;

    function setUp() public {
        vm.startPrank(deployer);
        wnear = new WNEAR();
        nearWhaleBalance = near.balanceOf(nearWhale);
        SCALE_FACTOR = wnear.SCALE_FACTOR();
        vm.stopPrank();
    }

    function test_state_variables_at_deployment() public {
        assertEq(wnear.decimals(), 18);
        assertEq(wnear.name(), "Wrapped NEAR");
        assertEq(wnear.symbol(), "wNEAR");
        assertEq(wnear.totalSupply(), 0);
        assertEq(wnear.NEAR(), address(near));
        assertEq(wnear.SCALE_FACTOR(), 1e6);
    }

    function testFuzzIntegration_wrapping_and_unwrapping_NEAR_should_result_in_unchanged_NEAR_balance(uint256 amount) public {
        assertEq(wnear.balanceOf(nearWhale), 0);
        assertEq(wnear.totalSupply(), 0);
        
        // nearWhale grant approval to wNEAR to move their NEAR
        vm.startPrank(nearWhale);
        vm.assume(amount <= nearWhaleBalance);
        near.approve(address(wnear), amount);

        // nearWhale attempt to wrap more NEAR than they have
        vm.expectRevert(bytes("insufficient NEAR balance"));
        wnear.deposit(nearWhaleBalance + 1);

        // nearWhale wrap their NEAR
        wnear.deposit(amount);
        assertEq(wnear.totalSupply(), amount / SCALE_FACTOR);
        assertEq(wnear.balanceOf(nearWhale), amount / SCALE_FACTOR);
        assertEq(near.balanceOf(nearWhale), nearWhaleBalance - (amount / SCALE_FACTOR * SCALE_FACTOR));
        
        // nearWhale attempts to unwrap more wNEAR than they have
        vm.expectRevert(bytes("ERC20: burn amount exceeds balance"));
        wnear.withdraw((amount / SCALE_FACTOR) + 1);

        // nearWhale unwraps entire wNEAR balance
        wnear.withdraw(amount / SCALE_FACTOR);
        assertEq(wnear.totalSupply(), 0);
        assertEq(wnear.balanceOf(nearWhale), 0);
        assertEq(near.balanceOf(nearWhale), nearWhaleBalance);
    }

    function testFuzzIntegration_deposit_revert_when_user_has_0_NEAR(uint256 amount) public {
        vm.startPrank(random);
        vm.assume(amount > 0);
        assertEq(near.balanceOf(random), 0);
        near.approve(address(wnear), amount);
        vm.expectRevert(bytes("insufficient NEAR balance"));
        wnear.deposit(amount);
    }

    function testFuzzIntegration_withdraw_revert_when_user_has_0_WNEAR(uint256 amount) public {
        vm.startPrank(random);
        vm.assume(amount > 0);
        assertEq(wnear.balanceOf(random), 0);
        vm.expectRevert(bytes("ERC20: burn amount exceeds balance"));
        wnear.withdraw(amount);
    }

    function testFuzzIntegration_wrap_NEAR_transfer_WNEAR(uint256 amount) public {
        assertEq(wnear.balanceOf(nearWhale), 0);
        assertEq(wnear.totalSupply(), 0);

        // nearWhale mint NEAR and wrap minted NEAR into wNEAR
        vm.startPrank(nearWhale);
        vm.assume(amount <= nearWhaleBalance);
        near.approve(address(wnear), amount);
        wnear.deposit(amount);
        assertEq(wnear.totalSupply(), amount / SCALE_FACTOR);
        assertEq(wnear.balanceOf(nearWhale), amount / SCALE_FACTOR);
        assertEq(near.balanceOf(nearWhale), nearWhaleBalance - (amount / SCALE_FACTOR * SCALE_FACTOR));
        assertEq(near.balanceOf(random), 0);
        assertEq(wnear.balanceOf(random), 0);

        // Deployer transfer wNEAR to random
        wnear.transfer(random, amount / SCALE_FACTOR);
        assertEq(wnear.totalSupply(), amount / SCALE_FACTOR);
        assertEq(near.balanceOf(nearWhale), nearWhaleBalance - (amount / SCALE_FACTOR * SCALE_FACTOR));

        assertEq(near.balanceOf(random), 0);
        assertEq(wnear.balanceOf(random), amount / SCALE_FACTOR);
        assertEq(wnear.balanceOf(nearWhale), 0);
    
        // Deployer attempt to unwrap wNEAR (which they currently have none)
        vm.expectRevert(bytes("ERC20: burn amount exceeds balance"));
        wnear.withdraw(1);
        vm.stopPrank();

        vm.startPrank(random);
        // Random attempt to unwrap more wNEAR than they have
        vm.expectRevert(bytes("ERC20: burn amount exceeds balance"));
        wnear.withdraw((amount / SCALE_FACTOR) + 1);

        // Random unwraps all their wNEAR
        wnear.withdraw(amount / SCALE_FACTOR);
        assertEq(wnear.totalSupply(), 0);
        assertEq(near.balanceOf(nearWhale), nearWhaleBalance - (amount / SCALE_FACTOR * SCALE_FACTOR));
        assertEq(near.balanceOf(random), amount / SCALE_FACTOR * SCALE_FACTOR);
        assertEq(wnear.balanceOf(nearWhale), 0);
        assertEq(wnear.balanceOf(random), 0);
    }

}