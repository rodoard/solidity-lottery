import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Address, createPublicClient, createWalletClient, formatEther, http, parseEther, parseUnits } from "viem"
import { privateKeyToAccount } from 'viem/accounts';
import { hardhat, sepolia } from "viem/chains"
import {parseSignature, getContract} from "viem"
import {lotteryJSON } from './contracts';
import { getSignature } from './delegate';
import { parseBigInt } from './util';

const MINT_VALUE = parseEther("10")
const TOKENIZED_VOTE_CONTRACT_NAME = "TokenizedVote"
const CHAINS = {
  hardhat, 
  sepolia
}

@Injectable()
export class AppService {
  async closeLottery({ lotteryAddress, address}: { lotteryAddress: Address; address: Address; }) {
    const contract:any = await getContract(({
      address:lotteryAddress,
      abi: lotteryJSON.abi,
      client: this.walletClient,
    }));

    return this.waitForTransactionReceipt(
      await contract.write.closeLottery()
    )
  }

  async startLottery({  lotteryAddress, address, closingTime}: { signature:string, lotteryAddress:Address; address: Address; closingTime: number; }) {
    const contract:any = await getContract(({
      address:lotteryAddress,
      abi: lotteryJSON.abi,
      client: this.walletClient,
    }));

   return this.waitForTransactionReceipt(
     await contract.write.startLottery([closingTime, address], {
        account:address
      })
    )
  }
   
  async verifySignature({ message, address, signature }: {message:string, address:Address, signature:string}) {
    const valid = await this.publicClient.verifyMessage({
      address: address,
      message,
      signature,
    })   
    if (!valid) {
     throw new HttpException('Forbidden', HttpStatus.FORBIDDEN);
    }
  }
  
  async getLotteryInfo({ lotteryAddress, address}: { lotteryAddress: Address; address: Address; }) {
    const contract:any = await getContract(({
      address:lotteryAddress,
      abi: lotteryJSON.abi,
      client: this.publicClient,
    }));
    
      const [
       betFee,
       betPrice,
       betsOpen,
       betsClosingTime,
       isOwner,
       prizeAmount,
       prizePool,
       ownerFeePool,
        tokenBalance,
        tokenSymbol,
        isWinner,
        isLotteryClosed,
       isPastLotteryClosingTime
     ] = await Promise.all([
      contract.read.betFee(),
       contract.read.betPrice(),
       contract.read.betsOpen(),
       contract.read.betsClosingTime(),
       contract.read.isOwner([address]),
       contract.read.prizeAmount([address]),
       contract.read.prizePool(),
       contract.read.ownerPool(),
       contract.read.tokenBalance([address]),
       contract.read.tokenSymbol(),
       contract.read.isWinner([address]),
       contract.read.isLotteryClosed(),
       contract.read.isPastLotteryClosingTime()
     ])
   
     return parseBigInt({
      betFee,
       betPrice,
       betsOpen,
       betsClosingTime,
       isOwner,
       prizeAmount,
       prizePool,
       ownerFeePool,
       tokenBalance,
       tokenSymbol,
       isWinner,
       isLotteryClosed,
       isPastLotteryClosingTime
     })
  }
  
  chain: any;
 
  async waitForTransactionReceipt(hash: string) {
    return await this.publicClient.waitForTransactionReceipt({ hash })
  }
 
  
  publicClient: any;
  walletClient: any;

  private env(key:string):string {
    return this.configService.get<string>(key);
  } 

  constructor(private configService: ConfigService) {
    const endPointUrl =`${this.env('RPC_ENDPOINT_URL')}${this.env('PROVIDER_API_KEY')}`
    this.chain = CHAINS[this.env("CHAIN")]
    this.publicClient = createPublicClient({
      chain: this.chain,
      transport: http(endPointUrl),
    });
    const account = privateKeyToAccount(`0x${this.env("PRIVATE_KEY")}`);
    this.walletClient = createWalletClient({
      transport: http(endPointUrl),
      chain:  this.chain,
      account: account,
    });
  }
}
