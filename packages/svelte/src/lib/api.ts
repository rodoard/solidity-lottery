import { hexToString, stringToHex, type Address } from "viem";

const baseURL = "http://localhost:3001/api"

function apiUrl({ path, params = {} }:{path:string, params?:Object}) {
  const url = new URL(`${baseURL}${path}`);
  const searchParams = new URLSearchParams();
  for (const [key, value] of Object.entries(params)) {
    searchParams.append(key, value);
  }
  url.search = searchParams.toString();
  return url.toString();  
}

const domain = {
name: "MyToken", // Match your token name
version: "1",
chainId: 1, // Replace with your network's chain ID (e.g., 1 for mainnet, 5 for Goerli)
verifyingContract: "0xYourTokenAddress",
};

const types = {
Permit: [
  { name: "owner", type: "address" },
  { name: "spender", type: "address" },
  { name: "value", type: "uint256" },
  { name: "nonce", type: "uint256" },
  { name: "deadline", type: "uint256" },
],
};

const permit = {
  types,
  domain 
}
export {
  permit 
}

export type LotteryInfo = {
  betsOpen: boolean,
  isOwner: boolean,
  tokenName:string,
  nonce:number,
  tokenAddress:Address,
  prizeAmount: number,
  prizePool: number,
  betsClosingTime: number,
  maxBets:number,
  ownerPool: number,
  currentTimeStamp:number,
    isWinner:boolean,
    isLotteryClosed:boolean,
    betPrice:number,
    tokenSymbol:string,
    betFee:number,
    tokenBalance:number,
    isPastLotteryClosingTime:boolean,
  ownerFeePool: number,
    purchaseRatio:number
}
