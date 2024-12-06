<script lang="ts">
  import { getAllContracts } from "$lib/utils/scaffold-eth/contractsData";
  import { type Address } from "viem";
  let { lotteryAddress = $bindable(), lotteryName = $bindable() }: { lotteryAddress: Address; lotteryName: string } =
    $props();
  let contracts = getAllContracts();
  let lottery: { name: string; address: string } | undefined = $state(undefined);
  $effect(() => {
    if (lottery?.name?.length) {
      lotteryAddress = lottery.address as Address;
      lotteryName = lottery.name;
    }
  });
</script>

<div class=" mt-16 w-full flex-grow px-8">
  <div class="mx-5 mb-5 flex items-center justify-center space-x-3">
    <div class="bg-primary text-primary-content mb-6 rounded-lg p-6 text-center shadow-md">
      <label class="form-control w-full max-w-xs">
        <div class="label">
          <h1 class="text-2xl font-bold">Select Lottery contract</h1>
        </div>
        <select bind:value={lottery} class="select select-bordered">
          <option disabled selected value="">Pick one</option>
          {#each Object.entries(contracts) as [name, contract]}
            <option value={{ name, address: contract.address }}>
              {name}
            </option>
          {/each}
        </select>
      </label>
    </div>
  </div>
</div>
