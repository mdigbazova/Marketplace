pragma solidity 0.4.24;

/*
Mandatory tasks for Marketplace:
●	ok (20%) (lecture 6) Public method to buy a store item by specifying its ID (a string) and quantity. 
The method should execute successfully if the marketplace has enough of the item in stock and the 
sent funds are sufficient. 
Overpay is considered a tip.
●	ok (10%) (lecture 6) Public method to update the stock of an item by taking its ID and the new 
availability (items in stock). 
This method should only be called from the contract owner!
●	ok (10%) (lecture 6) Public method to add a new product to the Marketplace by specifying its name 
(string), price and initial quantity.
●	ok (10%) (lecture 6) Public constant method to get the price, name and stock about a product by its 
ID.
●	ok (10%) (lecture 6) Public constant method that returns an array of all product IDs.

Optional tasks for Marketplace:
●	None yet

Mandatory tasks for all topics:
●	(40%) (lecture 10) Unit tests for all the methods in your contract (including all aforementioned). 
The tests should handle all constraints around the contract. Example with DDNS: A test can be one that 
tries to register an already registered domain. 
The test is passed if the operation fails (expected behavior).


Optional tasks for all topics:
●	ok (5%) (lecture 5) Use contract events to signify that an activity has taken place in your contract. 
Events can be for domain registration / 
transfer (DDNS) or item purchase / stock update (Marketplace), for example.
●	(20%) (lecture 8) Create a basic website with MetaMask that connects to a contract (published in a 
test net or local blockchain). 
The application should allow at least one operation with the contract (Domain registration or Store 
purchase are examples).
●	ok (5%) (lecture 6) Dynamic pricing. For DDNS, the base price can increase if a short domain name is 
bought. For Marketplace, price can increase as the stock of an item lowers.
●	ok (5%) (lecture 6) Public method to withdraw the funds from the contract. This should be called 
only from the contract owner 
(the address which initially created the contract).
*/

    /**
    * @title SafeMath
    * @dev Math operations with safety checks that throw on error
    */
    library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
        return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
 
    /**
    * @dev Returns percent of number in uint256, throws on overflow.
    */ 
    function percent100(uint number, uint percent) 
            internal 
            pure 
            returns(uint256) 
            {
        assert(percent < 100);
        uint256 retNumber = number + (number * percent / 100);
        return retNumber;
    }

}


library StoreItemLib {
  // We define a new struct datatype that will be used to
  // hold its data in the calling contract.
    
    using SafeMath for uint;
    struct StoreItem { // call it like StoreItem.itemId or self.itemId
        bytes32 itemId;  // keccak256(itemName) -> bytes32(keccak256(abi.encodePacked(name)));
        string name; // shirt, shoes, dress
        uint price;
        uint qty; // existing quantity
    }

    function getItemData(StoreItem storage self) 
            internal 
            view
            returns (string, uint, uint) {
        //(10%) (lecture 6) Public constant method to get the price, name and 
        //stock about a product by its ID.
        return (self.name, self.price, self.qty);
    }

    function updItemPrice (StoreItem storage self)
            internal
            //view
            returns (uint256)
            {
        /*●	(5%) (lecture 6) Dynamic pricing. 
         For Marketplace, price can increase as the stock of an item lowers.*/
         /* the Formula is:
         - if the number of items > 1000 -> 0% increase in price
         - if the number of items are <= 1000 -> 2% increase in price 
         - if the number of items are <= 800 -> 4% increase in price 
         - if the number of items are <= 500 -> 6% increase in price 
         - if the number of items are <= 400 -> 8% increase in price 
         - if the number of items are <= 200 -> 10% increase in price 
         - if the number of items are <= 100 -> 12% increase in price 

         uint c = a * (b / 100) * 100; // = percent b * 100
        */
        uint newPrice; 
        if(self.qty <= 1000 && self.qty > 800){ // <= 1000 
            newPrice = SafeMath.percent100(self.price, 2);
        }
        else if(self.qty <= 800 && self.qty > 500){ // <= 800 
            newPrice = SafeMath.percent100(self.price, 4);
        }
        else if(self.qty <= 500 && self.qty > 400){ // <= 500 
            newPrice = SafeMath.percent100(self.price, 6);
        }
        else if(self.qty <= 400 && self.qty > 200){ // <= 400
            newPrice = SafeMath.percent100(self.price, 8);
        }
        else if(self.qty <= 200 && self.qty > 100){ // <= 200
            newPrice = SafeMath.percent100(self.price, 10);
        }
        else if(self.qty <= 100 && self.qty > 0){ // <= 100
            newPrice = SafeMath.percent100(self.price, 12);
        }
        else {   // (self.qty > 1000) {
            newPrice = self.price;
        }
        self.price = newPrice;
        return newPrice;
    }

     
    function insertItem(StoreItem storage self, bytes32 _itemId, string _name, uint _price, uint _qty)
        internal
        returns (bool)
        {           
            if (self.itemId == 0) {// doesn't exist
                self.itemId = _itemId;
                self.name = _name;
                self.qty = _qty;
                self.price = _price;
                
                return true; 
            }
            else {
                return false; // already there
            }
        }


    function updateItem (StoreItem storage self, uint _price, uint _qty, uint _oper) // operations: 0 - sub, 1 - add;
        internal    
        returns (bool) 
        {
            /*	(10%) (lecture 6) Public method to update the stock of an item by taking its ID and the new 
                availability (items in stock). 
                This method should only be called from the contract owner!*/
        
            if (self.itemId != 0) { //  exists
                if(_oper == 1) { // operations: 0 - sub, 1 - add;
                    self.qty = SafeMath.add(self.qty, _qty); // new supply 
                    if(_price > 0 ) {self.price = _price;}
                    
                }
                else{
                    self.qty = SafeMath.sub(self.qty, _qty); // buying item
                }
                return true; 
            }
            else {
                return false; // doesn't exist
            }
        }
        

}


