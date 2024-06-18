@Entry
@Component
struct Index {

  @State time: number = 3

  build() {
    Stack({alignContent:Alignment.Bottom}){
      Stack({alignContent:Alignment.TopEnd}){
        Image($rawfile("index/launch-screen.png"))
          .width('100%')
          .height('100%')

        Row() {
          Text(`${this.time}`)
            .fontSize(30)
            .fontColor(Color.Gray)
            .width('100%')
            .textAlign(TextAlign.Center)
        }
        .width(50)
        .height(50)
        .borderRadius(25)
        .backgroundColor(Color.White)
        .margin({
          top:15,
          right:15
        })
      }

      Button("")
        .width(200)
        .height(50)
        .margin({
          bottom: 88
        })
        .backgroundColor(Color.Transparent)
    }
    .width('100%')
    .height('100%')
  }
}