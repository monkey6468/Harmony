import {
    CJBaseModel,
    CJDBUtil,
    Columns,
    ColumnType,
    Condition,
    Id,
    Ignore, OperatorType,
    Table
} from 'cjdb';
import { relationalStore } from '@kit.ArkData';
import { PidsModel } from './PidsModel';

// 参考使用：
// https://ohpm.openharmony.cn/#/cn/detail/cjdb

// @Table("FreezeModel") // @Table("表名")
// @Observed // 如果同时使用多注解，请将@Table() 放在最后，紧跟class
@Table("FreezeModel")
export default class FreezeModel extends CJBaseModel {
  @Id({ types: ColumnType.INTEGER })
  id?: number
  @Columns({ types: ColumnType.TEXT })
  carIndex?: string
  @Columns({ types: ColumnType.TEXT })
  vin?: string
  @Columns({ types: ColumnType.TEXT })
  saveTime?: string
  @Columns({ types: ColumnType.TEXT })
  makeName?: string
  @Columns({ types: ColumnType.TEXT })
  freezeModelsJson?: string
  @Columns({ types: ColumnType.TEXT })
  device?: string
  @Ignore()
  freezeModels?: PidsModel[]

  static clone(source: FreezeModel): FreezeModel {
    let item = new FreezeModel()
    item = source
    item.freezeModels = JSON.parse(source.freezeModelsJson ?? "") as [PidsModel];
    return item
  }
}

let TAG: string = "xwh"

export class DeviceDBManger {
  static async shared(context: Context) {
    await CJDBUtil.init({
      context: context, // 必填，上下文
      securityLevel: relationalStore.SecurityLevel.S1 // 非必填 （默认 S1）
    })
  }

  static insert(model: FreezeModel) {
    CJDBUtil.save(model)
      .then(id => {
        console.info(TAG, "保存成功", id)
      })
      .catch(() => {
        console.error(TAG, "保存异常")
      })
  }

  static delete(model: FreezeModel) {
    console.log('xwh ', JSON.stringify(model), (Object(model)).id);
    CJDBUtil.delete(FreezeModel.name, [
      new Condition('id', OperatorType.EQUAL_TO, `${(Object(model)).id}`)
    ])
      .then(results => {
        console.info(TAG, "删除结果：", JSON.stringify(results))
      })
      .catch(() => {
        console.error(TAG, "删除异常")
      })
  }

  static update(model: FreezeModel) {
    CJDBUtil.update(FreezeModel.name, model, [
      new Condition('id', OperatorType.EQUAL_TO, `${(Object(model)).id}`)
    ])
      .then(ids => {
        console.info(TAG, "更新结果：", JSON.stringify(ids))
      })
      .catch(() => {
        console.error(TAG, "更新异常")
      })
  }

  static async getAll(block?: (value: FreezeModel[]) => void) {
    CJDBUtil.all<FreezeModel>(FreezeModel.name)
      .then((data) => {
        block && block(data)
        console.info(TAG, "获取全部成功")
      }).catch(() => {
      console.error(TAG, "获取全部异常")
    });
  }
}