import { Salary } from '../../../types/Salary'
import { getSalaryInfo } from '../../../api/Salary'
import router from '@ohos.router'
import { NavBar } from '../../../components/NavBar'

@Entry
@Component
struct SalaryDetail {
  @State salary: Salary = {} as Salary

  async getSalaryDetailData() {
    const res = await getSalaryInfo(router.getParams()['id'])
    console.log("-----getSalaryDetailData",JSON.stringify(res))
    this.salary = res.data
  }

  onPageShow() {
    this.getSalaryDetailData()
  }

  @Builder buildMainInfo() {
    Row() {
      Column() {
        Text(`${this.salary.year}年${this.salary.month}月工资`)
          .fontSize(16)
          .fontColor('#101010')
          .fontWeight(FontWeight.Bold)
        Text("实发工资")
          .fontSize(14)
          .fontColor('#9d9d9d')
      }
      .alignItems(HorizontalAlign.Start)
      .height('60%')
      .width('50%')
      .justifyContent(FlexAlign.SpaceAround)

      Text(`￥ ${this.salary.net_salary}`)
        .fontSize(26)
        .fontColor('#4749a1')
        .fontWeight(FontWeight.Bold)
    }
    .padding({
      left: 20,
      right: 20
    })
    .width('100%')
    .height(120)
    .borderRadius(8)
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder buildRow(title, key) {
    Row() {
      Text(title)
        .fontColor('#666666')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
      Text(`${this.salary[key]}`)
        .fontColor('#666666')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
    }
    .height(40)
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder buildDetailInfo() {
    Column() {
      this.buildRow("工号", "job_number")
      this.buildRow("所在部门", "department")
      this.buildRow("基本工资", "base_salary")
      this.buildRow("绩效工资", "merit_salary")
      this.buildRow("缺勤天数", "absence_days")
      this.buildRow("病假天数", "sick_leave_days")
      this.buildRow("福利奖金", "welfare_bonus")
      this.buildRow("社保合计", "social_security_total")
      this.buildRow("公积金合计", "provident_fund_total")
      this.buildRow("实发工资", "net_salary")
    }
    .padding(15)
    .margin({
      top: 15
    })
    .borderRadius(8)
    .backgroundColor(Color.White)
  }

  build() {
    Column(){
      NavBar({title: `${this.salary.month}月工资单`})

      Column() {
        // 主要内容部分
        this.buildMainInfo()

        // 详细说明
        this.buildDetailInfo()
      }
      .padding({
        top: 15,
        left: 15,
        right: 15
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}