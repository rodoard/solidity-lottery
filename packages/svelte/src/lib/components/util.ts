export async function tryFinally({ t, f }: {t:()=>Promise<void>, f:()=>Promise<void>}) {
  try {
     await t()
  } finally {
    await f()
   }
}