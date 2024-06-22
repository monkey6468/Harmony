import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { NavBar } from '../../../components/NavBar'
import PreferencesUtil from '../../../utils/PreferencesUtil'

@Entry
@Component
struct Setting {
  logout() {
    promptAction.showDialog({
      title: "温馨提示",
      message: "确定退出吗?",
      buttons: [
        {
          text: '取消',
          color: '#2b2b2b'
        },
        {
          text: '确定',
          color: '#ff0000'
        }
      ]
    })
      .then(obj => {
        if (obj.index === 1) { // 点击了确认
          // 清空token
          PreferencesUtil.saveToken("")
          // 跳转到登录页面
          router.replaceUrl({
            url: "pages/Login/Login"
          })
        }
      })
  }

  @Builder buildAccount() {
    Row() {
      Text("账号管理")
      Image($rawfile("common/arraw_right.png"))
        .width(30)
        .height(30)
    }
    .onClick(() => {
      router.pushUrl({
        url: "pages/My/AccountManage/AccountManage"
      })
    })
    .width('100%')
    .padding({
      top: 10,
      bottom: 10,
      left: 15,
      right: 15
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
    .margin({
      top: 15
    })
  }

  @Builder buildAboutUs() {
    Column() {
      Row() {
        Text("隐私协议")
        Image($rawfile("common/arraw_right.png"))
          .width(30)
          .height(30)
      }
      .width('100%')
      .padding(10)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor(Color.White)

      Divider()
        .height(2)
        .color('#f2f2f2')

      Row() {
        Text("关于我们")
        Image($rawfile("common/arraw_right.png"))
          .width(30)
          .height(30)
      }
      .width('100%')
      .padding(10)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor(Color.White)

    }
    .width('100%')
    .padding(5)
    .backgroundColor(Color.White)
    .margin({
      top: 15
    })
  }

  @Builder buildVersion() {
    Column() {
      Row() {
        Text("意见反馈")
        Image($rawfile("common/arraw_right.png"))
          .width(30)
          .height(30)
      }
      .width('100%')
      .padding(10)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor(Color.White)

      Divider()
        .height(2)
        .color('#f2f2f2')

      Row() {
        Text("版本")
        Image($rawfile("common/arraw_right.png"))
          .width(30)
          .height(30)
      }
      .width('100%')
      .padding(10)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor(Color.White)

    }
    .width('100%')
    .padding(5)
    .backgroundColor(Color.White)
    .margin({
      top: 15
    })
  }

  @Builder buildLogout() {
    Button("退出")
      .fontColor('#5a5c59')
      .fontSize(20)
      .width('85%')
      .height(60)
      .borderRadius(8)
      .type(ButtonType.Normal)
      .backgroundColor(Color.White)
      .margin({
        top: 20
      })
      .onClick(() => {
        this.logout()
      })
  }

  build() {
    Column() {
      NavBar({ title: "设置" })
      // 账号管理
      this.buildAccount()
      // 关于我们
      this.buildAboutUs()
      // 版本
      this.buildVersion()
      // 退出
      this.buildLogout()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}