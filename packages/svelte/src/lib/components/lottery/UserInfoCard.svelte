<script lang="ts">
  let { title, value, unit }: { title: string; value: number; unit: string } = $props();
</script>

<div class="card bg-base-100 p-4 shadow-lg">
  <div class="card-body">
    <h2 class="card-title text-lg font-bold">{title}</h2>
    <p class="text-2xl font-semibold">{value} {unit}</p>
  </div>
</div>
