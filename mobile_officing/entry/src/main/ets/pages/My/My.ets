import { User } from '../../types/User'
import { getUserInfo } from '../../api/User'
import router from '@ohos.router'

@Component
export struct My {
  @State userInfo: User = {} as User

  async getUserInfoData() {
    const res = await getUserInfo()
    this.userInfo = res.data

    // 存储到全局状态中
    AppStorage.SetOrCreate("userInfo", res.data)
  }

  aboutToAppear() {
    this.getUserInfoData()
  }

  @Builder buildHeader() {
    Column() {
      Image(this.userInfo.avatar)
        .objectFit(ImageFit.Fill)
        .width("80vp")
        .height("80vp")
        .borderRadius('80vp')
        .borderWidth(2)
        .borderColor("#f1f1f1")
      Row({ space: 10 }) {
        Text(this.userInfo.nickname)
          .fontColor(Color.White)
          .fontSize("20sp")
        Text("技术部")
          .fontColor("#6a6bcd")
          .backgroundColor("#d5d5ff")
          .fontSize("16sp")
          .padding({ top: 3, bottom: 3, left: 5, right: 5 })
          .borderRadius(3)
      }

      Text("工号：25021")
        .fontColor(Color.White)
        .fontSize("14sp")
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .backgroundColor('#4749a1')
    .width('100%')
    .height('250vp')
    .borderRadius({ bottomLeft: 20, bottomRight: 20 })
  }

  @Builder buildAccumulateInfo() {
    Row() {
      Column() {
        Text("累计年假")
          .fontColor("#8889d0")
          .fontSize("12sp")
        Text("15")
          .fontColor("#4749a1")
          .fontSize("18sp")
          .fontWeight(800)
      }
      .height('100%')
      .justifyContent(FlexAlign.SpaceEvenly)

      Column() {
        Text("累计病假")
          .fontColor("#8889d0")
          .fontSize("12sp")
        Text("15")
          .fontColor("#4749a1")
          .fontSize("18sp")
          .fontWeight(800)
      }
      .height('100%')
      .justifyContent(FlexAlign.SpaceEvenly)

      Column() {
        Text("累计调休")
          .fontColor("#8889d0")
          .fontSize("12sp")
        Text("15")
          .fontColor("#4749a1")
          .fontSize("18sp")
          .fontWeight(800)
      }
      .height('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .justifyContent(FlexAlign.SpaceAround)
    .height('80vp')
    .width('94%')
    .borderRadius(10)
    .backgroundColor(Color.White)
    .margin({
      top: -20
    })
    // .offset({
    //   y: -20
    // })
  }

  @Builder buildCellGroup() {
    List() {
      ListItemGroup() {
        ListItem() {
          ArrowCell({ icon: $rawfile("my/leave.png"), title: '我的请假' })
        }

        ListItem() {
          ArrowCell({ icon: $rawfile("my/approve.png"), title: '我的审批' })
        }

        ListItem() {
          ArrowCell({ icon: $rawfile("my/work.png"), title: '加班统计' })
        }

        ListItem() {
          ArrowCell({ icon: $rawfile("my/meeting.png"), title: '会议记录' })
        }

        ListItem() {
          ArrowCell({ icon: $rawfile("my/information.png"), title: '我的资料' })
        }

        ListItem() {
          ArrowCell({ icon: $rawfile("my/help.png"), title: '帮助中心' })
        }
      }
      .divider({ strokeWidth: 1, color: "#f7f7f7" }) // 每行之间的分界线
    }
    .margin({ top: 20 })
    .width('94%')
    .backgroundColor(Color.White)
    .borderRadius(10)
  }

  @Builder buildSetting() {
    List() {
      ListItem() {
        ArrowCell({ icon: $rawfile("my/setting.png"), title: '设置' })
      }
      .onClick(() => {
        router.pushUrl({
          url: "pages/My/Setting/Setting"
        })
      })
    }
    .margin({ top: 15, bottom: 15 })
    .width('94%')
    .backgroundColor(Color.White)
    .borderRadius(10)
  }

  build() {
    List() {
      // 1、构建头部
      this.buildHeader()
      // 2.累计信息
      this.buildAccumulateInfo()
      // cell信息相关
      this.buildCellGroup()
      // 设置相关
      this.buildSetting()
    }
    .alignListItem(ListItemAlign.Center)
    .backgroundColor("#f5f5f5")
    .width('100%')
    .height('100%')
  }
}

@Component
struct ArrowCell {
  icon: ResourceStr
  title: string

  build() {
    Row() {
      Row() {
        Image(this.icon)
          .width("40vp")
          .height("40pv")
        Text(this.title)
          .margin({ left: 10 })
      }

      Image($rawfile("common/arraw_right.png"))
        .width("20vp")
        .height("20pv")
    }
    .padding({ left: 10, right: 10 })
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .height("60vp")
  }
}