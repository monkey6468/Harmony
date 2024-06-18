import { Organization } from '../AddressBook'

@Component
export struct OrganizationComp {
  // 组织结构
  @ObjectLink organization: Organization

  build() {
    Row() {
      Row() {
        Image(this.organization.icon)
          .size({ width: 50, height: 50 })
        Text(this.organization.name)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 10 })
      }

      Image(this.organization.expand ? $rawfile("common/arrow_top.png") : $rawfile("common/arraw_right.png"))
        .size({ width: this.organization.expand ? 25 : 30, height: this.organization.expand ? 25 : 30 })
        .onClick(() => {
          this.organization.expand = !this.organization.expand
        })
    }
    .padding(20)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height(80)
    .backgroundColor('#f7f7f7')
    .zIndex(1)
  }
}