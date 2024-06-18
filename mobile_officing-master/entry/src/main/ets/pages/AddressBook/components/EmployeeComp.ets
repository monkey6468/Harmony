import { Organization } from '../AddressBook'
import { Employee } from '../../../types/Employee'
import router from '@ohos.router'

@Component
export struct EmployeeComp {
  // 组织结构
  @ObjectLink organization: Organization

  @Builder buildEmployee(employee: Employee) {
    Row() {
      Text(employee.name ? employee.name.substring(0,1) : "")
        .width(50)
        .height(50)
        .borderRadius(50)
        .fontSize(18)
        .textAlign(TextAlign.Center)
        .fontColor(Color.White)
        .backgroundColor('#6467d3')
      Text(employee.name)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ left: 10 })
    }
    .padding({ left: 30, top: 20, right: 20, bottom: 20 })
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height(80)
    .onClick(() => {
      router.pushUrl({
        url: "pages/AddressBook/EmployeeDetail/EmployeeDetail",
        params: employee
      })
    })
  }

  build() {
    if (this.organization.expand) {
      Column() {
        ForEach(this.organization.employees, (employee: Employee) => {
          this.buildEmployee(employee)
        })
      }
    }
  }
}