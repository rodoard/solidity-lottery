<script lang="ts">
  import Connect from "$lib/components/lottery/Connect.svelte";
  import Connected from "$lib/components/lottery/Connected.svelte";
  import { createAccount } from "@byteatatime/wagmi-svelte";
  const account = $derived.by(createAccount());
  let lotteryAddress = $state("");
  let lotteryName = $state("");
</script>

<div class="flex flex-col items-center pt-10">
  {#if !account.address}
    <h1 class="font-italic text-md text-center font-semibold">Please connect wallet account.</h1>
  {:else if lotteryName.length && lotteryAddress.length}
    <Connected {lotteryAddress} {lotteryName} {account} />
  {:else}
    <Connect bind:lotteryAddress bind:lotteryName />
  {/if}
</div>
