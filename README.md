# UserDatabase Smart Contract

The **UserDatabase** smart contract is an Ethereum-based decentralized database for managing user shipping addresses and product listings. The contract allows users to set shipping addresses, add products to a marketplace, and retrieve available products. It includes predefined data (a shipping address and a set of products) for a specific wallet address.

## Features

1. **Shipping Address Management**
   - Allows users to set or update their shipping address.
   - Allows viewing and checking if a user has set a shipping address.

2. **Product Management**
   - Users can add products with details such as name, price, and description.
   - Only the product owner (user who added it) can update availability or delete a product.
   - The contract keeps track of all products linked to individual sellers.
   - Includes predefined products for an initial seller.

3. **Retrieving Products**
   - Retrieve all products listed by a specific seller.
   - Retrieve details of a specific product by its ID.
   - Retrieve all products across all sellers.

## Contract Details

- **Solidity Version:** 0.8.27
- **License:** UNLICENSED

## Contract Structure

### State Variables

- `shippingAddresses`: Maps user addresses to shipping addresses.
- `Product`: Struct defining a product with an ID, name, price, description, and availability.
- `sellerProducts`: Maps seller addresses to their products.
- `productOwners`: Tracks product ownership by ID.
- `sellers`: List of all sellers with products.
- `productIdCounter`: Counter for unique product IDs.

### Constructor

The contract's constructor initializes:
- A predefined shipping address for `0x50E97bB726D7a5f1F34Ef2EEb9F7EB001f741b7B`.
- Six predefined products for the same address, each with unique details.

### Functions

1. **Shipping Address Functions**
   - `setShippingAddress(string memory _shippingAddress)`: Set or update the shipping address for the caller.
   - `getShippingAddress(address _user) public view returns (string memory)`: Retrieve the shipping address of a user.
   - `hasShippingAddress(address _user) public view returns (bool)`: Check if a user has set a shipping address.

2. **Product Functions**
   - `addProduct(string memory _name, uint _price, string memory _description)`: Add a new product for the caller.
   - `getSellerProducts(address _seller) public view returns (Product[] memory)`: Get all products for a specified seller.
   - `getProductById(uint _productId) public view returns (Product memory)`: Retrieve details of a product by its ID.
   - `updateProductAvailability(uint _productId, bool _available)`: Update the availability status of a product (only the owner can call this).
   - `deleteProduct(uint _productId)`: Delete a product (only the owner can call this).
   - `getAllProducts() public view returns (Product[] memory)`: Retrieve all products across all sellers.

### Events

- `ShippingAddressUpdated`: Triggered when a user updates their shipping address.
- `ProductAdded`: Triggered when a product is added by a seller.
- `ProductUpdated`: Triggered when a product's availability is updated.
- `ProductDeleted`: Triggered when a product is deleted.

### Modifiers

- `onlyProductOwner(uint _productId)`: Restricts access to functions that can only be called by the product's owner.

## Deployment

The contract can be deployed on Ethereum testnets or the mainnet using tools such as Remix or Hardhat.

### Example

For initial deployment, the contract's constructor will automatically set a predefined shipping address and add six predefined products for a wallet address.

---

## Usage

1. **Set Shipping Address**
   - Call `setShippingAddress` with your desired shipping address.

2. **Add Product**
   - Use `addProduct` to add a new product with name, price, and description.

3. **Retrieve Products**
   - Use `getAllProducts` to retrieve all products across all sellers or `getSellerProducts` to get products from a specific seller.

4. **Update or Delete Product**
   - Use `updateProductAvailability` to set availability or `deleteProduct` to remove the product, available only to the product owner.

## License

This project is unlicensed.
