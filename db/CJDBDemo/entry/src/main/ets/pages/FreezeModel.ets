import {
    CJBaseModel,
    CJDBUtil,
    Columns,
    ColumnType,
    Condition,
    Id,
    Ignore,
    OperatorType,
    Table
} from 'cjdb';
import { relationalStore } from '@kit.ArkData';
import { PidsModel } from './PidsModel';

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