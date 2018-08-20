pragma solidity 0.4.24;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Marketplace.sol";
//import "../contracts/StoreItemLib";

contract TestMarketplace {
    //Marketplace market = Marketplace(DeployedAddresses.Marketplace());
    Marketplace public market = new Marketplace();
    uint public initialBalance = 10 ether;
    string public itemName1 = "shirt";
    bytes32 public itemId1 = bytes32(keccak256(abi.encodePacked(itemName1))); // keccak256(itemName1);
    uint public itemPrice1 = 250 wei;
    uint public qtyInStore1 = 2000;
    uint public itemPrice1_2 = 300 wei;
    uint public qtyInStore1_2 = 3000;
    uint public qty2Buy1 = 100;
    string public itemName2 = "skirt";
    bytes32 public itemId2 =  bytes32(keccak256(abi.encodePacked(itemName2))); // keccak256(itemName2);
    uint public itemPrice2 = 350 wei;
    uint public qtyInStore2 = 1000;
    uint public qty2Buy2 = 200;


    StoreItemLib public item = StoreItemLib(DeployedAddresses.StoreItemLib());
    using StoreItemLib for StoreItemLib.StoreItem; 


    function testSettingOwnerDuringCreation() public {
        // test contract owner
        Owned owned = new Owned();
        Assert.equal(owned.owner(), this, "Owner is different than a deployer");
    }

    function testSettingOwnerOfDeployedContract() public {
        Owned owned = Owned(DeployedAddresses.Marketplace());
        Assert.equal(owned.owner(), msg.sender, "Owner is different than a deployer");
    }

    //function addItem
    function testAddingItems() public {
        // add item
        Assert.equal(market.newProduct(itemName1, qtyInStore1, itemPrice1), itemId1, "Not added product");

    } 

    //function updItem(string _name, uint _qty, uint _price) 
    function testUpdItem() public {
        // update item - 
        Assert.equal(market.update(itemName1, qtyInStore1_2, itemPrice1_2), true, "After adding new shirts the result should be TRUE");

    }

    // freezing and unfreezing contract
    function testFreezeContract() public {
        // freezeContr = true;
        market.freezeContract();
        Assert.equal(market.freezeContr(), true, "Contract should not work");
    }

    function testUnfreezeContract() public {
        // freezeContr = false;
        market.unFreezeContract();
        Assert.equal(market.freezeContr(), false, "Contract should work");
    }




}