contract Owned {
    address public owner;  
    
    constructor () public {
        owner = msg.sender;
        //owner = _owner; // msg.sender
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner!");
        _;
    }

    /*modifier onlyNotOwner() {
        require(msg.sender != owner, "Only not Owner!");
        _;
    }*/

}



contract Marketplace is Owned {
    // libraries
    using SafeMath for uint; //all integer operations are using the safe library
    using StoreItemLib for StoreItemLib.StoreItem; 

    // state vars:
    uint public tips; // Overpay is considered a tip.
    bytes32 public itemIdToAddOrBuy; // itemId to be purchased
    
    // mapping for items
    mapping(bytes32 => StoreItemLib.StoreItem) public items;
    bytes32[] public itemIds; // array of all itemIds 
    bool public freezeContr; // to freeze contract for Security reason

    //contract events
    event LogItemPurchased(string desc, string name, uint price, uint qty, uint amount);
    event LogTipsAdded(bytes32 id, uint tipAmount);
    event LogItemInserted(string desc, string name, uint price, uint qty);
    event LogItemSupplied(string desc, string name, uint price, uint qty); 
    event LogRefund(string desc, address indexed to, uint amount, uint tips); // log the event Refund
    //event LogDestroyed(string desc, address owner);
    event LogItemPriceChanged(string desc, string name, uint newPrice, uint oldPrice);
    

    // modifiers:
    modifier onlyStoreItem(string _name) {
        //the item should exist
        itemIdToAddOrBuy = bytes32(keccak256(abi.encodePacked(_name))); //keccak256(_name);
        require(items[itemIdToAddOrBuy].itemId != 0, "Item doesn't exist in the Store!");
        _;
    }

    modifier canAddItem(string _name) {
        itemIdToAddOrBuy = bytes32(keccak256(abi.encodePacked(_name))); //keccak256(_name);
        require(items[itemIdToAddOrBuy].itemId == 0, "Item exists in the Store."); //item shouldn't exist
        _;
    }
    
    
    modifier canBuyItem(uint _qty) {
        require(msg.value > 0, "Amount sent should be positive");
        require(items[itemIdToAddOrBuy].qty >= _qty, "Unsufficient quantity of item."); 
        require(msg.value >= SafeMath.mul(_qty, items[itemIdToAddOrBuy].price), "Unsufficient amount sent.");
        _;
    }

    modifier contractNotFreezed(){
        require (freezeContr == false, "Contract is freezed");
        _;
    }

    constructor() Owned public {
        freezeContr = false;
    }


    // functions    
    function freezeContract() public onlyOwner {
        // to freeze contract
        freezeContr = true;
    }

    function unFreezeContract() public onlyOwner {
        // to unFreeze contract
        freezeContr = false;
    }

    function newProduct(string _name, uint _price, uint _qty) 
            contractNotFreezed
            canAddItem (_name)
            onlyOwner
            public 
            returns(bytes32) {
        /*  ●	(10%) (lecture 6) Public method to add a new product to the 
            Marketplace by specifying its name 
            (string), price and initial quantity.
        */
        require(items[itemIdToAddOrBuy].insertItem(itemIdToAddOrBuy, _name, _price, _qty));
        itemIds.push(itemIdToAddOrBuy);
        emit LogItemInserted("Item is inserted", _name, _price, _qty);
        return itemIdToAddOrBuy;
    }
    
    function update(string _name, uint _price, uint _qty) 
            contractNotFreezed
            onlyStoreItem (_name)
            onlyOwner
            public 
            returns(bool) {
            /*	(10%) (lecture 6) Public method to update the stock of an item by taking its ID and the new 
                availability (items in stock). 
                This method should only be called from the contract owner!
            */
                
        itemIdToAddOrBuy = bytes32(keccak256(abi.encodePacked(_name))); // keccak256(_name);
        require(items[itemIdToAddOrBuy].updateItem(_price, _qty, 1)); // operations: 0 - sub, 1 - add;
        emit LogItemSupplied("New supply for item: ", _name, _price, _qty);
        return true;
    }
    

    function buy(string _name, uint _qty)
            contractNotFreezed
            //onlyNotOwner
            onlyStoreItem(_name)
            canBuyItem (_qty)
            public 
            payable
            returns (bool)
            {
        /*●	(20%) (lecture 6) Public method to buy a store item by specifying its ID (a string) and quantity. 
        The method should execute successfully if the marketplace has enough of the item in stock and the 
        sent funds are sufficient. 
        Overpay is considered a tip.*/

        // operations: 0 - sub, 1 - add;:
        require(items[itemIdToAddOrBuy].updateItem(0, _qty, 0), "Either missing quantity, or unsufficient amount"); 

        uint _price = items[itemIdToAddOrBuy].price;
        uint _amountOfPurchase = items[itemIdToAddOrBuy].price.mul(_qty);
        uint _tip = msg.value.sub(_amountOfPurchase);
        if (_tip > 0){
            tips = tips.add(_tip);
            emit LogTipsAdded(itemIdToAddOrBuy, _tip);
        }

        if (items[itemIdToAddOrBuy].updItemPrice() > 0) {
            if(_price != items[itemIdToAddOrBuy].price){
                emit LogItemPriceChanged("Increase in price", _name, items[itemIdToAddOrBuy].price, _price);
            }
            emit LogItemPurchased("Item is purchased", _name, _price, _qty, _amountOfPurchase);
            return true;
        }
        else {
            return false;
        }
        
    }


    function getItemByID(bytes32 _itemId)
            contractNotFreezed
            onlyOwner
            public
            view
            returns (string, uint, uint) 
            {
        /*  ●	(10%) (lecture 6) Public constant method to get the price, name and stock about 
            a product by its ID.
        */
        // it is easier to be done by name - so 2 functions by ID and by name
        require (items[_itemId].itemId != 0, "ItemId doesn't exist in the store!");
        return items[_itemId].getItemData();
    }


    function getItemByName(string _name)
            contractNotFreezed
            onlyOwner
            public
            view
            onlyStoreItem(_name)
            returns (string, uint, uint)
            {
        /*  ●	(10%) (lecture 6) Public constant method to get the price, name and stock about 
            a product by its ID.*/
        // it is easier to be done by name - so 2 functions by ID and by name

        return getItemByID(bytes32(keccak256(abi.encodePacked(_name))));
    }


    function getProducts()
            contractNotFreezed
            onlyOwner
            public
            view
            returns (bytes32[])
            {
        /*●	(10%) (lecture 6) Public constant method that returns an array of all product IDs.*/
        return itemIds;
    }

    function getPrice(bytes32 itemId) public view returns (uint) {
        return items[itemId].price ;
    }
    
    function withdraw() 
    /*(5%) (lecture 6) Public method to withdraw the funds from the contract. This should be called 
    only from the contract owner (the address which initially created the contract).*/
            payable 
            public
            contractNotFreezed
            onlyOwner
            returns (bool)
            { //returns (uint)
        require(address(this).balance > 0, "Your balance is 0");
        uint _amount = address(this).balance; // amount and tips
        emit LogRefund("Amount refund to owner, part of amount are tips: ", owner, _amount, tips);  
        tips = 0;
        msg.sender.transfer(_amount); 
        // msg.sender.transfer(address(this).balance);
        return true;       
    }


    /*function destroyContract() onlyOwner {
		assert (msg.sender == owner); 
		emit LogDestroyed("Contract is destroyed: ", owner);
        selfdestruct(owner);
	}*/

 

}




