// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract SupplyChain {
    address owner;
    uint256 skuCount;

    mapping(uint256 => Item) items;
    enum State {UnInitialized, ForSale, Sold, Shipped, Received}

    struct Item {
        string name;
        uint256 sku;
        uint256 price;
        State state;
        address payable seller;
        address payable buyer;
    }

    event LogForSale(uint256 sku);
    event LogSold(uint256 sku);
    event LogShipped(uint256 sku);
    event LogReceived(uint256 sku);

    /* Create a modifer that checks if the msg.sender is the owner of the contract */
    modifier verifyCaller(address _address) {
        require(msg.sender == _address);
        _;
    }
    modifier paidEnough(uint256 _price) {
        require(msg.value >= _price);
        _;
    }
    modifier checkValue(uint256 _sku) {
        _;
        uint256 _price = items[_sku].price;
        uint256 amountToRefund = msg.value - _price;
        items[_sku].buyer.transfer(amountToRefund);
    }

    modifier forSale(uint256 _sku) {
        require(items[_sku].state == State.ForSale, "Item is not for sale");
        _;
    }
    modifier sold(uint256 _sku) {
        require(items[_sku].state == State.Sold, "Item is not sold");
        _;
    }
    modifier shipped(uint256 _sku) {
        require(items[_sku].state == State.Shipped, "Item is not shipped");
        _;
    }
    modifier received(uint256 _sku) {
        require(items[_sku].state == State.Received, "Item is not received");
        _;
    }

    constructor() public {
        owner = msg.sender;
        skuCount = 0;
    }

    function addItem(string memory _name, uint256 _price)
        public
        returns (bool)
    {
        emit LogForSale(skuCount);
        items[skuCount] = Item({
            name: _name,
            sku: skuCount,
            price: _price,
            state: State.ForSale,
            seller: msg.sender,
            buyer: address(0)
        });
        skuCount = skuCount + 1;
        return true;
    }

    function buyItem(uint256 sku)
        public
        payable
        forSale(sku)
        paidEnough(items[sku].price)
        checkValue(sku)
    {
        items[sku].buyer = msg.sender;
        items[sku].state = State.Sold;

        address payable seller = items[sku].seller;
        uint256 price = items[sku].price;
        seller.transfer(price);

        emit LogSold(sku);
    }

    function shipItem(uint256 sku)
        public
        sold(sku)
        verifyCaller(items[sku].seller)
    {
        items[sku].state = State.Shipped;
        emit LogShipped(sku);
    }

    function receiveItem(uint256 sku)
        public
        shipped(sku)
        verifyCaller(items[sku].buyer)
    {
        items[sku].state = State.Received;
        emit LogReceived(sku);
    }

    /* We have these functions completed so we can run tests, just ignore it :) */
    function fetchItem(uint256 _sku)
        public
        view
        returns (
            string memory name,
            uint256 sku,
            uint256 price,
            uint256 state,
            address seller,
            address buyer
        )
    {
        name = items[_sku].name;
        sku = items[_sku].sku;
        price = items[_sku].price;
        state = uint256(items[_sku].state);
        seller = items[_sku].seller;
        buyer = items[_sku].buyer;
        return (name, sku, price, state, seller, buyer);
    }
}
