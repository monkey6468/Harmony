import router from '@ohos.router'
import { NavBar } from '../../../components/NavBar'
import { getSmsCode, changePhone } from '../../../api/User'
import promptAction from '@ohos.promptAction'

@Entry
@Component
struct ChangePhone2 {
  @State message: string = 'Hello World'
  @State phone: string = ""
  @State code: string = ""
  @State time: number = 0
  timer: number = -1

  aboutToAppear() {
    this.phone = router.getParams()["phone"]
  }

  aboutToDisappear() {
    clearInterval(this.timer)
  }

  /**
   * 倒计时 & 发送请求
   */
  async getPhoneCode() {
    if (this.time > 0) return

    this.time = 10
    this.timer = setInterval(() => {
      this.time--
      if (this.time <= 0) {
        clearInterval(this.timer)
        return
      }
    }, 1000)

    const res = await getSmsCode({
      phone: this.phone
    })

    if (res.code === 200) {
      promptAction.showToast({
        message: res.data.code + "",
        duration: 2000
      })
    }
  }

  async submit() {
    const reg = /^1[3-9]\d{9}$/
    if (!reg.test(this.phone)) {
      promptAction.showToast({
        message: "手机号不合法",
        duration: 800
      })
      return
    }

    if (this.code.trim().length === 0) {
      promptAction.showToast({
        message: "验证码不能为空",
        duration: 800
      })
      return
    }

    const res = await changePhone({ phone: this.phone, code: this.code })

    promptAction.showToast({
      message: res.message,
      duration: 800
    })
    if (res.code === 200) {
      setTimeout(() => {
        router.replaceUrl({
          url: "pages/Login/Login"
        })
      }, 800)
    }
  }

  build() {
    Column() {
      NavBar({ title: "" })

      Text("验证手机号码")
        .fontSize(30)
        .fontColor('#101010')
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      Text("我们已发送手机验证短信到")
        .margin({
          top: 30
        })

      Row() {
        Text("手机号码 ")
        Text(`${this.phone}`)
          .fontColor('#101010')
          .fontWeight(FontWeight.Bold)
      }
      .margin({
        top: 10
      })

      Row() {
        TextInput({
          placeholder: '请输入手机验证码'
        })
          .onChange(value => {
            this.code = value
          })
          .height(40)
          .border({
            width: 0
          })
          .backgroundColor(Color.White)
          .layoutWeight(1)

        if (this.time > 0) {
          Text(`${this.time}S之后重试`).fontColor('#bfbfbf')
        } else {
          Text('获取验证码').fontColor('#101010')
            .onClick(() => {
              this.getPhoneCode()
            })
        }
      }
      .padding(5)
      .border({
        width: 1,
        color: '#c7c7c7'
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({
        top: 20
      })

      Row() {
        Button("提交")
          .onClick(() => {
            this.submit()
          })
          .type(ButtonType.Normal)
          .focusOnTouch(true)
          .backgroundColor('#4749a1')
          .fontColor(Color.White)
          .borderRadius(5)
          .fontSize(20)
          .width(180)
          .height(50)
          .margin({
            top: 20
          })
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .padding({
      left: 10,
      right: 10
    })
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
  }
}