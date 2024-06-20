import { Notice } from '../../../types/Notice'
import { getNoticeList } from '../../../api/Notice'
import { NavBar } from '../../../components/NavBar'
import router from '@ohos.router'

@Entry
@Component
struct NoticeList {
  @State noticeList: Notice[] = []

  async getNoticeListData() {
    const res = await getNoticeList()

    this.noticeList = res.data
  }

  aboutToAppear() {
    this.getNoticeListData()
  }

  @Builder buildNoticeItem(notice: Notice) {
    Column() {
      Row() {
        Text("")
          .width(20)
          .height(20)
          .borderRadius(10)
          .backgroundColor('#ff5f35')

        Text(notice.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({
            left: 20
          })
          .layoutWeight(1)
      }
      .width('100%')

      Row() {
        Text(notice.date.split(" ")[0])
          .fontSize(16)

        Text(`阅读：${notice.read_count}`)
      }
      .margin({
        top: 20
      })
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .padding({
      top: 20,
      bottom: 20
    })
    .onClick(() => {
      router.pushUrl({
        url: "pages/Work/NoticeDetail/NoticeDetail",
        params: notice
      })
    })
  }

  build() {
    Column() {
      NavBar({ title: "公司公告" })

      List() {
        ForEach(this.noticeList, (item: Notice) => {
          this.buildNoticeItem(item)
        })
      }
      .divider({
        strokeWidth: 1,
        color: '#e4e4e4',
      })
      .padding({
        left: 20,
        right: 20
      })
      .margin({
        top: 20
      })
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}