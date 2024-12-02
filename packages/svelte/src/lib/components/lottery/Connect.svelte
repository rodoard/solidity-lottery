<script lang="ts">
  import { getAllContracts } from "$lib/utils/scaffold-eth/contractsData";
  import { type Address } from "viem";
  let { lotteryAddress = $bindable() }: { lotteryAddress: Address } = $props();
  let contracts = getAllContracts();
</script>

<div class=" mt-16 w-full flex-grow px-8">
  <div class="mx-5 mb-5 flex items-center justify-center space-x-3">
    <div class="bg-primary text-primary-content mb-6 rounded-lg p-6 text-center shadow-md">
      <label class="form-control w-full max-w-xs">
        <div class="label">
          <h1 class="text-2xl font-bold">Select Lottery contract</h1>
        </div>
        <select bind:value={lotteryAddress} class="select select-bordered">
          <option disabled selected value="">Pick one</option>
          {#each Object.entries(contracts) as [name, contract]}
            <option value={contract.address as Address}>
              {name}
            </option>
          {/each}
        </select>
      </label>
    </div>
  </div>
</div>
