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
        addInitialProduct(predefinedAddress, "Product 1", 100, "Description of product 1");
        addInitialProduct(predefinedAddress, "Product 2", 150, "Description of product 2");
        addInitialProduct(predefinedAddress, "Product 3", 200, "Description of product 3");
        addInitialProduct(predefinedAddress, "Product 4", 100, "Description of product 4");
        addInitialProduct(predefinedAddress, "Product 5", 150, "Description of product 5");
        addInitialProduct(predefinedAddress, "Product 6", 200, "Description of product 6");
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
            sellers.push(seller); // Add to sellers list if it's the first product for the seller
        }

        sellerProducts[seller].push(newProduct);
        productOwners[productIdCounter] = seller; // Set ownership of the product
        emit ProductAdded(seller, productIdCounter, name, price);

        productIdCounter++; // Increment the product ID counter for the next product
    }

    // Other functions remain unchanged

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
}
