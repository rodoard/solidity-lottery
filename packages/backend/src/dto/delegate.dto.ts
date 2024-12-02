import { ApiProperty } from "@nestjs/swagger";

export default class DelegateDto {
  @ApiProperty({ type: String, required: true, default: "My Address" })
  address: string;
}