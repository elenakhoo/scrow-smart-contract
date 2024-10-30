// scripts/generateProducts.js
require("dotenv").config();
const { ethers } = require("hardhat");

// Define contract information
const contractAddress = "0x4A813F566f743A1a5936a1ac5C523E0b2F34F533"; // Replace with your deployed contract address
const contractABI = [
  {
    inputs: [{ internalType: "string", name: "_shippingAddress", type: "string" }],
    name: "setShippingAddress",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function"
  },
  {
    inputs: [{ internalType: "address", name: "_user", type: "address" }],
    name: "getShippingAddress",
    outputs: [{ internalType: "string", name: "", type: "string" }],
    stateMutability: "view",
    type: "function"
  },
  {
    inputs: [{ internalType: "address", name: "_user", type: "address" }],
    name: "hasShippingAddress",
    outputs: [{ internalType: "bool", name: "", type: "bool" }],
    stateMutability: "view",
    type: "function"
  },
  {
    inputs: [
      { internalType: "string", name: "_name", type: "string" },
      { internalType: "uint", name: "_price", type: "uint" },
      { internalType: "string", name: "_description", type: "string" }
    ],
    name: "addProduct",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function"
  },
  {
    inputs: [{ internalType: "address", name: "_seller", type: "address" }],
    name: "getSellerProducts",
    outputs: [
      {
        components: [
          { internalType: "uint", name: "id", type: "uint" },
          { internalType: "string", name: "name", type: "string" },
          { internalType: "uint", name: "price", type: "uint" },
          { internalType: "string", name: "description", type: "string" },
          { internalType: "bool", name: "available", type: "bool" }
        ],
        internalType: "struct UserDatabase.Product[]",
        name: "",
        type: "tuple[]"
      }
    ],
    stateMutability: "view",
    type: "function"
  }
];

// Predefined wallet address
const predefinedWalletAddress = "0xc8381e1791F997e39e8D5293A886f65484e1016F"; // Replace with your wallet address

// Array of product data to add
const products = [
  { name: "Product 1", price: 100, description: "Description of product 1" },
  { name: "Product 2", price: 150, description: "Description of product 2" },
  { name: "Product 3", price: 200, description: "Description of product 3" },
];

async function main() {
  try {
    const providerUrl = process.env.LOCAL_PROVIDER_URL || "http://127.0.0.1:8545";
    const provider = new ethers.JsonRpcProvider(providerUrl);

    if (!process.env.PRIVATE_KEY) {
      throw new Error("Missing PRIVATE_KEY in environment variables.");
    }

    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
    const userDatabase = new ethers.Contract(contractAddress, contractABI, wallet);

    // Add products for the predefined wallet address
    for (const product of products) {
      try {
        console.log(`Adding product: ${product.name}`);
        const tx = await userDatabase.addProduct(product.name, product.price, product.description, {
          gasLimit: 1000000 // Set gasLimit explicitly to avoid errors
        });
        await tx.wait();
        console.log(`Product ${product.name} added successfully.`);
      } catch (addError) {
        console.error(`Error adding product "${product.name}":`, addError.message);
      }
    }

    // Fetch and log the products to confirm
    console.log("Fetching products for the predefined wallet address...");
    try {
      const sellerProducts = await userDatabase.getSellerProducts(predefinedWalletAddress, {
        blockTag: "latest" // Ensure correct block reference
      });
      console.log("Products linked to the predefined wallet address:");
      console.log(sellerProducts);
    } catch (fetchError) {
      console.error("Error fetching seller products:", fetchError.message);
    }
  } catch (error) {
    console.error("Error running script:", error.message);
    console.error(error.stack);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Unexpected error:", error);
    process.exit(1);
  });
