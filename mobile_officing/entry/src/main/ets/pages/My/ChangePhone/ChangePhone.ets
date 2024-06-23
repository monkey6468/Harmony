import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { NavBar } from '../../../components/NavBar'
import { User } from '../../../types/User'

@Entry
@Component
struct ChangePhone {
  @StorageLink("userInfo") userInfo: User = {} as User
  @State phone: string = ""

  build() {
    Column() {
      NavBar({ title: "" })

      Text("更换手机号")
        .fontSize(30)
        .fontColor('#101010')
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      Text("更换手机号后，下次登录可使用新的手机号码")
        .margin({
          top: 30
        })

      Row() {
        Text("您的当前手机号码  ")
        Text(`${this.userInfo.tel}`)
          .fontColor('#101010')
          .fontWeight(FontWeight.Bold)
      }
      .margin({
        top: 10
      })

      TextInput({
        placeholder: '填写新的手机号'
      })
        .onChange(value => {
          this.phone = value
        })
        .height(40)
        .borderRadius(0)
        .border({
          width: 1,
          color: '#c7c7c7'
        })
        .margin({
          top: 20
        })

      Row() {
        Button("下一步")
          .focusOnTouch(true)
          .type(ButtonType.Normal)
          .backgroundColor('#4749a1')
          .fontColor(Color.White)
          .borderRadius(5)
          .fontSize(20)
          .width(180)
          .height(50)
          .margin({
            top: 20
          })
          .onClick(() => {
            if (this.phone.trim() === '') {
              promptAction.showToast({
                message: "手机号不能为空",
                duration: 500
              })
              return
            }

            const reg = /^1[3-9]\d{9}$/
            if (!reg.test(this.phone)) {
              promptAction.showToast({
                message: "手机号不合法",
                duration: 500
              })
              return
            }
            console.log("----更新手机号")
            router.pushUrl({
              url: "pages/My/ChangePhone2/ChangePhone2",
              params: {
                phone: this.phone
              }
            })
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