import axios, { AxiosResponse } from '@ohos/axios';
import { OilPrice, OilPriceModel } from '../model/OilPriceModel';
import { OilList } from '../view/OilList';

@Entry
@Component
struct Index {
  url: string = "https://api.oioweb.cn/api/common/GasolinePriceQuery"
  //"http://47.112.25.203:8061/home/Getyj?city=changsha"

  @State oils: OilPrice[] = []
  @State oilModel: OilPriceModel = new OilPriceModel()

  // 支持async/await用法
  async getDataList() {
    try {
      const response: AxiosResponse = await axios.get<string, AxiosResponse<OilPriceModel>, null>(this.url);
      let retModel: OilPriceModel = response.data
      this.oilModel = retModel
      this.oils = retModel.result
      console.log("monkey:", JSON.stringify(this.oils))
    } catch (error) {
      console.error(JSON.stringify(error))
    }
  }

  aboutToAppear(): void {
    this.getDataList()
  }

  build() {
    Column() {
      Text("最新油价列表：" + this.oils.length)
        .backgroundColor("#f5f5f5")
        .width('100%')
        .height('5%')
        .textAlign(TextAlign.Center)
      Text(this.oilModel.msg)
        .width('100%')
      List() {
        ListItemGroup() {
          ForEach(this.oils, (item: OilPrice, index: number) => {
            ListItem() {
              OilList({ item })
            }
          })
        }
        .divider({
          strokeWidth: 1,
          color: "#f5f5f5"
        })
      }.width('100%')
      .layoutWeight(1)
    }.width('90%')
    .padding({
      left:"10%"
    })
    .height('100%')
  }
}