import router from '@ohos.router'
import { NavBar } from '../../../components/NavBar'
import { Employee } from '../../../types/Employee'
import call from '@ohos.telephony.call'

@Entry
@Component
struct EmployeeDetail {
  @State employee: Employee = {} as Employee

  aboutToAppear() {
    this.employee = router.getParams() as Employee
  }

  @Builder buildPart1() {
    Column() {
      Text(this.employee.name ? this.employee.name.substring(0, 1) : "")
        .fontSize(30)
        .width(100)
        .height(100)
        .borderRadius(50)
        .backgroundColor('#6467d3')
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
      Text(this.employee.name)
        .fontSize(32)
        .fontColor('#101010')
        .fontWeight(FontWeight.Bold)
        .margin({
          top: 20
        })
      Text(`${this.employee.department_name} / ${this.employee.position}`)
        .fontSize(18)
        .fontColor('#101010')
        .margin({
          top: 20
        })

      Row() {
        Button("消息")
          .fontSize(20)
          .width(150)
          .height(60)
          .fontColor(Color.White)
          .backgroundColor('#6467d3')
          .type(ButtonType.Normal)
          .borderRadius(8)

        Button("电话联系")
          .fontSize(20)
          .width(150)
          .height(60)
          .fontColor(Color.White)
          .backgroundColor('#6467d3')
          .type(ButtonType.Normal)
          .borderRadius(8)
          .onClick(() => {
            call.makeCall(this.employee.phone, err => {
              console.log(`makeCall callback: err->${JSON.stringify(err)}`)
            })
          })
      }
      .margin({
        top: 20
      })
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .padding({
      top: 20
    })
    .width('100%')
    .height(320)
    .borderRadius(10)
    .backgroundColor(Color.White)
  }

  @Builder buildPart2() {
    Column() {
      Row() {
        Text("部门")
          .fontSize(20)
        Text(`${this.employee.department_name}\n${this.employee.team_name}`)
          .fontSize(20)
          .fontColor('#4749a1')
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Divider()
        .color('#ededed')
        .height(1)
        .width('100%')
        .margin({
          top: 20,
          bottom: 20
        })

      Row() {
        Text("直属领导")
          .fontSize(20)
        Text(this.employee.direct_leader)
          .fontSize(20)
          .fontColor('#4749a1')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Divider()
        .color('#ededed')
        .height(1)
        .width('100%')
        .margin({
          top: 20,
          bottom: 20
        })

      Row() {
        Text("入职时间")
          .fontSize(20)
        Text(this.employee.entry_time)
          .fontSize(20)
          .fontColor('#4749a1')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Divider()
        .color('#ededed')
        .height(1)
        .width('100%')
        .margin({
          top: 20,
          bottom: 20
        })

      Row() {
        Text("备注")
          .fontSize(20)
        Text(this.employee.remark)
          .fontSize(20)
          .fontColor('#4749a1')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Divider()
        .color('#ededed')
        .height(1)
        .width('100%')
        .margin({
          top: 20
        })
    }
    .padding(20)
    .width('100%')
    .borderRadius(10)
    .margin({
      top: 20
    })
    .backgroundColor(Color.White)
  }

  build() {
    Column() {
      NavBar({title: "个人信息"})

      List() {
        // 第一部分渲染
        this.buildPart1()
        // 第二部分渲染
        this.buildPart2()
      }
      .width('100%')
      .layoutWeight(1)
      .padding(15)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}