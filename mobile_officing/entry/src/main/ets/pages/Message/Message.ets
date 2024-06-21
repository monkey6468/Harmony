import router from '@ohos.router'
interface ChatMessage {
  icon: ResourceStr
  name: string
  content: string
  time: string
  badge: number
}

@Component
export struct Message {
  @State currentIndex: number = 0
  @State messageList: ChatMessage[] = [
    {
      icon: '张',
      name: '张一山',
      content: '当前工作进度怎样了',
      time: '30分钟前',
      badge: 10
    },
    {
      icon: '李',
      name: '李华',
      content: '当前工作进度怎样了',
      time: '30分钟前',
      badge: 1
    },
    {
      icon: '赵',
      name: '赵雯',
      content: '是这样的，还有哪些不明白',
      time: '2022-10-30',
      badge: 0
    }
  ]
  @State platformMessageList: ChatMessage[] = [
    {
      icon: $rawfile("message/meeting.png"),
      name: '工作通知',
      content: '考勤打卡：8:59 成功',
      time: '1小时前',
      badge: 2
    },
    {
      icon: $rawfile("message/notice1.png"),
      name: '待办事项',
      content: '许xx的请假申请请您审批',
      time: '1小时前',
      badge: 2
    },
    {
      icon: $rawfile("message/notice2.png"),
      name: '公告',
      content: '关于元旦放假通知',
      time: '1小时前',
      badge: 3
    },
    {
      icon: $rawfile("message/todo.png"),
      name: '通知',
      content: '关于元旦放假通知',
      time: '1小时前',
      badge: 1
    },
    {
      icon: $rawfile("message/metting2.png"),
      name: '会议提醒',
      content: '2022年12月8日上午10：00会议',
      time: '1小时前',
      badge: 2
    },
    {
      icon: $rawfile("message/notice1.png"),
      name: '待办事项',
      content: '许xx的请假申请请您审批',
      time: '1小时前',
      badge: 2
    }
  ]

  @Builder buildTop() {
    Row() {
      Text("消息")
        .fontColor(Color.White)
        .fontSize(26)
        .fontWeight(800)
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#4749a1')
    .width('100%')
    .height(80)
  }

  @Builder buildChatMessage(message: ChatMessage) {
    Row() {
      Text(message.icon)
        .fontSize(20)
        .backgroundColor('#6467d3')
        .fontColor(Color.White)
        .width(60)
        .height(60)
        .borderRadius(30)
        .textAlign(TextAlign.Center)
      Column() {
        Text(message.name)
          .fontColor('#101010')
          .fontSize(22)
          .fontWeight(800)
        Text(message.content)
          .fontColor('#9a9a9a')
          .fontSize(14)
      }
      .height('80%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 10 })

      Column() {
        Text(message.time)
          .fontColor('#9a9a9a')
          .fontSize(14)

        if (message.badge > 0) {
          Text(`${message.badge}`)
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .backgroundColor('#f99b2b')
            .fontColor(Color.White)
            .width(26)
            .height(26)
            .borderRadius(13)
        }
      }
      .height('80%')
      .width(100)
      .justifyContent(FlexAlign.SpaceAround)
    }
    .onClick(() => {
      router.pushUrl({
        url: "pages/Message/Chat/Chat"
      })
    })
    .height(120)
    .padding({
      left: 15,
      top: 15,
      bottom: 10,
      right: 5
    })
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

  // 消息列表
  @Builder buildMessageList() {
    List() {
      ForEach(this.messageList, (message: ChatMessage) => {
        this.buildChatMessage(message)
      })
    }
    .divider({
      color: '#f0f0f0',
      strokeWidth: 1
    })
    .height('100%')
    .backgroundColor('#f7f7f7')
  }

  @Builder buildPlatformMessage(message: ChatMessage) {
    Row() {
      Image(message.icon)
        .width(60)
        .height(60)
        .borderRadius(30)
      Column() {
        Text(message.name)
          .fontColor('#101010')
          .fontSize(22)
          .fontWeight(800)
        Text(message.content)
          .fontColor('#9a9a9a')
          .fontSize(14)
      }
      .height('80%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 15 })

      Column() {
        Text(message.time)
          .fontColor('#9a9a9a')
          .fontSize(14)

        if (message.badge > 0) {
          Text(`${message.badge}`)
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .backgroundColor('#f99b2b')
            .fontColor(Color.White)
            .width(26)
            .height(26)
            .borderRadius(13)
        }
      }
      .height('80%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .backgroundColor(Color.White)
    .borderRadius(10)
    .height(100)
    .padding({
      left: 15,
      top: 15,
      bottom: 10,
      right: 5
    })
  }

  @Builder buildPlatformMessageList() {
    Column() {
      Search({ placeholder: '搜索' })
        .width('90%')
        .height(46)
        .borderRadius(15)
        .margin({ top: 15 })

      List({ space: 15 }) {
        ForEach(this.platformMessageList, (message: ChatMessage) => {
          ListItem() {
            this.buildPlatformMessage(message)
          }
        })
      }
      .padding(15)
      .alignListItem(ListItemAlign.Center)
      .layoutWeight(1)
    }
    .height('100%')
  }

  @Builder buildTopTab() {
    Tabs({ barPosition: BarPosition.Start }) {
      TabContent() {
        this.buildMessageList()
      }.tabBar(this.TabItemBuilder(0, '消息中心'))

      TabContent() {
        this.buildPlatformMessageList()
      }.tabBar(this.TabItemBuilder(1, '平台消息'))
    }
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