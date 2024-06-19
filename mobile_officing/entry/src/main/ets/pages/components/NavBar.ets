import router from '@ohos.router'
@Component
export struct NavBar{
  @Prop title: string

  build(){
    Row() {
      // 左边的返回
      Image($rawfile("common/back.png"))
        .width(20)
        .height(20)
        .onClick(() => {
          router.back()
        })

      // 中间的标题
      Text(this.title)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      // 右边
      Text("")
    }
    .width('100%')
    .height(60)
    .padding({
      left: 10,
      right: 10
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
  }
}
