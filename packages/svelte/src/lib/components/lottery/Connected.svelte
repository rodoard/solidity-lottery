<script lang="ts">
  import { getLotteryContractInfo, type LotteryInfo } from "$lib/api";
  import { onMount } from "svelte";
  import { tryFinally } from "../util";
  import Dashboard from "./Dashboard.svelte";

  const { lotteryAddress, account } = $props();

  let isLoading = $state(true);
  let info: LotteryInfo | {} = $state({});

  onMount(async () => {
    tryFinally({
      t: async () => {
        info = await getLotteryContractInfo({ lotteryAddress, address: account.address });
        console.log("info", info);
      },
      f: async () => {
        isLoading = false;
      },
    });
  });
</script>

{#if isLoading}
  <button class="btn">
    <span class="loading loading-spinner"></span>
    Loading lottery contract
  </button>
{:else}
  <Dashboard {account} {...info} />
{/if}
