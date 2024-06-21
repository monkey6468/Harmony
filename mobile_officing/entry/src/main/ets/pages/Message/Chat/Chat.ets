import { NavBar } from '../../../components/NavBar'
import { Message } from '../../../types/Message'
import webSocket from '@ohos.net.webSocket'
import promptAction from '@ohos.promptAction'
import { uploadFile } from '../../../utils/FileUtil'
import picker from '@ohos.file.picker'

@Entry
@Component
struct Chat {
  @State textFocusable: boolean = true
  @State friendName: string = "张一山"
  @State messageList: Message[] = []
  @State isSendMedia: boolean = false
  @State sendContent: string = ''
  @State hasMore: boolean = true
  room = "30908286-466b-485e-b673-332db053bd18"
  page: number = 1
  pageSize: number = 5
  listScroller: Scroller = new Scroller()
  private ws = null

  aboutToAppear() {
    var defaultIpAddress = `ws://119.91.151.46:3001/api/chat/connect?room=${this.room}&id=user_b7d8955c-8339-458e-a13b-461b1271e5d4&type=private`
    this.ws = webSocket.createWebSocket()

    this.ws.on('open', (err, value) => {
      console.log("on open, status:" + value['status'] + ", message:" + value['message'])
    })

    this.ws.on('message', (err, value) => {
      console.log('---message exec---', this.page)
      // 处理服务器返回的聊天记录
      if (!err) {
        if (value.length >= 3900) {
          promptAction.showToast({
            message: "服务器返回数据过多",
            duration: 2000
          })
          return
        }

        const obj = JSON.parse(value)
        if (obj.code === 200 || obj.code === 201) {
          if (obj.type === 'list' && obj.historyMsgList && obj.historyMsgList.length > 0) {
            this.messageList = [...this.messageList, ...obj.historyMsgList]
          } else if (obj.type === 'other') {
            this.messageList.push(obj.data)
          }
        } else if (obj.code === 404) {
          this.hasMore = false
        }
      } else {
        console.log('---error---', JSON.stringify(err))
      }
    })

    this.ws.on('close', (err, value) => {
      console.log("on close, code is " + value.code + ", reason is " + value.reason);
    })

    this.ws.on('error', (err) => {
      console.log("on error, error:" + JSON.stringify(err));
    })

    this.ws.connect(defaultIpAddress, (err, value) => {
      if (!err) {
        console.log("connect success");
      } else {
        console.log("connect fail, err:" + JSON.stringify(err));
      }
    })

    setTimeout(() => {
      this.getNewMessageListData()
    }, 200)
  }

  // 获取新的聊天记录
  getNewMessageListData() {
    if (!this.hasMore) return
    // 给服务器发送websocket请求，请求第二页或是以后页数的数据
    this.page++

    const message = {
      type: 'getNewMessageList',
      page: this.page,
      pageSize: this.pageSize,
      room: this.room
    }

    // 发websocket请求给服务器了
    this.ws.send(JSON.stringify(message))
  }

  // 发送文本消息
  sendTextMessage() {
    if (this.sendContent.trim() === '') {
      promptAction.showToast({
        message: "消息内容不能为空",
        duration: 800
      })
      return
    }

    // 准备好消息的内容，然后发送websocket请求给服务器
    const message: Message = {
      content: this.sendContent,
      media_type: "text",
      receiver_id: "user_da8add51-4bcc-4d82-a4c3-dcd7a44b527b",
      room: this.room,
      sender_id: "user_b7d8955c-8339-458e-a13b-461b1271e5d4",
      is_sender: true,
      status: 1,
      type: "private",
      avatar: "https://img2.baidu.com/it/u=1477138556,2382360194&fm=253&fmt=auto&app=138&f=JPEG?w=400&h=400",
      nickname: "王文元",
      created_at: new Date(),
    }

    this.ws.send(JSON.stringify(message))

    // 清空输入的内容
    this.sendContent = ''

    setTimeout(() => {
      this.listScroller.scrollToIndex(this.messageList.length - 1)
    }, 200)
  }

