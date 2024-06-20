import promptAction from '@ohos.promptAction'
import { NavBar } from '../../../components/NavBar'
import { changePassword } from '../../../api/User'
import router from '@ohos.router'

@Entry
@Component
struct ChangePassword {
  @State oldPassword: string = ''
  @State newPassword: string = ''
  @State reNewPassword: string = ''

  async submit() {
    if (this.oldPassword.trim().length < 6 || this.newPassword.length < 6) {
      promptAction.showToast({
        message: "密码长度至少是6位",
        duration: 800
      })
      return
    }

    if (this.newPassword.trim() !== this.reNewPassword.trim()) {
      promptAction.showToast({
        message: "新密码与确认密码不一致",
        duration: 800
      })
      return
    }

    const res = await changePassword({
      oldPassword: this.oldPassword,
      newPassword: this.newPassword
    })
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
      NavBar({ title: "修改密码" })

      List() {
        // 原密码
        ListItem() {
          Column() {
            Row() {
              Text("原密码")
                .fontSize(18)
                .fontColor('#101010')
                .width(80)
              TextInput({ placeholder: "请输入原来的密码" })
                .type(InputType.Password)
                .onChange(value => {
                  this.oldPassword = value
                })
                .margin({
                  left: 25
                })
                .border({
                  width: 0
                })
                .backgroundColor(Color.White)
            }

            Divider()
              .color('#f5f5f5')
              .margin({
                top: 10
              })
              .width('100%')
          }
          .width('100%')
        }
        .height(60)

        // 新密码
        ListItem() {
          Column() {
            Row() {
              Text("新密码")
                .fontSize(18)
                .fontColor('#101010')
                .width(80)
              TextInput({ placeholder: "请输入原来的密码" })
                .type(InputType.Password)
                .onChange(value => {
                  this.newPassword = value
                })
                .margin({
                  left: 25
                })
                .border({
                  width: 0
                })
                .backgroundColor(Color.White)
            }

            Divider()
              .color('#f5f5f5')
              .margin({
                top: 10
              })
              .width('100%')
          }
          .width('100%')
        }
        .height(60)

        // 确认密码
        ListItem() {
          Column() {
            Row() {
              Text("确认密码")
                .fontSize(18)
                .fontColor('#101010')
                .width(80)
              TextInput({ placeholder: "请输入原来的密码" })
                .type(InputType.Password)
                .onChange(value => {
                  this.reNewPassword = value
                })
                .margin({
                  left: 25
                })
                .border({
                  width: 0
                })
                .backgroundColor(Color.White)
            }

            Divider()
              .color('#f5f5f5')
              .margin({
                top: 10
              })
              .width('100%')
          }
          .width('100%')
        }
        .height(60)

        // 确定按钮
        ListItem() {
          Row() {
            Button("确定")
              .focusOnTouch(true)
              .type(ButtonType.Normal)
              .borderRadius(5)
              .backgroundColor('#4749a1')
              .height(50)
              .width('95%')
              .margin({
                top: 20
              })
              .onClick(() => {
                this.submit()
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
      }
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