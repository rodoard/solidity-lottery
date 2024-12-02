<script lang="ts">
  import Connect from "$lib/components/lottery/Connect.svelte";
  import Connected from "$lib/components/lottery/Connected.svelte";
  import { createAccount } from "@byteatatime/wagmi-svelte";
  const account = $derived.by(createAccount());
  let lotteryAddress = $state("");
  let lotteryConnected = $derived(lotteryAddress.length > 0);
</script>

<div class="flex flex-col items-center pt-10">
  {#if lotteryConnected}
    <Connected {lotteryAddress} {account} />
  {:else}
    <Connect bind:lotteryAddress />
  {/if}
</div>