  // 发送图片消息
  async sendImageMessage() {
    const uploadImageUrl = await uploadFile()

    const message: Message = {
      content: uploadImageUrl,
      media_type: "image",
      receiver_id: "user_da8add51-4bcc-4d82-a4c3-dcd7a44b527b",
      room: this.room,
      sender_id: "user_b7d8955c-8339-458e-a13b-461b1271e5d4",
      is_sender: true,
      status: 1,
      type: "private",
      avatar: "https://img2.baidu.com/it/u=1477138556,2382360194&fm=253&fmt=auto&app=138&f=JPEG?w=400&h=400",
      nickname: "张三",
      created_at: new Date(),
    }

    this.ws.send(JSON.stringify(message))
    setTimeout(() => {
      this.listScroller.scrollToIndex(this.messageList.length - 1)
    }, 200)
  }

  // 发送视频消息
  async sendVideoMessage() {
    const uploadVideoUrl = await uploadFile(picker.PhotoViewMIMETypes.VIDEO_TYPE)

    const message: Message = {
      content: uploadVideoUrl,
      media_type: "video",
      receiver_id: "user_da8add51-4bcc-4d82-a4c3-dcd7a44b527b",
      room: this.room,
      sender_id: "user_b7d8955c-8339-458e-a13b-461b1271e5d4",
      is_sender: true,
      status: 1,
      type: "private",
      avatar: "https://img2.baidu.com/it/u=1477138556,2382360194&fm=253&fmt=auto&app=138&f=JPEG?w=400&h=400",
      nickname: "张三",
      created_at: new Date(),
    }

    // 发送给服务器
    this.ws.send(JSON.stringify(message))
    setTimeout(() => {
      this.listScroller.scrollToIndex(this.messageList.length - 1)
    }, 200)
  }

  @Builder buildFooter() {
    Column() {
      // 输入框部分
      Row() {
        Image($rawfile("message/voice1.png"))
          .width(38)
          .height(38)

        TextInput({
          placeholder: "输入聊天内容",
          text: this.sendContent
        })
          .onClick(() => {
            this.textFocusable = true
            setTimeout(() => {
              this.listScroller.scrollToIndex(this.messageList.length - 1)
            }, 200)
          })
          .focusable(this.textFocusable)
          .focusOnTouch(true)
          .height('100%')
          .layoutWeight(1)
          .onFocus(() => {
            this.isSendMedia = false
          })
          .onChange(value => {
            this.sendContent = value
          })

        if (this.sendContent.trim().length > 0) {
          Button("发送")
            .backgroundColor('#4749a1')
            .fontColor(Color.White)
            .margin({
              left: 10
            })
            .type(ButtonType.Normal)
            .borderRadius(5)
            .focusOnTouch(true)
            .onClick(() => {
              this.sendTextMessage()
            })
        } else {
          Image($rawfile("message/smile1.png"))
            .width(46)
            .height(46)
            .objectFit(ImageFit.Fill)
            .margin({
              left: 5,
              right: 5
            })

          Text("+")
            .backgroundColor('#000000')
            .fontColor(Color.White)
            .width(30)
            .height(30)
            .borderRadius(15)
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .focusOnTouch(true)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.isSendMedia = !this.isSendMedia

              this.textFocusable = false
            })
        }

      }
      .borderWidth({
        top: 1
      })
      .borderColor({
        top: '#f5f5f5'
      })
      .height(60)
      .padding(10)
      .width('100%')
      .backgroundColor(Color.White)

