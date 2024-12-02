import { Address, Hex } from "viem";
import { signTypedData } from "viem/accounts";
import { hardhat, sepolia } from "viem/chains";

type Params = {
  privateKey: Hex,
  contractName:string, contractAddress:`0x${string}`,
  delegatee:Address, nonce:any, expiry:any, chain:any
}
  
async function getSignature({
  contractName, contractAddress,
  delegatee, nonce, expiry,
  privateKey,
  chain
  }:Params
) {
  // Define the EIP-712 domain and types for `delegateBySig`
  const domain = {
    name: contractName,
    version: "1",
    chainId: chain.id,
    verifyingContract: contractAddress,
  };

  const types = {
    Delegation: [
      { name: "delegatee", type: "address" },
      { name: "nonce", type: "uint256" },
      { name: "expiry", type: "uint256" },
    ],
  };

  const message = {
    delegatee,
    nonce,
    expiry,
  };

  // Sign EIP-712 data using Viem's `signTypedData`
  const signature = await signTypedData({
    privateKey, // Use the private key directly in the script
    domain,
    types,
    primaryType: "Delegation",
    message,
  });
  return {
    signature
  }
}

export {
  getSignature
}