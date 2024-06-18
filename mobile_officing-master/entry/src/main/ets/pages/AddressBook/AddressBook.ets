import { OrganizationComp } from './components/OrganizationComp'
import { EmployeeComp } from './components/EmployeeComp'
import { Employee } from '../../types/Employee'
import { getEmployeeList, getDepartmentList } from '../../api/AddressBook'
import { Department } from '../../types/Department'
import router from '@ohos.router'

@Observed
export class Organization {
  icon: ResourceStr
  name: string
  expand: boolean
  employees: Employee[]

  constructor(icon: ResourceStr, name: string, expand: boolean, employees: Employee[]) {
    this.icon = icon
    this.name = name
    this.expand = expand
    this.employees = employees
  }
}

@Component
export struct AddressBook {
  @State currentIndex: number = 0
  @State employeeList: Employee[] = []
  @State organizationList: Organization[] = []

  async getEmployeeListData() {
    const res = await getEmployeeList()
    this.employeeList = res.data
  }

  async geDepartmentListData() {
    const res = await getDepartmentList()

    res.data.forEach((department: Department) => {
      this.organizationList.push(new Organization($rawfile("address-book/organization.png"), department.name, false, department.employees))
    })
  }

  aboutToAppear() {
    this.getEmployeeListData()
    this.geDepartmentListData()
  }

  @Builder buildTop() {
    Row() {
      Text("通讯录")
        .fontColor(Color.White)
        .fontSize(26)
        .fontWeight(800)
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#4749a1')
    .width('100%')
    .height(80)
  }

  @Builder TabItemBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor('#4749a0')
        .fontSize(this.currentIndex === index ? 20 : 16)
        .fontWeight(this.currentIndex === index ? 800 : 300)
        .lineHeight(22)
        .margin({ top: 17, bottom: 10 })
      Divider()
        .strokeWidth(5)
        .color('#4749a0')
        .width('50%')
        .opacity(this.currentIndex === index ? 1 : 0)
    }
    .backgroundColor(Color.White)
    .padding({ bottom: 10 })
    .width('100%')
  }

  // 联系人
  @Builder buildContactsItem(employee: Employee) {
    Row() {
      Image(employee.avatar)
        .width(56)
        .height(56)
        .borderRadius(28)
      Text(employee.name)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ left: 10 })
    }
    .padding({ left: 20 })
    .width('100%')
    .height(80)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .onClick(() => {
      router.pushUrl({
        url: "pages/AddressBook/EmployeeDetail/EmployeeDetail",
        params: employee
      })
    })
  }

  // 常用联系人列表
  @Builder buildContacts() {
    List({ space: 10 }) {
      ForEach(this.employeeList, (employee: Employee) => {
        ListItem() {
          this.buildContactsItem(employee)
        }
      })
    }
    .padding(15)
    .height('100%')
    .backgroundColor('#f7f7f7')
  }

  // 构建组织结构每一项
  @Builder buildOrganizationItem(organization: Organization) {
    OrganizationComp({ organization: organization })
  }

  // 构建组织结构
  @Builder buildOrganization() {
    List() {
      ForEach(this.organizationList, (organization: Organization) => {
        ListItemGroup({ header: this.buildOrganizationItem(organization) }) {
          ListItem() {
            EmployeeComp({ organization: organization })
          }
        }
      })
    }
    .sticky(StickyStyle.Header)
    .width('100%')
    .height('100%')
  }

  @Builder buildTopTab() {
    Tabs({ barPosition: BarPosition.Start }) {
      TabContent() {
        this.buildContacts()
      }.tabBar(this.TabItemBuilder(0, '常用联系人'))

      TabContent() {
        this.buildOrganization()
      }.tabBar(this.TabItemBuilder(1, '组织架构'))
    }
    .backgroundColor(Color.White)
    .onChange((index: number) => {
      this.currentIndex = index
    })
    .layoutWeight(1)
    .backgroundColor('#f7f7f7')
  }

  build() {
    Column() {
      // 渲染顶部
      this.buildTop()
      // 渲染Tab
      this.buildTopTab()
    }
    .width('100%')
    .height('100%')
  }
}