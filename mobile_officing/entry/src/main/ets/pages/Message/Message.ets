@Component
export struct Message {
  build() {
    Column() {
      Text("消息")
    }.justifyContent(FlexAlign.Center).width('100%').height('100%')
  }
}