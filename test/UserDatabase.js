const { expect } = require("chai");

describe("UserDatabase", function () {
  let UserDatabase;
  let userDatabase;
  let owner;
  let addr1;

  beforeEach(async function () {
    // Get the ContractFactory and Signers
    UserDatabase = await ethers.getContractFactory("UserDatabase");
    [owner, addr1] = await ethers.getSigners();

    // Deploy the contract (no need for userDatabase.deployed() in ethers v6)
    userDatabase = await UserDatabase.deploy();
  });

  it("should allow the owner to set and retrieve their shipping address", async function () {
    // Set the shipping address for the owner
    const shippingAddress = "123 Ethereum St.";
    await userDatabase.setShippingAddress(shippingAddress);

    // Check that the shipping address is correctly stored
    expect(await userDatabase.getShippingAddress(owner.address)).to.equal(shippingAddress);
  });

  it("should return true for hasShippingAddress if a shipping address is set", async function () {
    // Set the shipping address for the owner
    const shippingAddress = "123 Ethereum St.";
    await userDatabase.setShippingAddress(shippingAddress);

    // Check if the owner has a shipping address
    expect(await userDatabase.hasShippingAddress(owner.address)).to.be.true;
  });

  it("should return false for hasShippingAddress if no shipping address is set", async function () {
    // Check if addr1 has a shipping address (which it shouldn't at this point)
    expect(await userDatabase.hasShippingAddress(addr1.address)).to.be.false;
  });
});
