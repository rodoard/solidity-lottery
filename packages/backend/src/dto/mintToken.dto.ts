import { ApiProperty } from "@nestjs/swagger";

export default class MintTokenDto {
  @ApiProperty({ type: String, required: true, default: "My Address" })
  address: string;
}