@Component
export struct My {
  build() {
    Column() {
      Text("我的")
    }.justifyContent(FlexAlign.Center).width('100%').height('100%')
  }
}