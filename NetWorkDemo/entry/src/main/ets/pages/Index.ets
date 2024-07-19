import { OilPrice, OilPriceModel } from '../model/OilPriceModel';
import { NetWorkManger } from '../utils/NetWorkManger';
import { OilList } from '../view/OilList';

@Entry
@Component
struct Index {
  @State oils: OilPrice[] = []
  @State oilModel: OilPriceModel = new OilPriceModel()

  async getResult() {
    let response = await NetWorkManger.requsetCmd()
    let retModel = response as OilPriceModel
    this.oilModel = retModel
    this.oils = retModel.result
    console.log("NetWorkManger:", response.msg)
  }

  aboutToAppear(): void {
    this.getResult()
  }

  build() {
    Column() {
      Text("最新油价列表：" + this.oils.length)
        .backgroundColor("#f5f5f5")
        .width('100%')
        .height('5%')
        .textAlign(TextAlign.Center)
      Text(this.oilModel.msg).width('100%')
      List() {
        ListItemGroup() {
          ForEach(this.oils, (item: OilPrice, index: number) => {
            ListItem() {
              OilList({ item })
            }
          })
        }.divider({
          strokeWidth: 1, color: "#f5f5f5"
        })
      }.width('100%').layoutWeight(1)
    }.width('90%').padding({
      left: "10%"
    }).height('100%')
  }
}