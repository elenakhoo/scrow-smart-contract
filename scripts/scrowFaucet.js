const { ethers } = require("ethers");

async function main() {
  
    const [deployer] = await hre.ethers.getSigners();  // Get the deployer signer
  
    console.log("Sending funds to deployer:", deployer.address);
    // Sending 1 ETH from the deployer's account to a target address
    const tx = await deployer.sendTransaction({
      to: "0x50E97bB726D7a5f1F34Ef2EEb9F7EB001f741b7B", // Replace with your target address
      value: hre.ethers.parseEther("126.0")  // Send 1 ETH (adjust as needed)
    });
  
    console.log("Transaction hash:", tx.hash);
  
    // Wait for the transaction to be mined
    await tx.wait();
  
    console.log("Transaction mined.");

    console.log("Sending funds to deployer:", deployer.address);
    // Sending 1 ETH from the deployer's account to a target address
    const tx1 = await deployer.sendTransaction({
      to: "0xc8381e1791F997e39e8D5293A886f65484e1016F", // Replace with your target address
      value: hre.ethers.parseEther("86.0")  // Send 1 ETH (adjust as needed)
    });
  
    console.log("Transaction hash:", tx1.hash);
  
    // Wait for the transaction to be mined
    await tx1.wait();
  
    console.log("Transaction mined.");
  }
  
  main().catch((error) => {
    console.error("Error in the faucet script:", error);
    process.exitCode = 1;
  });
  
