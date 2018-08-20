var Marketplace = artifacts.require("Marketplace");
var expectThrow = require('./utils.js').expectThrow;

contract('Marketplace', function(accounts) {

    let market;

    const _owner = accounts[0];
    const _notOwner = accounts[1];
    const _buyer = accounts[2];

    const itemName1 = "shirt";
    const itemPrice1 = 250;
    const qtyInStore1 = 2000;
    const qty2Buy1 = 100;
    const itemName2 = "skirt";
    const itemPrice2 = 350;
    const qtyInStore2 = 1000;
    const qty2Buy2 = 200;
    const qty2Buy2_2 = 350;
    let itemPrice2_2;
    let qtyInStore2_2;
    const itemPrice2_3 = 320;
    const qtyInStore2_3 = 1000;

    // adding new item
    describe("Adding new items", () => {
        beforeEach(async() => {
            market = await Marketplace.new();
        });

        it("Sets an owner", async() => {
            assert.equal(await market.owner.call(), _owner);
        });

        it("Should add two new items correctly: " + itemName1 + ", " + itemName2, async function() {
            let obj1 = await market.newProduct(itemName1, itemPrice1, qtyInStore1);
            assert(obj1.receipt.status == 1, "First item - " + itemName1 + " is not added correctly");
            //assert(obj1.receipt.status == 1, "First item is not added correctly, " + "itemId1 = " + itemId1 + ", obj1 = " + obj1);

            let obj2 = await market.newProduct(itemName2, itemPrice2, qtyInStore2);
            assert(obj2.receipt.status == 1, "Second item - " + itemName2 + " is not added correctly");
        })

    });


    describe("Buying an existing item - " + itemName1, () => {
        beforeEach(async function() {
            market = await Marketplace.deployed({
                from: _owner
            });
            // to add items in this market instance so may test further:
            await market.newProduct(itemName1, itemPrice1, qtyInStore1);
            await market.newProduct(itemName2, itemPrice2, qtyInStore2);
        })

        it("Should be possible to buy items by Buyer", async function() {
            await market.buy(itemName1, qty2Buy1, {
                value: qty2Buy1 * itemPrice1 + 100, // tips
                from: _buyer
            })
        })
    });


    describe("Buying items by anyone", () => {
        it("Should be possible to buy items by Owner", async function() {
            await market.buy(itemName2, qty2Buy2, {
                value: qty2Buy2 * itemPrice2 + 200 // tips
            })
        })
    })


    describe("Checking items in Store", () => {
        it("Should remain correct quantity of first item - " + itemName1, async function() {
            let items = await market.getProducts.call();
            let item1ID = items[0];

            // to check getItemByID
            let itemObj = await market.getItemByID(item1ID);
            let test1 = qtyInStore1 - qty2Buy1;
            //let test2 = qty2Buy1 * itemPrice1 + 100; // tips = 100
            assert(itemObj[2].eq(qtyInStore1 - qty2Buy1), "Remained incorrect quantity of shirts" + ", qty in Store = " + test1);
            //  + ", amount+tips = " + test2 + ", itemObj[0] = " + itemObj[0] + ",itemObj[1] = " + itemObj[1] + ",itemObj[2] = " + itemObj[2]

        })

        it("Should get data about added and bought items correctly", async function() {
            //to check getItemByName()
            let itemObj1 = await market.getItemByName(itemName1);

            // first item
            assert(itemObj1[1].eq(itemPrice1), "Incorrect price of " + itemName1);
            assert(itemObj1[2].eq(qtyInStore1 - qty2Buy1), "Incorrect quantity in Store - " + itemName1);
        })

    })


    describe("Check corrected price", () => {
        it("Should get changed price of " + itemName2 + " correctly", async function() {
            let items = await market.getProducts.call();
            let item2ID = items[1];
            let itemObj2 = await market.getItemByID(item2ID);

            // check getPrice()
            itemPrice2_2 = await market.getPrice(item2ID);
            // second item:
            assert(itemObj2[1].eq(itemPrice2_2), "The price of " + itemName2 +
                " is not correctly changed. It should be " + itemPrice2_2 + ", but it is set as " + itemObj2[1]);
            assert(itemObj2[2].eq(qtyInStore2 - qty2Buy2), "Incorrect quantity in Store - " + itemName2);
        })

        // to buy item 2 again 
        it("Should be possible to buy items by not owner", async function() {
            await market.buy(itemName2, qty2Buy2_2, { // qty2Buy2_2 350, qtyInStore 800
                value: qty2Buy2_2 * itemPrice2_2 + 300, // price 364, tips
                from: _notOwner
            })
        })
    })


    //updating items
    describe("Check prices changing and update of second item: " + itemName2, () => {
        it("Should change the price correctly - new test with second item: " + itemName2, async function() {
            let items = await market.getProducts.call();
            let item2ID = items[1];
            let itemObj2 = await market.getItemByID(item2ID);
            qtyInStore2_2 = qtyInStore2 - qty2Buy2 - qty2Buy2_2;
            let newCalculatedPrice = await market.getPrice(item2ID);

            // second item again:
            assert(itemObj2[1].eq(newCalculatedPrice), "The price of " + itemName2 + ", qty in Store: " + qtyInStore2_2 +
                " is not correctly changed. It should be " + newCalculatedPrice + ", but it is set as " + itemObj2[1]);

        })

        it("Should update the price and quantity of second item correctly", async function() {
            // let update the second item - new supply itemPrice2_3 = 320, qtyInStore2_3 = 1000
            await market.update(itemName2, itemPrice2_3, qtyInStore2_3, {
                from: _owner
            })
        })
    })


    describe("Check updated item " + itemName2, () => {
        //qtyInStore2_2 = qtyInStore2 - qty2Buy2 - qty2Buy2_2; = 450
        //let newQty = qtyInStore2_2 + qtyInStore2_3; = 1450
        it("Should has new updated price: " + itemPrice2_3, async function() {
            let itemObj2 = await market.getItemByName(itemName2);
            assert(itemObj2[1].eq(itemPrice2_3), "The price is not updated correctly");
            assert(itemObj2[2].eq(1450), "The quantity is not updated correctly. It should be " + itemObj2[2]);
        })

    })


    describe("Check against adding first item twice", () => {
        it("Should not add an existing item twice", async function() {
            await expectThrow(market.newProduct(itemName1, itemPrice1, qtyInStore1)); // should throw exception
        });
    })


    describe("Check Withdraw function", () => {
        it("Should not allow transferring money to not Owner", async function() {
            await expectThrow(market.withdraw({ from: _buyer }));
        });

        it("Should transfer all balance in Owner account", async function() {
            // withdraw money
            let receiptWithdraw = await market.withdraw.call({ from: _owner });
            assert(receiptWithdraw == true, 'Money are not transferred. Value of receiptWithdraw is ' + receiptWithdraw);
        });

    })

})