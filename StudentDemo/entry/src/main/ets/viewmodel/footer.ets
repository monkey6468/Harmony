@Component
export struct footer {
  okck: () => void = () => {
  }

  build() {
    Button("Add")
      .width("80%")
      .margin({ top: 10 })
      .fontSize(28)
      .height("6%")
      .onClick(this.okck)
  }
}