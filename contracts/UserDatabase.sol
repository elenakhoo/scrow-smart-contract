// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

contract UserDatabase {
    // Mapping of wallet addresses to shipping addresses
    mapping(address => string) private shippingAddresses;

    // Struct to represent a product
    struct Product {
        uint id;
        string name;
        uint price;
        string description;
        bool available;
    }

    // Mapping from seller address to their list of products
    mapping(address => Product[]) private sellerProducts;

    // Mapping to track individual product ownership by ID for each seller
    mapping(uint => address) private productOwners;

    // List of all sellers who have added products
    address[] private sellers;

    // Counter for generating unique product IDs
    uint private productIdCounter;

    // Events
    event ShippingAddressUpdated(address indexed user, string shippingAddress);
    event ProductAdded(address indexed seller, uint productId, string productName, uint price);
    event ProductUpdated(address indexed seller, uint productId, bool available);
    event ProductDeleted(address indexed seller, uint productId);

    // Modifier to restrict actions to the owner of a specific product
    modifier onlyProductOwner(uint _productId) {
        require(productOwners[_productId] == msg.sender, "Not authorized to manage this product");
        _;
    }

    // Constructor to set predefined data
    constructor() {
        address predefinedAddress = 0x50E97bB726D7a5f1F34Ef2EEb9F7EB001f741b7B;
        
        // Set predefined shipping address
        shippingAddresses[predefinedAddress] = "123 Blockchain Lane, Crypto City";

        // Add predefined products
        addInitialProduct(predefinedAddress, "Product 1", 0.01 * 10 ** 18, "Description of product 1");
        addInitialProduct(predefinedAddress, "Product 2", 0.02 * 10 ** 18, "Description of product 2");
        addInitialProduct(predefinedAddress, "Product 3", 0.01 * 10 ** 18, "Description of product 3");
        addInitialProduct(predefinedAddress, "Product 4", 0.014 * 10 ** 18, "Description of product 4");
        addInitialProduct(predefinedAddress, "Product 5", 0.005 * 10 ** 18, "Description of product 5");
        addInitialProduct(predefinedAddress, "Product 6", 0.01 * 10 ** 18, "Description of product 6");
    }

    // Internal function to add predefined products during contract initialization
    function addInitialProduct(address seller, string memory name, uint price, string memory description) internal {
        Product memory newProduct = Product({
            id: productIdCounter,
            name: name,
            price: price,
            description: description,
            available: true
        });

        if (sellerProducts[seller].length == 0) {
            sellers.push(seller);
        }

        sellerProducts[seller].push(newProduct);
        productOwners[productIdCounter] = seller;
        emit ProductAdded(seller, productIdCounter, name, price);

        productIdCounter++;
    }

    // Function to set or update a shipping address for the sender's wallet
    function setShippingAddress(string memory _shippingAddress) public {
        shippingAddresses[msg.sender] = _shippingAddress;
        emit ShippingAddressUpdated(msg.sender, _shippingAddress);
    }

    function getShippingAddress(address _user) public view returns (string memory) {
        return shippingAddresses[_user];
    }

    function hasShippingAddress(address _user) public view returns (bool) {
        return bytes(shippingAddresses[_user]).length > 0;
    }

    function addProduct(string memory _name, uint _price, string memory _description) public {
        Product memory newProduct = Product({
            id: productIdCounter,
            name: _name,
            price: _price,
            description: _description,
            available: true
        });

        if (sellerProducts[msg.sender].length == 0) {
            sellers.push(msg.sender);
        }

        sellerProducts[msg.sender].push(newProduct);
        productOwners[productIdCounter] = msg.sender;
        emit ProductAdded(msg.sender, productIdCounter, _name, _price);

        productIdCounter++;
    }

    function getSellerProducts(address _seller) public view returns (Product[] memory) {
        return sellerProducts[_seller];
    }

    function getProductById(uint _productId) public view returns (Product memory) {
        address owner = productOwners[_productId];
        require(owner != address(0), "Product does not exist");

        Product[] storage products = sellerProducts[owner];
        for (uint i = 0; i < products.length; i++) {
            if (products[i].id == _productId) {
                return products[i];
            }
        }
        revert("Product not found");
    }

    function updateProductAvailability(uint _productId, bool _available) public onlyProductOwner(_productId) {
        Product[] storage products = sellerProducts[msg.sender];

        for (uint i = 0; i < products.length; i++) {
            if (products[i].id == _productId) {
                products[i].available = _available;
                emit ProductUpdated(msg.sender, _productId, _available);
                return;
            }
        }
        revert("Product not found");
    }

    function deleteProduct(uint _productId) public onlyProductOwner(_productId) {
        Product[] storage products = sellerProducts[msg.sender];

        for (uint i = 0; i < products.length; i++) {
            if (products[i].id == _productId) {
                products[i] = products[products.length - 1];
                products.pop();

                delete productOwners[_productId];
                emit ProductDeleted(msg.sender, _productId);
                return;
            }
        }
        revert("Product not found");
    }

    function getAllProducts() public view returns (Product[] memory) {
        uint totalProducts = 0;

        for (uint i = 0; i < sellers.length; i++) {
            totalProducts += sellerProducts[sellers[i]].length;
        }

        Product[] memory allProducts = new Product[](totalProducts);
        uint index = 0;

        for (uint i = 0; i < sellers.length; i++) {
            Product[] storage products = sellerProducts[sellers[i]];
            for (uint j = 0; j < products.length; j++) {
                allProducts[index] = products[j];
                index++;
            }
        }

        return allProducts;
    }

    // Struct to represent an individual item in an order
    struct OrderItem {
        uint productId;
        uint quantity;
    }

    // Struct to represent an order with multiple items
    struct Order {
        uint orderId;
        OrderItem[] items; // Array of items in the order
        address buyer;
        uint totalPrice;
        bool isFulfilled;
        bool isAccepted;
    }

    mapping(uint => Order) public orders;
    uint private orderIdCounter;

    event OrderPlaced(uint orderId, address buyer, uint totalPrice);
    event OrderFulfilled(uint orderId);
    event OrderAccepted(uint orderId);
    event OrderDebug(uint indexed orderId, uint productId, uint quantity, uint price, uint totalPrice);

    function placeOrder(OrderItem[] memory _items) public payable {
        uint totalPrice = 0;

        for (uint i = 0; i < _items.length; i++) {
            uint productId = _items[i].productId;
            uint quantity = _items[i].quantity;

            Product memory product = getProductById(productId);
            require(product.available, "Product not available");
            totalPrice += product.price * quantity;

            emit OrderDebug(orderIdCounter, productId, quantity, product.price, totalPrice);
        }

        require(msg.value == totalPrice, "Incorrect payment amount");

        Order storage newOrder = orders[orderIdCounter];
        newOrder.orderId = orderIdCounter;
        newOrder.buyer = msg.sender;
        newOrder.totalPrice = totalPrice;
        newOrder.isFulfilled = false;
        newOrder.isAccepted = false;

        for (uint i = 0; i < _items.length; i++) {
            newOrder.items.push(_items[i]);
        }

        emit OrderPlaced(orderIdCounter, msg.sender, totalPrice);
        orderIdCounter++;
    }


    function fulfillOrder(uint _orderId) public {
        Order storage order = orders[_orderId];
        require(!order.isFulfilled, "Order already fulfilled");

        for (uint i = 0; i < order.items.length; i++) {
            uint productId = order.items[i].productId;
            require(productOwners[productId] == msg.sender, "Not authorized to fulfill this order");
        }

        order.isFulfilled = true;
        emit OrderFulfilled(_orderId);
    }

    function acceptOrder(uint _orderId) public {
        Order storage order = orders[_orderId];
        require(msg.sender == order.buyer, "Only buyer can accept the order");
        require(order.isFulfilled, "Order not fulfilled");
        require(!order.isAccepted, "Order already accepted");

        order.isAccepted = true;

        for (uint i = 0; i < order.items.length; i++) {
            uint productId = order.items[i].productId;
            address seller = productOwners[productId];
            uint itemPrice = getProductById(productId).price * order.items[i].quantity;
            payable(seller).transfer(itemPrice);
        }

        emit OrderAccepted(_orderId);
    }

    function getOrdersBySeller(address _seller) public view returns (Order[] memory) {
        uint count = 0;
        for (uint i = 0; i < orderIdCounter; i++) {
            for (uint j = 0; j < orders[i].items.length; j++) {
                if (productOwners[orders[i].items[j].productId] == _seller) {
                    count++;
                    break;
                }
            }
        }

        Order[] memory sellerOrders = new Order[](count);
        uint index = 0;

        for (uint i = 0; i < orderIdCounter; i++) {
            for (uint j = 0; j < orders[i].items.length; j++) {
                if (productOwners[orders[i].items[j].productId] == _seller) {
                    sellerOrders[index] = orders[i];
                    index++;
                    break;
                }
            }
        }

        return sellerOrders;
    }

    // Function to get all orders made by a specific buyer
    function getOrdersByBuyer(address _buyer) public view returns (Order[] memory) {
        uint count = 0;

        // Count the number of orders for the buyer
        for (uint i = 0; i < orderIdCounter; i++) {
            if (orders[i].buyer == _buyer) {
                count++;
            }
        }

        // Create an array to store the buyer's orders
        Order[] memory buyerOrders = new Order[](count);
        uint index = 0;

        // Populate the array with the buyer's orders
        for (uint i = 0; i < orderIdCounter; i++) {
            if (orders[i].buyer == _buyer) {
                buyerOrders[index] = orders[i];
                index++;
            }
        }

        return buyerOrders;
    }
}
