import { ApiProperty } from "@nestjs/swagger";

export default class TargetBlockNumberDto {
  @ApiProperty({ type: String, required: true, default: "Chain current block number" })
  targetNumber: number;
}