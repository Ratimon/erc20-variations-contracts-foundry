// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Mintable} from "@main/interfaces/IERC20Mintable.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import {ISanctionRoles} from "@main/interfaces/ISanctionRoles.sol";
import {IERC1363WithSanction} from "@main/interfaces/IERC1363WithSanction.sol";

import {Errors} from "@main/shared/Error.sol";
import {ERC1363WithSanction} from "@main/ERC1363WithSanction.sol";

import {ConstantsFixture}  from "@test/unit/utils/ConstantsFixture.sol";
import {DeploymentERC1363WithSanction}  from "@test/unit/utils/ERC1363WithSanction.constructor.sol";

contract TestUnitERC1363WithSanction is  ConstantsFixture, DeploymentERC1363WithSanction {

    event MinterSet(address indexed previousMinter, address indexed newMinter);

    event BlackListAdded(address indexed blacklist);
    event BlackListRemoved(address indexed blacklist);

    IERC1363WithSanction erc1363WithSanction;

    function setUpScripts() internal virtual override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public  virtual override {
        super.setUp();
        vm.label(address(this), "TestUnitERC1363WithSanction");

        vm.startPrank(deployer);

        arg_erc1363WithSanction.name = "Test Sanction Token";
        arg_erc1363WithSanction.symbol = "SANC";
        arg_erc1363WithSanction.initialOwner = msg.sender;
        arg_erc1363WithSanction.initialSanctionAdmin = msg.sender;
        arg_erc1363WithSanction.initialMinter = msg.sender;
        erc1363WithSanction = IERC1363WithSanction(DeploymentERC1363WithSanction.deployAndSetup( arg_erc1363WithSanction ));

        vm.label(address(erc1363WithSanction), "erc1363WithSanction");

        vm.stopPrank();
    }

    function test_Constructor() public {
        assertEq(ISanctionRoles(address(erc1363WithSanction)).owner(), deployer);
        assertEq(ISanctionRoles(address(erc1363WithSanction)).sanctionAdmin(), deployer);
        assertEq(ISanctionRoles(address(erc1363WithSanction)).minter(), deployer);
    }

    function test_mint() public {

        vm.startPrank(deployer);

        vm.expectEmit(true,true,false,false);
        emit MinterSet(deployer,dave);
        ISanctionRoles(address(erc1363WithSanction)).setMinter(dave);

        assertEq(ISanctionRoles(address(erc1363WithSanction)).minter(), dave);

        vm.stopPrank();
        vm.startPrank(dave);

        erc1363WithSanction.mint(dave, 1_000e18);
        
        assertEq(  IERC20(address(erc1363WithSanction)).balanceOf(dave), 1_000e18);

    }


    function test_RevertWhen_NotAuthorized_addToBlackList() public {
        vm.startPrank(alice);

        vm.expectRevert(
            abi.encodeWithSelector(Errors.NotAuthorized.selector, alice)
        );
        erc1363WithSanction.addToBlackList(bob);

        vm.stopPrank();
    }

    function test_addToBlackList() public {
        vm.startPrank(deployer);

        vm.expectEmit(true,false,false,false);
        emit BlackListAdded(bob);
        erc1363WithSanction.addToBlackList(bob);
        assertEq(erc1363WithSanction.isBlacklist(bob), true);

        vm.stopPrank();

        deal({token : address(erc1363WithSanction), to: bob, give: 10 ether });
        vm.startPrank(bob);

        uint256 balance = IERC20(address(erc1363WithSanction)).balanceOf(bob);
        assertEq(balance, 10 ether);
        
        vm.expectRevert(
            bytes("The caller is on the blacklist")
        );
        IERC1363(address(erc1363WithSanction)).transferAndCall(carol, 2 ether);

        vm.stopPrank();
    }

    function testFuzz_addToBlackList(uint256 amount_to_send) public {
        amount_to_send = bound( amount_to_send, 0.5 ether, 10 ether);

        vm.startPrank(deployer);

        vm.expectEmit(true,false,false,false);
        emit BlackListAdded(bob);
        erc1363WithSanction.addToBlackList(bob);
        assertEq(erc1363WithSanction.isBlacklist(bob), true);

        vm.stopPrank();

        deal({token : address(erc1363WithSanction), to: bob, give: amount_to_send });
        vm.startPrank(bob);

        uint256 balance = IERC20(address(erc1363WithSanction)).balanceOf(bob);
        assertEq(balance, amount_to_send);
        
        vm.expectRevert(
            bytes("The caller is on the blacklist")
        );
        IERC1363(address(erc1363WithSanction)).transferAndCall(carol, amount_to_send);

        vm.stopPrank();
    }

    function testFuzz_removeFromBlackList(uint256 amount_to_send) public {
        amount_to_send = bound( amount_to_send, 0.5 ether, 10 ether);

        vm.startPrank(deployer);

        erc1363WithSanction.addToBlackList(bob);
        assertEq(erc1363WithSanction.isBlacklist(bob), true);

        erc1363WithSanction.removeFromBlacklist(bob);
        assertEq(erc1363WithSanction.isBlacklist(bob), false);

        vm.stopPrank();
    }




}