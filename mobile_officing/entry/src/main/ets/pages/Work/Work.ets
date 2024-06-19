import { Process } from '../../types/Process'
import { getProcessList } from '../../api/Process'
import { ApplyForItem } from '../../components/ApplyForItem'
import router from '@ohos.router'

@Component
@Preview
export struct Work {
  @State processList: Process[] = []

  async getProcessListData() {
    const res = await getProcessList({ type_id: 0, page: 1, pageSize: 2 })
    this.processList = res.data.items
  }

  aboutToAppear() {
    this.getProcessListData()
  }

  @Builder buildTop() {
    Row() {
      Text("我的办公").fontSize('30sp').fontColor(Color.White).fontWeight(800)
      Row() {
        Column() {
          Text("8℃").fontColor(Color.White).fontWeight(800)
          Text("6月19日").fontColor(Color.White).margin({ top: 5 })
        }

        Image($rawfile("work/weather.png")).height(50).width(50)
      }
    }
    .padding({ left: 20, right: 20, bottom: 10 })
    .height('100vp')
    .width('100%')
    .alignItems(VerticalAlign.Bottom)
    .justifyContent(FlexAlign.SpaceBetween)
    .borderColor({ bottom: '#6a6cb2' })
    .borderWidth({ bottom: 1 })
    .backgroundColor('#4749a1')
  }

  @Builder buildTip() {
    Row() {
      Column() {
        Text('待审批').fontSize(16).fontColor('#8888cd')
        Text('15').fontSize(26).fontColor(Color.White).fontWeight(800).margin({ top: 15 })
      }

      Column() {
        Text('会议提醒').fontSize(16).fontColor('#8888cd')
        Text('2').fontSize(26).fontColor(Color.White).fontWeight(800).margin({ top: 15 })
      }

      Column() {
        Text('周报').fontSize(16).fontColor('#8888cd')
        Text('1').fontSize(26).fontColor(Color.White).fontWeight(800).margin({ top: 15 })
      }

      Column() {
        Text('工作汇报').fontSize(16).fontColor('#8888cd')
        Text('5').fontSize(26).fontColor(Color.White).fontWeight(800).margin({ top: 15 })
      }
    }
    .padding({ top: 30 })
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.SpaceEvenly)
    .backgroundColor('#4749a1')
    .height(200)
    .width('100%')
  }

  // 应用管理
  @Builder buildAppManagement() {
    Column() {
      Row() {
        Row() {
          Image($rawfile("work/menu.png")).width(26).height(26)
          Text("应用管理").margin({ left: 5 }).fontSize(20).fontWeight(600).fontColor('#101010')
        }

        Row() {
          Text("自定义").fontColor('#7f6666').fontSize(16)
          Image($rawfile("common/arraw_right.png")).width(20).height(20)
        }
      }
      .padding({ left: 10, right: 10 })
      .justifyContent(FlexAlign.SpaceBetween)
      .height(60)
      .width('100%')
      .borderColor({ bottom: '#efefef' })
      .borderWidth({ bottom: 1 })

      // this.buildAppContainer()
      this.buildAppContainer2()
    }
    .height(280)
    .width('94%')
    .backgroundColor(Color.White)
    .borderRadius(10)
    .offset({ y: -180 })
  }

  // 构建App容器（使用Flex组件）
  @Builder buildAppContainer2() {
    Flex({ wrap: FlexWrap.Wrap, alignContent: FlexAlign.SpaceBetween }) {
      this.buildAppItem($rawfile("work/process.png"), "流程申请")
      this.buildAppItem($rawfile("work/clock.png"), "考勤打卡")
      this.buildAppItem($rawfile("work/report.png"), "汇报")
      this.buildAppItem($rawfile("work/approve.png"), "OA审批")
      this.buildAppItem($rawfile("work/card.png"), "补卡申请")
      this.buildAppItem($rawfile("work/salary.png"), "工资单")
      this.buildAppItem($rawfile("work/notice.png"), "公司公告")
      this.buildAppItem($rawfile("work/rule.png"), "规章制度")
    }.padding({ left: 15, right: 15, top: 20, bottom: 20 })
  }

  // 构建App每一项
  @Builder buildAppItem(image: ResourceStr, text: string) {
    Column() {
      Image(image).width(50).height(50)
      Text(text).margin({ top: 10 })
    }.width('25%').margin({ bottom: 20 })
  }

  @Builder buildApplyFor() {
    Column() {
      Row() {
        Row() {
          Image($rawfile("work/badge.png")).width(22).height(22)
          Text("我的申请").margin({ left: 5 }).fontSize(20).fontWeight(600).fontColor('#101010')
        }

        Row() {
          Text("更多").fontColor('#7f6666').fontSize(16)
          Image($rawfile("common/arraw_right.png")).width(20).height(20)
        }.onClick(()=>{
          console.log("----更多----")
          router.pushUrl({
            url: "pages/Work/MyApplyFor/MyApplyFor"
          })
        })
      }.padding({ left: 10, right: 10 }).justifyContent(FlexAlign.SpaceBetween).height(60).width('100%')

      ForEach(this.processList, (process: Process) => {
        ApplyForItem({ process })
      })
      // Row() {
      //   Row() {
      //     Text()
      //       .width(20)
      //       .height(20)
      //       .borderRadius(10)
      //       .backgroundColor('#4749a1')
      //       .margin({ top: 33 })
      //   }.alignItems(VerticalAlign.Top).justifyContent(FlexAlign.Center).height('100%').width(40)
      //
      //   Column() {
      //     Text("请假申请").fontSize(20).fontWeight(600)
      //     Text("2024/6/19 至 2024/6/21 共3天")
      //     Row() {
      //       Text('申请时间：2024/6/19 15:30')
      //       Text("待审批").fontColor('#ff935d')
      //     }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ right: 20 })
      //   }.alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.SpaceEvenly).layoutWeight(1).height(130)
      // }.width('100%').height(160).borderColor({ top: '#efefef' }).borderWidth({ top: 1 })

      // Row() {
      //   Row() {
      //     Text()
      //       .width(20)
      //       .height(20)
      //       .borderRadius(10)
      //       .backgroundColor('#4749a1')
      //       .margin({ top: 33 })
      //   }.alignItems(VerticalAlign.Top).justifyContent(FlexAlign.Center).height('100%').width(40)
      //
      //   Column() {
      //     Text("请假申请").fontSize(20).fontWeight(600)
      //     Text("2024/6/19 至 2024/6/21 共3天")
      //     Row() {
      //       Text('申请时间：2024/6/19 15:30')
      //       Text("正在审批中").fontColor('#53cbae')
      //     }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ right: 20 })
      //   }.alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.SpaceEvenly).layoutWeight(1).height(130)
      // }.width('100%').height(160).borderColor({ top: '#efefef' }).borderWidth({ top: 1 })
    }.margin({ top: -65, bottom: 15 }).width('94%').backgroundColor(Color.White).borderRadius(10)
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      this.buildTop()

      List() { // 提示信息
        this.buildTip() // 应用管理
        this.buildAppManagement() // 我的申请
        this.buildApplyFor()
      }.alignListItem(ListItemAlign.Center).width("100%").height("100%").padding({ top: 100 })
    }.width('100%').height('100%').backgroundColor("#f5f5f5")
  }
}