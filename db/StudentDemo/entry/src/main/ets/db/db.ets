import { relationalStore } from '@kit.ArkData'

const config: relationalStore.StoreConfig = {
  name: "stu.db",
  securityLevel: relationalStore.SecurityLevel.S2
}

export async function get_rdb(): Promise<relationalStore.RdbStore> {
  return await relationalStore.getRdbStore(globalThis.context, config)
}