      if (this.isSendMedia) {
        Row() {
          Column() {
            Image($rawfile("message/image1.png"))
              .width(46)
              .height(38)
            Text('图片')
              .margin({
                top: 5
              })
              .fontColor('#101010')
              .fontSize(18)
          }
          .onClick(() => {
            this.sendImageMessage()
          })
          .margin({ left: 20 })

          Column() {
            Image($rawfile("message/photo1.png"))
              .width(46)
              .height(38)
            Text('视频')
              .margin({
                top: 5
              })
              .fontColor('#101010')
              .fontSize(18)
          }
          .onClick(() => {
            this.sendVideoMessage()
          })
          .margin({ left: 30 })
        }
        .backgroundColor(Color.White)
        .width('100%')
        .height(120)
      }
    }
  }

  @Builder buildMessageTime(message: Message) {
    Row() {
      Text(message.content)
        .fontColor('#99a7c6')
        .fontSize(12)
    }
    .height(40)
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildLeftMessage(message: Message) {
    Row() {
      Text(message.nickname.substring(0, 1))
        .fontColor(Color.White)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#6467d3')
        .width(50)
        .height(50)
        .borderRadius(25)
        .textAlign(TextAlign.Center)

      if (message.media_type === 'text') {
        Text(message.content) {

        }
        .fontSize(14)
        .fontColor('#000000')
        .padding({
          left: 10,
          top: 15,
          bottom: 15,
          right: 10
        })
        .borderWidth(1)
        .margin({
          left: 20
        })
        .borderRadius(5)
        .borderColor('#e3e3e3')
      } else if (message.media_type === 'image') {
        Row() {
          Image(message.content)
            .objectFit(ImageFit.Auto)
            .width(140)
            .height(140)
            .padding(5)
        }
        .borderWidth(1)
        .margin({
          left: 20
        })
        .borderRadius(5)
        .borderColor('#e3e3e3')
      } else if (message.media_type === 'video') {
        Row() {
          Video({ src: message.content })
            .objectFit(ImageFit.Auto)
            .width(180)
            .height(180)
            .padding(5)
        }
        .borderWidth(1)
        .margin({
          left: 20
        })
        .borderRadius(5)
        .borderColor('#e3e3e3')
      }

      Text(message.status === 1 ? '未读' : '已读')
        .fontSize(14)
        .fontColor('#6f6f6f')
        .margin({
          left: 15
        })
        .alignSelf(ItemAlign.Center)
    }
    .alignItems(VerticalAlign.Top)
    .padding(10)
    .width('100%')
    .height(message.media_type === 'text' ? 80 : message.media_type === 'video' ? 200 : 160)
  }

  @Builder buildRightMessage(message: Message) {
    Row() {
      Text(message.status === 1 ? '未读' : '已读')
        .fontSize(14)
        .fontColor('#6f6f6f')
        .margin({
          right: 15
        })
        .alignSelf(ItemAlign.Center)

      if (message.media_type === 'text') {
        Text(message.content)
          .fontSize(14)
          .fontColor('#000000')
          .padding({
            left: 10,
            top: 15,
            bottom: 15,
            right: 10
          })
          .margin({
            right: 20
          })
          .borderRadius(5)
          .backgroundColor('#f5f3f3')
      } else if (message.media_type === 'image') {
        Row() {
          Image(message.content)
            .objectFit(ImageFit.Auto)
            .width(140)
            .height(140)
            .padding(5)
        }
        .borderWidth(1)
        .margin({
          right: 20
        })
        .borderRadius(5)
        .borderColor('#e3e3e3')
        .height('100%')
      } else if (message.media_type === 'video') {
        Row() {
          Video({ src: message.content })
            .objectFit(ImageFit.Auto)
            .width(180)
            .height(180)
            .padding(5)
        }
        .borderWidth(1)
        .margin({
          right: 20
        })
        .borderRadius(5)
        .borderColor('#e3e3e3')
        .height('100%')
      }

      Text(message.nickname.substring(0, 1))
        .fontColor(Color.White)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#6467d3')
        .width(50)
        .height(50)
        .borderRadius(25)
        .textAlign(TextAlign.Center)
    }
    .alignItems(VerticalAlign.Top)
    .padding(10)
    .width('100%')
    .height(message.media_type === 'text' ? 80 : message.media_type === 'video' ? 200 : 160)
    .justifyContent(FlexAlign.End)
  }

  @Builder buildMessageList() {
    List({ scroller: this.listScroller }) {
      ForEach(this.messageList, (message: Message) => {
        ListItem() {
          if (message.media_type === 'time') {
            this.buildMessageTime(message)
          } else {
            if (message.is_sender) {
              this.buildRightMessage(message)
            } else {
              this.buildLeftMessage(message)
            }
          }
        }
      })
    }
    .onReachEnd(() => {
      this.getNewMessageListData()
    })
    .width('100%')
    .height('100%')
    .padding({
      bottom: this.isSendMedia ? 240 : 120
    })
  }

  build() {
    Stack({ alignContent: Alignment.End }) {
      Column() {
        // 1、标题栏
        NavBar({
          title: this.friendName
        })

        // 2、聊天消息
        this.buildMessageList()
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)

      // 3、底部区域
      this.buildFooter()
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.BottomEnd)
    .backgroundColor(Color.White)
  }
}