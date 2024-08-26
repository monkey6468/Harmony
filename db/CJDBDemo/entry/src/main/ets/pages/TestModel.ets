import {
    CJBaseModel,
    Columns,
    ColumnType,
    Id,
    Ignore,
    Table
} from 'cjdb';
import { PidsModel } from './PidsModel';

// @Table("TestModel") // @Table("表名")
// @Observed // 如果同时使用多注解，请将@Table() 放在最后，紧跟class
@Table("TestModel")
export default class TestModel extends CJBaseModel {
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
  testModelsJson?: string
  @Columns({ types: ColumnType.TEXT })
  device?: string
  @Ignore()
  TestModels?: PidsModel[]

  static clone(source: TestModel): TestModel {
    let item = new TestModel()
    item = source
    item.TestModels = JSON.parse(source.testModelsJson ?? "") as [PidsModel];
    return item
  }
}