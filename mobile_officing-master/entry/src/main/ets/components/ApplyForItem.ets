import router from '@ohos.router'
import { applyForStatus, applyForStatusColor } from '../utils/ApplyForUtil'

@Observed
class MyProcess {
  _id: string = ''
  approve_number: string = '' // 审批编号
  department: string = '' // 所在部门
  type_id: string = '' // 类型 1：人事管理 2：行政事务 3：财务类 4：业务相关
  type: string = '' // 请假类型
  reason: string = '' // 请假事由/加班原因
  begin_date: string = '' // 请假/加班开始日期
  end_date: string = '' // 请假/加班结束日期
  begin_time: string = '' // 请假/加班开始时间
  end_time: string = '' // 请假/加班结束时间
  days: string = '' // 请假/加班天数
  hours: string = '' // 请假/加班小时
  initiator: string = '' // 发起人
  department_leader: string = '' // 部门领导
  personnel_department: string = '' // 人事部
  cc_persons: string[] = [''] // 抄送人
  approve_status: number = 0 // 审批状态 1：待审批 2、正在审批中 3、审批通过  4：拒绝
  status: number = 1 // 状态 1：启动 0：禁用
  created_at: string = ''
  updated_at: string = ''
}

@Component
export struct ApplyForItem {
  @ObjectLink process: MyProcess

  build() {
    Row() {
      Row() {
        Text()
          .width(20)
          .height(20)
          .borderRadius(10)
          .backgroundColor('#4749a1')
          .margin({ top: 33 })
      }
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.Center)
      .height('100%')
      .width(40)

      Column() {
        Text(this.process.type)
          .fontSize(20)
          .fontWeight(600)
        Text(`${this.process.begin_date.replace("-", "/")} 至 ${this.process.end_date.replace("-", "/")}  共${this.process.days}天`)
        Row() {
          Text(`申请时间：${this.process.created_at}`)
          Text(applyForStatus(this.process.approve_status))
            .fontColor(applyForStatusColor(this.process.approve_status))
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ right: 20 })
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceEvenly)
      .layoutWeight(1)
      .height(130)
    }
    .onClick(() => {
      router.pushUrl({
        url: "pages/Work/ApplyForDetail/ApplyForDetail",
        params: this.process
      })
    })
    .width('100%')
    .height(160)
    .borderColor({ top: '#efefef' })
    .borderWidth({ top: 1 })
  }
}