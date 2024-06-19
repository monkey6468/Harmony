@Component
export struct AddressBook {
  build() {
    Column() {
      Text("通讯录")
    }.justifyContent(FlexAlign.Center).width('100%').height('100%')
  }
}