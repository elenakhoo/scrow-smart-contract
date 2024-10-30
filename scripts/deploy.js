async function main() {
  // Fetch the contract factory
  const UserDatabase = await ethers.getContractFactory("UserDatabase");

  // Deploy the contract
  const userDatabase = await UserDatabase.deploy();

  console.log("Transaction mined. Contract deployed to:", userDatabase.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error during deployment:", error);
    process.exit(1);
  });
