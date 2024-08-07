import { authStore, getTimeText, HdClockIn, hdHttp, HdUser } from '@itcast/basic'
import { promptAction, router } from '@kit.ArkUI'
import { OptionalRouterParams, OptionalType } from './OptionalComp'

interface Nav {
  icon: ResourceStr
  name: string
  onClick?: () => void
  other?: string
}

interface Tool {
  icon: ResourceStr
  name: string
  value?: string
  onClick?: () => void
}

@Component
export struct MineComp {
  @StorageProp('topHeight')
  topHeight: number = 0
  @StorageProp('user')
  user: HdUser = {} as HdUser
  @StorageProp('colorMode')
  colorMode: number = -1
  @State
  isPreview: boolean = false

  @Builder
  navBuilder(nav: Nav) {
    GridCol() {
      Column() {
        Image(nav.icon)
          .width(30)
          .aspectRatio(1)
          .margin({ bottom: 10 })
        Text(nav.name)
          .fontSize(14)
          .fontColor($r('app.color.common_gray_03'))
          .margin({ bottom: 4 })
        if (nav.other) {
          Row() {
            Text(nav.other)
              .fontSize(12)
              .fontColor($r('app.color.common_gray_01'))
            Image($r('sys.media.ohos_ic_public_arrow_right'))
              .width(12)
              .aspectRatio(1)
              .fillColor($r('app.color.common_gray_01'))
          }
        }
      }
      .onClick(() => {
        nav.onClick && nav.onClick()
      })
    }
  }

  @Builder
  toolsBuilder(tool: Tool) {
    Row() {
      Image(tool.icon)
        .width(16)
        .aspectRatio(1)
        .margin({ right: 12 })
      Text(tool.name)
        .fontSize(14)
      Blank()
      if (tool.value) {
        Text(tool.value)
          .fontSize(12)
          .fontColor($r('app.color.common_gray_01'))
      }
      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(16)
        .aspectRatio(1)
        .fillColor($r('app.color.common_gray_01'))
    }
    .height(50)
    .width('100%')
    .padding({ left: 16, right: 10 })
    .onClick(() => {
      tool.onClick && tool.onClick()
    })
  }

  @Builder
  AvatarPreviewBuilder() {
    Image(this.user.avatar)
      .objectFit(ImageFit.Contain)
      .onClick(() => {
        this.isPreview = false
      })
  }

  build() {
    Column({ space: 16 }) {
      Row({ space: 12 }) {
        Image(this.user.avatar || $r('app.media.ic_mine_avatar'))
          .alt($r('app.media.ic_mine_avatar'))
          .width(55)
          .aspectRatio(1)
          .borderRadius(55)
          .bindContentCover($$this.isPreview, this.AvatarPreviewBuilder, {
            modalTransition: ModalTransition.ALPHA,
            backgroundColor: '#000000'
          })
          .onClick(() => {
            if (this.user.avatar) {
              this.isPreview = true
            }
          })
        if (this.user && this.user.token) {
          Column({ space: 4 }) {
            Text(this.user.nickName || this.user.username)
              .fontSize(18)
              .fontWeight(500)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Row({ space: 4 }) {
              Text('编辑信息')
                .fontSize(12)
                .fontColor($r('app.color.common_gray_01'))
              Image($r('app.media.ic_mine_edit'))
                .width(12)
                .aspectRatio(1)
                .fillColor($r('app.color.common_gray_01'))
            }
            .onClick(() => {
              authStore.checkAuth({
                url: 'pages/ProfileEditPage'
              })
            })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        } else {
          Text('立即登录')
            .fontSize(18)
            .fontWeight(500)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/LoginPage'
              })
            })
        }

        HdClockIn({ clockCount: this.user.clockinNumbers })
          .onClick(() => {
            if (this.user?.token) {
              if (this.user.clockinNumbers) {
                router.pushUrl({ url: 'pages/ClockedPage' })
              } else {
                // 打卡
                hdHttp.post<Record<string, number>>('clockin').then(async (res) => {
                  promptAction.showToast({ message: '打卡成功' })
                  this.user.clockinNumbers = res.data.clockinNumbers
                  await authStore.setUser(this.user)
                  router.pushUrl({ url: 'pages/ClockedPage' })
                })
              }
            } else {
              router.pushUrl({ url: 'pages/LoginPage' })
            }
          })
      }
      .width('100%')
      .height(100)
      .margin({ top: this.topHeight })

      GridRow({ columns: 4 }) {
        this.navBuilder({
          icon: $r('app.media.ic_mine_history'), name: '历史记录', onClick: () => {
            authStore.checkAuth({
              url: 'pages/OptionalPage',
              params: { type: OptionalType.HISTORY } as OptionalRouterParams
            })
          }
        })
        this.navBuilder({
          icon: $r('app.media.ic_mine_collect'), name: '我的收藏', onClick: () => {
            authStore.checkAuth({
              url: 'pages/OptionalPage',
              params: { type: OptionalType.COLLECT } as OptionalRouterParams
            })
          }
        })
        this.navBuilder({
          icon: $r('app.media.ic_mine_like'), name: '我的点赞', onClick: () => {
            authStore.checkAuth({
              url: 'pages/OptionalPage',
              params: { type: OptionalType.LIKE } as OptionalRouterParams
            })
          }
        })
        this.navBuilder({
          icon: $r('app.media.ic_mine_study'),
          name: '累计学时',
          other: getTimeText(this.user.totalTime),
          onClick: () => {
            authStore.checkAuth({
              url: 'pages/StudyTimePage'
            })
          }
        })
      }
      .backgroundColor($r('app.color.white'))
      .padding(16)
      .borderRadius(8)

      Column() {
        this.toolsBuilder({
          icon: $r('app.media.ic_mine_notes'), name: '开发常用词', onClick: () => {
            authStore.checkAuth({
              url: 'pages/WordPage'
            })
          }
        })
        this.toolsBuilder({ icon: $r('app.media.ic_mine_ai'), name: '面通AI' })
        this.toolsBuilder({ icon: $r('app.media.ic_mine_invite'), name: '推荐分享' })
        this.toolsBuilder({ icon: $r('app.media.ic_mine_file'), name: '意见反馈' })
        this.toolsBuilder({ icon: $r('app.media.ic_mine_info'), name: '关于我们' })
        this.toolsBuilder({
          icon: $r('app.media.ic_mine_setting'), name: '设置', onClick: () => {
            authStore.checkAuth({
              url: 'pages/SettingsPage'
            })
          }
        })
      }
      .backgroundColor($r('app.color.white'))
      .borderRadius(8)

    }
    .padding($r('app.float.common_gutter'))
    .backgroundColor($r('app.color.common_gray_bg'))
    .linearGradient({
      colors: [[this.colorMode === 1 ? '#FFB071' : '#ff8533', 0], [$r('app.color.common_gray_bg'), 0.3], [$r('app.color.common_gray_bg'), 1]]
    })
    .width('100%')
    .height('100%')
  }
}