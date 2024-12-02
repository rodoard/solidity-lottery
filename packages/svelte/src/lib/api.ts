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

export async function getTokenBalance(
  {  address }: {  address: Address }
):Promise<Number> {
  const response = await fetch(apiUrl({
    path: `/token-balance/${address}`,
  })).then((response) => {
    return response.json()
  }) 
  return Number(response.result);
}


export async function getVotingPower(
  {  address }: {  address: Address }
):Promise<Number> {
  const response = await fetch(apiUrl({
    path: `/voting-power/${address}`,
  })).then((response) => {
    return response.json()
  }) 
  return Number(response.result);
}


export async function getUserInfo(
  {  address }: {  address: Address }
):Promise<Number> {
  const response = await fetch(apiUrl({
    path: `/voting-power/${address}`,
  })).then((response) => {
    return response.json()
  }) 
  return Number(response.result);
}

export type LotteryInfo = {
  betsOen: boolean,
  isOwner: boolean,
  prizeAmount: number,
  prizePool: number,
  betsClosingTime: number,
  ownerPool: number,
    isWinner:boolean,
    isLotteryClosed:boolean,
    betPrice:number,
    tokenSymbol:string,
    betFee:number,
    tokenBalance:number,
    isPastLotteryClosingTime:boolean,
    ownerFeePool:number,
}

export async function getLotteryContractInfo(
  {  address, lotteryAddress }: {  address: Address, lotteryAddress:Address }
):Promise<LotteryInfo> {
  const response = await fetch(apiUrl({
    path: `/lottery/${lotteryAddress}/${address}`,
  })).then((response) => {
    return response.json()
  }) 
  return response.result;
}

type LotteryClose = {
  betsOpen: boolean,
  isLotteryClosed:boolean, 
  betsClosingTime:number, 
  isPastLotteryClosingTime: boolean,
  prizePool: number,
  prizeAmount:number
}
export async function lotteryClose(
  { signature, lotteryAddress, address }:
    { signature:string, address: Address, lotteryAddress: Address }
): Promise<LotteryClose> {
  const body = {
    signature,
    address
  }
  const response = await fetch(
  apiUrl({ path: `/lottery/${lotteryAddress}/close` }),
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body)
    }
  ).then((response) => {
    return response.json()
  }) 
  return response.result;
}

type LotteryStart = {
  betsOpen: boolean,
  isLotteryClosed:boolean, 
  betsClosingTime:number, 
  isPastLotteryClosingTime: boolean,
  prizePool: number,
  prizeAmount:number
}

export async function lotteryStart(
  { signature, lotteryAddress, address, closingTime }:
    { signature:string, address: Address, lotteryAddress: Address, closingTime: Date }
): Promise<LotteryStart> {
  const body = {
    closingTime:closingTime.valueOf(),
    signature,
    address
  }
  const response = await fetch(
  apiUrl({ path: `/lottery/${lotteryAddress}/start` }),
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body)
    }
  ).then((response) => {
    return response.json()
  }) 
  return response.result;
}

type OwnerWithdraw = {
  tokenBalance: number,
  ownerFeePool: number,
  ethReceived:number
}
export async function ownerWithdrawFees(
  { signature, lotteryAddress, address, amount }:
    { signature:string, address: Address, lotteryAddress: Address, amount:number }
): Promise<OwnerWithdraw> {
  const body = {
    amount,
    signature,
    address
  }
  const response = await fetch(
  apiUrl({ path: `/owner/${address}/withdraw` }),
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body)
    }
  ).then((response) => {
    return response.json()
  }) 
  return response.result;
}

type PlayerWithdrawPrize = {
  tokenBalance: number,
  prizeAmount:number 
}
export async function playerWithdrawPrize(
  { signature, lotteryAddress, address, amount }:
    { signature:string, address: Address, lotteryAddress: Address, amount:number }
): Promise<PlayerWithdrawPrize> {
  const body = {
    amount,
    signature,
    address
  }
  const response = await fetch(
  apiUrl({ path: `/player/${address}/withdraw` }),
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body)
    }
  ).then((response) => {
    return response.json()
  }) 
  return response.result;
}

type PlayerReturnTokens = {
  tokenBalance: number,
  ethReceived:number
}
export async function playerReturnTokens(
  { signature, lotteryAddress, address, amount }:
    { signature:string, address: Address, lotteryAddress: Address, amount:number }
): Promise<PlayerReturnTokens> {
  const body = {
    amount,
    signature,
    address
  }
  const response = await fetch(
  apiUrl({ path: `/player/${address}/return-tokens` }),
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body)
    }
  ).then((response) => {
    return response.json()
  }) 
  return response.result;
}
