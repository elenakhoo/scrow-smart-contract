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
        string imageUrl;
        bool available;
        string sellerId;
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
        string memory predefinedAddressString = "0x50E97bB726D7a5f1F34Ef2EEb9F7EB001f741b7B";

        address predefinedAddress1 = 0x6B540D57df2AdF572647cdE4D021359387B5809c;
        string memory predefinedAddress1String = "0x6B540D57df2AdF572647cdE4D021359387B5809c";
        
        // Set predefined shipping address
        shippingAddresses[predefinedAddress] = "123 Blockchain Lane, Crypto City";
        shippingAddresses[predefinedAddress1] = "133 Whale Lane, Crypto City";

        // Add predefined products
        addInitialProduct(predefinedAddress, predefinedAddressString, "Wireless Earbuds", 0.015 * 10 ** 18, "High fidelity audio earbuds with noise cancellation.", "https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/MUVY3?wid=1144&hei=1144&fmt=jpeg&qlt=90&.v=1713296133256");
        addInitialProduct(predefinedAddress, predefinedAddressString, "Smartphone Stand", 0.005 * 10 ** 18, "Adjustable stand for hands-free smartphone use.", "https://www.ikea.com/my/en/images/products/bergenes-holder-for-mobile-phone-tablet-bamboo__0948313_pe798953_s5.jpg?f=s");
        addInitialProduct(predefinedAddress, predefinedAddressString, "Portable Charger", 0.018 * 10 ** 18, "High capacity portable charger with 10000mAh.", "https://thelandmarkmusic.com/cdn/shop/files/PB436_blue_01.png?v=1684934651&width=1000");
        addInitialProduct(predefinedAddress, predefinedAddressString, "Bluetooth Speaker", 0.02 * 10 ** 18, "360-degree sound Bluetooth speaker, waterproof.", "https://images-cdn.ubuy.co.in/64f8fabde01bf74c341c95f7-portable-bluetooth-speaker-wireless.jpg");
        addInitialProduct(predefinedAddress, predefinedAddressString, "LED Desk Lamp", 0.012 * 10 ** 18, "Energy-efficient LED desk lamp with USB port.", "https://ergoworks.com.my/cdn/shop/files/EW-DE268811-BK-Main-Image-1_0350e2d9-f5b9-43ed-8881-5828128b5d26.jpg?v=1727780491&width=2048");
        addInitialProduct(predefinedAddress, predefinedAddressString, "USB-C Cable", 0.006 * 10 ** 18, "Durable 1-meter USB-C to USB-A cable.", "https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/HQZQ2?wid=2738&hei=2266&fmt=jpeg&qlt=95&.v=1693504246821");
        addInitialProduct(predefinedAddress, predefinedAddressString, "Laptop Stand", 0.013 * 10 ** 18, "Ergonomic laptop stand for better posture.", "https://media.wired.com/photos/65bd18df54e4c9ce4a1be572/master/w_320%2Cc_limit/Gear-Branch-laptop-stand-SOURCE-Branch.jpg");
        addInitialProduct(predefinedAddress, predefinedAddressString, "Smart Plug", 0.017 * 10 ** 18, "WiFi-enabled smart plug with remote control.", "https://down-my.img.susercontent.com/file/sg-11134201-7rcey-lqyj55ifpyw966");
        addInitialProduct(predefinedAddress, predefinedAddressString, "Fitness Tracker", 0.02 * 10 ** 18, "Tracks heart rate, sleep patterns, and calories.", "https://www.garmin.com.my/m/my/g/products/intosports/vivosmart-5.jpg");
        addInitialProduct(predefinedAddress, predefinedAddressString, "Wireless Mouse", 0.009 * 10 ** 18, "Lightweight wireless mouse with adjustable DPI.", "https://mecha.com.my/cdn/shop/files/Keychron-M1-Wireless-Mouse-Black_1800x1800_d7ce4c6d-d5d5-457f-9311-272b6c887d49_535x.webp?v=1696841298");
        addInitialProduct(predefinedAddress, predefinedAddressString, "Gaming Keyboard", 0.019 * 10 ** 18, "RGB backlit mechanical gaming keyboard.", "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSPFnSJyadrSlsyvP118g-6aAMSyf-HRjgJ4A&s");
        addInitialProduct(predefinedAddress, predefinedAddressString, "Smart Thermostat", 0.018 * 10 ** 18, "Learns your preferences and saves energy.", "https://images-cdn.ubuy.co.in/64c9e4d0f2dc1748f43fb5f5-google-nest-learning-thermostat-3rd.jpg");
        addInitialProduct(predefinedAddress, predefinedAddressString, "Noise Cancelling Headphones", 0.02 * 10 ** 18, "Immersive headphones with noise cancellation.", "https://www.sony.com.my/image/5d02da5df552836db894cead8a68f5f3?fmt=pjpeg&wid=330&bgcolor=FFFFFF&bgc=FFFFFF");
        addInitialProduct(predefinedAddress, predefinedAddressString, "HD Webcam", 0.014 * 10 ** 18, "1080p HD webcam with built-in microphone.", "https://www.itworld.com.my/image/cache/catalog/Images/Accessories/CAMLOGIC270HDW-T1-1000x1000.jpg");
        addInitialProduct(predefinedAddress, predefinedAddressString, "Digital Photo Frame", 0.0175 * 10 ** 18, "WiFi photo frame for sharing memories.", "https://images.philips.com/is/image/philipsconsumer/a8b7ab25251c4cf6b3cdb0bd009b36b1?$pnglarge$&wid=960");
        addInitialProduct(predefinedAddress1, predefinedAddress1String, "Smart Speaker", 0.02 * 10 ** 18, "Compact smart speaker with voice assistant.", "https://switchconcept.com.my/wp-content/uploads/2021/03/Mi-Smart-Speaker.jpg");
        addInitialProduct(predefinedAddress1, predefinedAddress1String, "Portable Projector", 0.0195 * 10 ** 18, "Mini projector with HDMI and USB support.", "https://www.lumosprojector.my/cdn/shop/products/ATOMthumbnailpicture_737x.png?v=1651034363");
        addInitialProduct(predefinedAddress1, predefinedAddress1String, "Electric Toothbrush", 0.0125 * 10 ** 18, "Rechargeable electric toothbrush with timer.", "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQRaOJX02g54DzSBS6TnaPNWg45EXbVyCYASA&s");
        addInitialProduct(predefinedAddress1, predefinedAddress1String, "Security Camera", 0.018 * 10 ** 18, "Outdoor security camera with night vision.", "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSG5fAp_9g2DuO-JpOmPpOJRQ5XoGPKrQT19w&s");
        addInitialProduct(predefinedAddress1, predefinedAddress1String, "UV Sanitizer Box", 0.0155 * 10 ** 18, "Sanitizes items with UV light technology.", "https://m.media-amazon.com/images/I/519tCdmehIL._SL1000_.jpg");
        addInitialProduct(predefinedAddress1, predefinedAddress1String, "Smart Doorbell", 0.02 * 10 ** 18, "Video doorbell with motion detection.", "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTW3XTEH8H8zbtE52lQSF3qAFxkNZLyOrJsfw&s");
        addInitialProduct(predefinedAddress1, predefinedAddress1String, "Robot Vacuum", 0.018 * 10 ** 18, "Automatic robot vacuum cleaner with app control.", "https://my.iliferobot.com/u_file/photo/20240319/5ac2ea2f41.jpg");
        addInitialProduct(predefinedAddress1, predefinedAddress1String, "Smart Light Bulb", 0.007 * 10 ** 18, "Customizable color and dimming features.", "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSfsBon153ynpc3ZyRwdg6MNspuaIyio-CFnQ&s");
        addInitialProduct(predefinedAddress1, predefinedAddress1String, "Electric Kettle", 0.013 * 10 ** 18, "Temperature control electric kettle.", "https://images.philips.com/is/image/philipsconsumer/vrs_07fe124b57416ffee514dc0e8e530ad5ab7f7c5d?$pnglarge$&wid=960");
        addInitialProduct(predefinedAddress1, predefinedAddress1String, "Wireless Charger", 0.011 * 10 ** 18, "Slim wireless charging pad for smartphones.", "https://www.ikea.com/my/en/images/products/livboj-wireless-charger-white__0721950_pe733427_s5.jpg?f=s");
        addInitialProduct(predefinedAddress1, predefinedAddress1String, "Air Purifier", 0.02 * 10 ** 18, "HEPA air purifier for cleaner air.", "https://eoleaf.com/cdn/shop/files/AEROPRO40-ENV4.jpg?v=1703077777&width=533");
        addInitialProduct(predefinedAddress1, predefinedAddress1String, "Mini Fridge", 0.019 * 10 ** 18, "Compact mini fridge for beverages and snacks.", "https://shop.tbm.com.my/cdn/shop/files/midea-mini-bar-fridge-mdrd86fgg-tbm-online-592938.jpg?v=1714969061&width=720");
        addInitialProduct(predefinedAddress1, predefinedAddress1String, "Infrared Thermometer", 0.006 * 10 ** 18, "Non-contact thermometer for quick readings.", "https://cetmestore.com.my/wp-content/uploads/2022/06/Untitled-design-2022-06-21T154644.361.png");
        addInitialProduct(predefinedAddress1, predefinedAddress1String, "Smartwatch", 0.02 * 10 ** 18, "Tracks fitness, notifications, and heart rate.", "https://i5.walmartimages.com/asr/2c1c2ccc-39a1-4aec-9430-5d1d934eb465.c315ee059f382bc635a801d8a5cb4325.jpeg");

    }

    // Internal function to add predefined products during contract initialization
    function addInitialProduct(address seller, string memory sellerId, string memory name, uint price, string memory description, string memory imageUrl) internal {
        Product memory newProduct = Product({
            id: productIdCounter,
            name: name,
            price: price,
            description: description,
            imageUrl: imageUrl,
            available: true,
            sellerId: sellerId
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

    function addProduct(address seller, string memory sellerId, string memory _name, uint _price, string memory _description, string memory _imageUrl) public {
        Product memory newProduct = Product({
            id: productIdCounter,
            name: _name,
            price: _price,
            description: _description,
            imageUrl: _imageUrl,
            available: true,
            sellerId: sellerId
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
        string name;       // New field to store the product name
        string imageUrl;   // New field to store the product image URL
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

    // Modified placeOrder function to include name and imageUrl in OrderItem
    function placeOrder(OrderItem[] memory _items) public payable {
        uint totalPrice = 0;

        Order storage newOrder = orders[orderIdCounter];
        newOrder.orderId = orderIdCounter;
        newOrder.buyer = msg.sender;
        newOrder.totalPrice = totalPrice;
        newOrder.isFulfilled = false;
        newOrder.isAccepted = false;

        for (uint i = 0; i < _items.length; i++) {
            uint productId = _items[i].productId;
            uint quantity = _items[i].quantity;

            Product memory product = getProductById(productId);
            require(product.available, "Product not available");
            totalPrice += product.price * quantity;

            // Add OrderItem with product's name and imageUrl
            newOrder.items.push(OrderItem({
                productId: productId,
                quantity: quantity,
                name: product.name,
                imageUrl: product.imageUrl
            }));
        }

        require(msg.value == totalPrice, "Incorrect payment amount");

        newOrder.totalPrice = totalPrice;
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
