@Component
export struct header {
  @Prop title: string

  build() {
    Text(this.title)
      .width("100%")
      .height("12%")
      .backgroundColor(Color.Black)
      .fontColor(Color.White)
      .textAlign(TextAlign.Center)
      .fontSize(30)
      .fontWeight(FontWeight.Bold)
  }
}