import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { login } from '../../api/User'

@Entry
@Component
struct Login {
  @State loginname: string = '17704051019'
  @State password: string = '123456'

  async onLogin(){
    /*
登录 API 接口详见接口文档
登录账号：
17704051019 123456
13811112222 123456
13911111111 123456
**/
    console.log("----login----",this.loginname, this.password)
    // 校验手机号和密码
    const loginNameRegex = /^1[3-9]\d{9}$/
    if (!loginNameRegex.test(this.loginname)) {
      promptAction.showToast({
        message: '手机号不合法',
        duration: 500,
        bottom: 100
      })
      return
    }

    const passwordRegex = /^\d{6,16}$/
    if (!passwordRegex.test(this.password)) {
      promptAction.showToast({
        message: '密码要6-16位',
        duration: 500,
        bottom: 100
      })
      return
    }

    const res = await login({
      loginname:this.loginname,
      password:this.password,
    })

    console.log("---res----",res)
  }

  build() {
    Column() {
      Image($rawfile("login/login1.png"))
        .objectFit(ImageFit.Fill)
        .width('100%')
        .height(300)

      Column() {
        // 账号输入框
        Row() {
          Image($rawfile('login/phone.png'))
            .width(20)
            .height(30)
            .margin({ left: 10 })
          TextInput({
            placeholder: "请输入账号",
            text:this.loginname
          })
            .height("100%")
            .layoutWeight(1)
            .borderRadius(0)
            .backgroundColor(Color.White)
            .onChange(value=>{
              this.loginname = value
            })
        }
        .borderWidth(1)
        .borderColor("#d5d5d5")
        .height(50)
        .width('90%')
        .borderRadius(0)
        .margin({ top: 30 })

        // 密码输入框
        Row() {
          Image($rawfile('login/password.png'))
            .width(20)
            .height(30)
            .margin({ left: 10 })
          TextInput({
            placeholder: "请输入密码",
            text:this.password
          })
            .type(InputType.Password)
            .height("100%")
            .layoutWeight(1)
            .borderRadius(0)
            .backgroundColor(Color.White)
            .onChange(value=>{
                this.password = value
            })
        }
        .borderWidth(1)
        .borderColor("#d5d5d5")
        .height(50)
        .width('90%')
        .borderRadius(0)
        .margin({ top: 30 })

        // 登录按钮
        Button('登录')
          .backgroundColor("#4749a1")
          .height(60)
          .width('85%')
          .margin({ top: 30 })
        .onClick(()=>{
          this.onLogin()
        })

        Row() {
          Text("登录及代表同意")
            .fontColor("#919191")
          Text("《用户协议》")
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              console.log("------点击了用户协议-------")
            })
          Text("和")
            .fontColor("#919191")
          Text("《隐私协议》")
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              console.log("------点击了隐私协议-------")
            })
        }.margin({ top: 40 })
      }
      .backgroundColor(Color.White)
      .borderRadius(5)
      .width("94%")
      .height(350)
      .margin({
        top: -50
      })

      Text("忘记密码")
        .fontColor("#4749a1")
        .margin({ top: 120 })
        .onClick(() => {
          router.pushUrl({
            url: "pages/ForgetPassword/ForgetPassword"
          })
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor("#f5f5f5")
  }
}