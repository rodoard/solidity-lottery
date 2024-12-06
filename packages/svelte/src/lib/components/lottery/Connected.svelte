<script lang="ts">
  import Dashboard from "./Dashboard.svelte";
  const { lotteryAddress, lotteryName, account } = $props();
</script>

<Dashboard {lotteryName} {lotteryAddress} {account} />
