import { DBManger } from './DBManger';
import FreezeModel from './FreezeModel';
import { PidsModel } from './PidsModel';
import TestModel from './TestModel';

@Entry
@Component
struct Index {
  build() {
    Column() {
      freeze_container()
      // test_container()
    }.width("100%")
    .height("100%")
  }
}

@Component
struct freeze_container {
  build() {
    Column({ space: 20 }) {
      Button("insert")
        .onClick(() => {
          console.log('xwh Hello World');
          let model: FreezeModel = new FreezeModel();
          model.makeName = 'John';
          model.vin = "25";

          let pids: PidsModel[] = [{
            "simpleName": "冻结帧故障码",
            "value": "U0073",
            "valueType": 2,
            "name": "导致产生冻结帧的故障码",
            "pid": "2",
            "unit": ""
          },
            {
              "simpleName": "转速",
              "value": "663",
              "valueType": 0,
              "name": "发动机转速",
              "pid": "17",
              "unit": "\/分"
            },]

          model.freezeModelsJson = JSON.stringify(pids)
          DBManger.insert(model)
        })

      Button("delete")
        .onClick(() => {
          let model: FreezeModel = new FreezeModel();
          model.id = 1
          DBManger.delete(model)
        })

      Button("update")
        .onClick(() => {
          let model: FreezeModel = new FreezeModel();
          model.id = 2
          model.makeName = 'John111';
          model.vin = "2544";
          DBManger.update(model)
        })

      Button("get all")
        .onClick(() => {
          DBManger.getAll(FreezeModel, (data) => {
            if (data.length > 0) {
              let model = data[0] as FreezeModel
              let modelCopy = FreezeModel.clone(model)
              let pids = modelCopy.freezeModels
              console.log("xwh2", pids)
              console.log("xwh3", model.freezeModelsJson)
            }
            console.log("xwh", data.length, JSON.stringify(data))
          })
        })
      Button("clean data")
        .onClick(() => {
          DBManger.cleanData(FreezeModel)
        })

      Button("drop table(⚠️)")
        .onClick(() => {
          DBManger.dropTable(FreezeModel)
        })
    }.borderWidth(1)
    .borderColor(Color.Red)
  }
}

@Component
struct test_container {
  build() {
    Column({ space: 20 }) {
      Button("insert")
        .onClick(() => {
          console.log('xwh Hello World');
          let model: TestModel = new TestModel();
          model.makeName = 'John';
          model.vin = "25";

          let pids: PidsModel[] = [{
            "simpleName": "冻结帧故障码",
            "value": "U0073",
            "valueType": 2,
            "name": "导致产生冻结帧的故障码",
            "pid": "2",
            "unit": ""
          },
            {
              "simpleName": "转速",
              "value": "663",
              "valueType": 0,
              "name": "发动机转速",
              "pid": "17",
              "unit": "\/分"
            },]

          model.testModelsJson = JSON.stringify(pids)
          DBManger.insert(model)
        })

      Button("delete")
        .onClick(() => {
          let model: TestModel = new TestModel();
          model.id = 1
          DBManger.delete(model)
        })

      Button("update")
        .onClick(() => {
          let model: TestModel = new TestModel();
          model.id = 2
          model.makeName = 'John111';
          model.vin = "2544";
          DBManger.update(model)
        })

      Button("get all")
        .onClick(() => {
          DBManger.getAll(TestModel, (data) => {
            if (data.length > 0) {
              let model = data[0] as TestModel
              let modelCopy = TestModel.clone(model)
              let pids = modelCopy.TestModels
              console.log("xwh2", pids)
              console.log("xwh3", model.testModelsJson)
            }
            console.log("xwh", data.length, JSON.stringify(data))
          })
        })
      Button("clean data")
        .onClick(() => {
          DBManger.cleanData(TestModel)
        })

      Button("drop table(⚠️)")
        .onClick(() => {
          DBManger.dropTable(TestModel)
        })
    }.borderWidth(1)
    .borderColor(Color.Red)
  }
}