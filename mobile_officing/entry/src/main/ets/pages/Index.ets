@Entry
@Component
struct Index {

  build() {
    Stack({alignContent:Alignment.Bottom}){
      Button("立即进入")
        .width(200)
        .height(50)
        .margin({
          bottom: 88
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Red)
  }
}