import { ApiProperty } from "@nestjs/swagger";

export default class StartLotteryDto {
  @ApiProperty({ type: String, required: true })
  signature: string;
  @ApiProperty({ type: String, required: true })
  address: string;
  @ApiProperty({ type: Number, required: true })
  closingTime: number;
}