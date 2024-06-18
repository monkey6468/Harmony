import router from '@ohos.router'
import { NavBar } from '../../../components/NavBar'
import { Notice } from '../../../types/Notice'
import { BASEURL } from '../../../utils/Request'
import web_webview from '@ohos.web.webview'

@Entry
@Component
struct NoticeDetail {
  @State notice: Notice = {} as Notice
  webViewController: web_webview.WebviewController = new web_webview.WebviewController()

  aboutToAppear() {
    this.notice = router.getParams() as Notice
  }

  @Builder buildTitle() {
    Column() {
      Text(this.notice.title)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
      Row() {
        Text(`来源：${this.notice.publish_department}`)
          .fontSize(16)
          .fontColor('#888888')

        Text(this.notice.date)
          .fontSize(16)
          .fontColor('#888888')
          .margin({
            left: 80
          })
      }
      .width('100%')
      .margin({
        top: 20
      })
    }
    .alignItems(HorizontalAlign.Start)
    .margin({
      top: 15
    })
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
  }

  @Builder buildContent() {
    Web({ src: `${BASEURL}${this.notice.content}`, controller: this.webViewController })
      .width('100%')
      .layoutWeight(1)
      .margin({
        top: 15
      })
  }

  build() {
    Column() {
      NavBar({ title: "公司公告" })

      // 构建标题部分
      this.buildTitle()

      // 构建通知内容
      this.buildContent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}