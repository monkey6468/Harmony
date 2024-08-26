import { CJDBUtil, Condition, OperatorType } from 'cjdb'
import { relationalStore } from '@kit.ArkData'

let TAG: string = "xwh"

// 参考使用：
// https://ohpm.openharmony.cn/#/cn/detail/cjdb
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

  static delete(model: object, cls: object) {
    CJDBUtil.delete(Object(cls).name, [
      new Condition('id', OperatorType.EQUAL_TO, `${(Object(model)).id}`)
    ])
      .then(results => {
        console.info(TAG, "删除结果：", JSON.stringify(results))
      })
      .catch(() => {
        console.error(TAG, "删除异常")
      })
  }

  static update(model: object, cls: object) {
    CJDBUtil.update(Object(cls).name, model, [
      new Condition('id', OperatorType.EQUAL_TO, `${(Object(model)).id}`)
    ])
      .then(ids => {
        console.info(TAG, "更新结果：", JSON.stringify(ids))
      })
      .catch(() => {
        console.error(TAG, "更新异常")
      })
  }

  static async getAll(cls: object, block?: (value: object[]) => void) {
    CJDBUtil.all<object>(Object(cls).name)
      .then((data) => {
        block && block(data)
        console.info(TAG, "获取全部成功")
      }).catch(() => {
      console.error(TAG, "获取全部异常")
    });
  }

  static cleanData(cls: object) {
    let sql = `DELETE FROM ${Object(cls).name}`
    console.info(TAG, "dropTable", sql)
    CJDBUtil.executeSql(sql, [])
      .then(() => {
        console.info(TAG, "清除数据成功")
      }).catch(() => {
      console.error(TAG, "清除数据异常")
    })
  }

  static dropTable(cls: object) {
    let sql = `DROP TABLE IF EXISTS ${Object(cls).name}`
    CJDBUtil.executeSql(sql, [])
      .then(() => {
        console.info(TAG, "删除表成功")
      }).catch(() => {
      console.error(TAG, "删除表异常")
    })
  }
}