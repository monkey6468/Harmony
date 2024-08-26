import { CJDBUtil, Condition, OperatorType } from 'cjdb'
import { relationalStore } from '@kit.ArkData'

let TAG: string = "xwh"

export class DBManger {
  static async shared(context: Context) {
    await CJDBUtil.init({
      context: context, // 必填，上下文
      securityLevel: relationalStore.SecurityLevel.S1 // 非必填 （默认 S1）
    })
  }

  static insert(model: object) {
    CJDBUtil.save(model)
      .then(id => {
        console.info(TAG, "保存成功", id)
      })
      .catch(() => {
        console.error(TAG, "保存异常")
      })
  }

  static delete(model: object, tableName: string) {
    CJDBUtil.delete(tableName, [
      new Condition('id', OperatorType.EQUAL_TO, `${(Object(model)).id}`)
    ])
      .then(results => {
        console.info(TAG, "删除结果：", JSON.stringify(results))
      })
      .catch(() => {
        console.error(TAG, "删除异常")
      })
  }

  static update(model: object, tableName: string) {
    CJDBUtil.update(tableName, model, [
      new Condition('id', OperatorType.EQUAL_TO, `${(Object(model)).id}`)
    ])
      .then(ids => {
        console.info(TAG, "更新结果：", JSON.stringify(ids))
      })
      .catch(() => {
        console.error(TAG, "更新异常")
      })
  }

  static async getAll(model: object, block?: (value: object[]) => void) {
    CJDBUtil.all<object>(Object(model).name)
      .then((data) => {
        block && block(data)
        console.info(TAG, "获取全部成功")
      }).catch(() => {
      console.error(TAG, "获取全部异常")
    });
  }
}