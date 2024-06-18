import router from '@ohos.router'
import PreferencesUtil from '../utils/PreferencesUtil'

@Entry
@Component
struct Index {
  @State time: number = 3
  timer: number = -1

  async enter() {
    const token = await PreferencesUtil.getToken()

    if (token) { // 登录了
      router.replaceUrl({
        url: "pages/Home/Home"
      })
    } else {
      router.replaceUrl({
        url: "pages/Login/Login"
      })
    }
  }

  onPageShow() {
    this.timer = setInterval(() => {
      this.time--
      if (this.time < 1) {
        // 跳转到登录页面
        this.enter()
        clearInterval(this.timer)
      }
    },1000)
  }

  build() {
    Stack({alignContent:Alignment.Bottom}){
      Stack({alignContent:Alignment.TopEnd}){
        Image($rawfile("index/launch-screen.png"))
          .width('100%')
          .height('100%')
        Row(){
          Text(`${this.time}`)
            .fontSize(30)
            .fontColor(Color.Gray)
            .width('100%')
            .textAlign(TextAlign.Center)
        }
        .width(50)
        .height(50)
        .borderRadius(25)
        .margin({
          top: 15,
          right: 15
        })
        .backgroundColor(Color.White)
      }

      Button("")
        .width(200)
        .height(50)
        .margin({
          bottom: 88
        })
        .onClick(() => {
          this.enter()
        })
        .backgroundColor(Color.Transparent)
    }
    .width('100%')
    .height('100%')
  }
}