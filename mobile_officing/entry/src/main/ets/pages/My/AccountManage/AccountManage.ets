import router from '@ohos.router'
import { NavBar } from '../../../components/NavBar'
import { User } from '../../../types/User'

@Entry
@Component
struct AccountManage {
 // @StorageLink("userInfo") userInfo: User = {} as User

  build() {
    Column() {
      NavBar({ title: "账号管理" })
      List() {
        ListItem() {
          Row() {
            Text("更换手机号")
            Row() {
              Text('geng huan')
              // Text(`${this.userInfo.tel.replace(/^(\d{3})\d+(\d{4})$/, "$1****$2")}`)
              Image($rawfile("common/arraw_right.png"))
                .width(28)
                .height(28)
            }
            .onClick(() => {
              router.pushUrl({
                url: "pages/My/ChangePhone/ChangePhone"
              })
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            router.pushUrl({
              url: "pages/My/ChangePhone/ChangePhone"
            })
          })
        }
        .height(60)

        ListItem() {
          Row() {
            Text("修改密码")
            Image($rawfile("common/arraw_right.png"))
              .width(28)
              .height(28)
          }
          .onClick(() => {
            router.pushUrl({
              url: 'pages/My/ChangePassword/ChangePassword'
            })
          })
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            router.pushUrl({
              url: "pages/My/ChangePassword/ChangePassword"
            })
          })
        }
        .height(60)
      }
      .divider({
        strokeWidth: 2
      })
    }
    .width('100%')
    .height('100%')
    .padding({
      left: 10,
      right: 10
    })
  }
}