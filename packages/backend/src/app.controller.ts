import { Body, Controller, Get, Param, Post, Query } from '@nestjs/common';
import { AppService } from './app.service';
import { Address } from 'viem';
import StartLotteryDto from './dto/startLottery.dto';
import CloseLotteryDto from './dto/closeLottery.dto';

@Controller("/api")
export class AppController {
  constructor(private readonly appService: AppService) { }

  @Get('lottery/:lottery/:address')
  async getLotteryInfo(@Param('lottery') lotteryAddress: string, @Param('address') address: string) {
    return { result: await this.appService.getLotteryInfo({ lotteryAddress: lotteryAddress as Address, address: address as Address }) };
  }
  
  @Post('lottery/:address/start')
  async startLottery(@Param('address') lotteryAddress: string, @Body() dto: StartLotteryDto) {
    const { address,  closingTime, signature } = dto;
    await this.appService.verifySignature({ address: address as Address, signature, message:"start lottery" })
    return { result: await this.appService.startLottery({ signature, lotteryAddress: lotteryAddress as Address, address: address as Address, closingTime }) };
  }

  @Post('lottery/:address/close')
  async closeLottery(@Param('address') lotteryAddress: string, @Body() dto: CloseLotteryDto) {
    const { address, signature } = dto;
    await this.appService.verifySignature({ address: address as Address, signature, message:"close lottery" })
    return { result: await this.appService.closeLottery({ lotteryAddress: lotteryAddress as Address, address: address as Address}) };
  }
}
