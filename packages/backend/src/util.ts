import { formatEther } from "viem";

export function parseBigInt(obj) {
  return JSON.parse(JSON.stringify(obj, (key, value) =>
    typeof value === 'bigint'
      ? formatEther(value)
      : value // return everything else unchanged
  ));
}