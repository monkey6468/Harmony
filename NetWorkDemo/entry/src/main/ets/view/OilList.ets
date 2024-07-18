import { OilPrice } from '../model/OilPriceModel'

@Component
export struct OilList {
  item: OilPrice = new OilPrice()

  build() {
    Column() {
      Row() {
        Text("省份：")
        Text(this.item.Region)
      }.width("100%")

      Row() {
        Text("时间：")
        Text(this.item.UpdateTime)
      }.width("100%")

      Row() {
        Text("92#")
        Text("95#")
        Text("98#")
        Text("0#")
      }.width("100%")
      .justifyContent(FlexAlign.SpaceEvenly)

      Row() {
        Text(this.item.Gasoline92)
        Text(this.item.Gasoline95)
        Text(this.item.Gasoline98)
        Text(this.item.Diesel0)
      }.width("100%")
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('100%')
    .padding(10)
  }
}