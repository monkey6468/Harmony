import router from '@ohos.router'
import { Process } from '../../../types/Process'
import { NavBar } from '../../../components/NavBar'
import { applyForStatus, applyForStatusColor } from '../../../utils/ApplyForUtil'

@Entry
@Component
struct ApplyForDetail {
  @State process: Process = {} as Process

  aboutToAppear() {
    this.process = router.getParams() as Process
  }

  @Builder buildHeader() {
    Row() {
      // 左边
      Row() {
        Text()
          .width(20)
          .height(20)
          .borderRadius(10)
          .backgroundColor('#4749a1')

        Text(`${this.process.initiator}${this.process.type}`)
          .fontSize(18)
          .fontColor('#101010')
          .fontWeight(FontWeight.Bold)
          .margin({ left: 10 })
      }

      // 右边
      Text(applyForStatus(this.process.approve_status))
        .fontColor(applyForStatusColor(this.process.approve_status))
    }
    .height(80)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 15, right: 15 })
    .backgroundColor(Color.White)
    .width('100%')
    .borderRadius(8)
  }

  @Builder buildContent() {
    Column() {
      Row() {
        Text(`审批编号：${this.process.approve_number}`)
      }
      .height(40)
      .width('100%')

      Row() {
        Text(`所在部门：${this.process.department}`)
      }
      .height(40)
      .width('100%')

      Row() {
        Text(`请假类型：${this.process.type}`)
      }
      .height(40)
      .width('100%')

      Row() {
        if (this.process.type_id == "1") {
          Text(`开始时间：${this.process.begin_date} ${this.process.begin_time}`)
        } else if (this.process.type_id == "2") {
          Text(`开始时间：${this.process.begin_time}`)
        }
      }
      .height(40)
      .width('100%')

      Row() {
        if (this.process.type_id == "1") {
          Text(`结束时间：${this.process.end_date} ${this.process.end_time}`)
        } else if (this.process.type_id == "2") {
          Text(`结束时间：${this.process.end_time}`)
        }

      }
      .height(40)
      .width('100%')

      Row() {
        if (this.process.type_id == "1") {
          Text(`请假天数：${this.process.days}天`)

        } else if (this.process.type_id == "2") {
          Text(`加班时长：${this.process.hours}小时`)
        }

      }
      .height(40)
      .width('100%')

      Row() {
        if (this.process.type_id == "1") {
          Text("请假事由：")
        } else if (this.process.type_id == "2") {
          Text("加班原因：")
        }

        Text(this.process.reason)
          .layoutWeight(1)
      }
      .alignItems(VerticalAlign.Top)
      .margin({ top: 10 })
      .width('100%')
    }
    .padding(15)
    .width('100%')
    .borderRadius(8)
    .margin({ top: 15 })
    .backgroundColor(Color.White)
  }

  @Builder buildProcess() {
    Row() {
      Image($rawfile("process/process1.png"))
        .width(30)
        .height(230)
        .objectFit(ImageFit.Cover)
      Column() {
        Row() {
          Column() {
            Text("魏茜茜").fontSize(20).fontColor('#101010').fontWeight(FontWeight.Bold)
            Text("发起申请").fontSize(16).fontColor('#666666')
              .margin({
                top: 10
              })
          }
          .alignItems(HorizontalAlign.Start)

          Text("2022-12-07 15:00").fontSize(14).fontColor('#9999a3')
        }
        .borderColor({ bottom: '#efefef' })
        .borderWidth({ bottom: 1 })
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .height(80)

        Row() {
          Column() {
            Row() {
              Text("张云").fontSize(20).fontColor('#101010').fontWeight(FontWeight.Bold)
              Text("部门领导")
                .padding(5)
                .fontSize(12)
                .margin({ left: 15 })
                .borderRadius(5)
                .backgroundColor('#eaeaff')
                .height(22)
                .fontColor('#6a6bcd')
            }

            Text("已审批").fontSize(16).fontColor('#666666')
              .margin({
                top: 10
              })
          }
          .alignItems(HorizontalAlign.Start)

          Text("2022-12-07 15:00").fontSize(14).fontColor('#9999a3')
        }
        .borderColor({ bottom: '#efefef' })
        .borderWidth({ bottom: 1 })
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .height(80)

        Row() {
          Column() {
            Row() {
              Text("梨花").fontSize(20).fontColor('#101010').fontWeight(FontWeight.Bold)
              Text("人事部")
                .padding(5)
                .fontSize(12)
                .margin({ left: 15 })
                .borderRadius(5)
                .backgroundColor('#eaeaff')
                .height(22)
                .fontColor('#6a6bcd')
            }

            Text("等待审批").fontSize(16).fontColor('#ff5f35')
              .margin({
                top: 10
              })
          }
          .alignItems(HorizontalAlign.Start)

          Text("2022-12-07 15:00").fontSize(14).fontColor('#9999a3')
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .height(80)

      }
      .padding({
        left: 10
      })
      .layoutWeight(1)
    }
    .padding(15)
    .width('100%')
    .borderRadius(8)
    .margin({ top: 15 })
    .backgroundColor(Color.White)
  }

  build() {
    Column() {
      // 导航栏
      NavBar({
        title: "申请详情"
      })

      List() {
        // 构建头部
        this.buildHeader()
        // 构建详情内容
        this.buildContent()
        // 构建流程
        this.buildProcess()
      }
      .padding(15)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}