import { ApiProperty } from "@nestjs/swagger";

export default class CloseLotteryDto {
  @ApiProperty({ type: String, required: true })
  address: string;
  @ApiProperty({ type: String, required: true })
  signature: string;
}