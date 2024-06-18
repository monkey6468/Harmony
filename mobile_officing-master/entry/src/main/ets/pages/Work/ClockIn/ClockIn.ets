import { NavBar } from '../../../components/NavBar'

@Entry
@Component
struct ClockIn {
  @Builder buildHeader() {
    Row() {
      Image($rawfile("common/avatar2.png"))
        .objectFit(ImageFit.Fill)
        .width(50)
        .height(50)
        .borderRadius(25)

      Column() {
        Row() {
          Text("许夏天")
            .fontColor("#101010")
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
          Text("12月8日 星期四")
            .fontColor('#969896')
        }
        .padding({ left: 20 })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text("技术部-成员")
            .fontColor('#969896')
          Text("考勤规则")
            .padding({
              left: 5,
              right: 5,
              top: 2,
              bottom: 2
            })
            .fontColor('#5d67c2')
            .borderWidth(1)
            .borderColor('#5d67c2')
            .borderRadius(3)
          Text("申请")
            .padding({
              left: 5,
              right: 5,
              top: 2,
              bottom: 2
            })
            .fontColor('#fff')
            .borderWidth(1)
            .borderColor('#ff5f35')
            .backgroundColor('#ff5f35')
            .borderRadius(3)
        }
        .padding({ left: 20 })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
      .height('100%')
      .padding({
        left: 15,
        right: 15,
        top: 10,
        bottom: 10
      })
    }
    .padding({
      left: 15
    })
    .backgroundColor(Color.White)
    .width('100%')
    .height(80)
    .borderRadius(8)
  }

  @Builder buildContent() {
    Column(){
      // 上班时间
      Row() {
        Text()
          .backgroundColor('#4749a1')
          .width(10)
          .height(10)
          .borderRadius(5)
        Text("上班时间 09:00")
          .margin(
            { left: 15 }
          )
          .fontSize(14)
          .fontColor('#101010')
      }
      .width('100%')
      .height(40)

      Row() {
        Column() {
          Text("上班打卡\n\n08:50") {
          }
          .fontColor(Color.White)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .backgroundColor('#4749a1')
          .width(120)
          .height(120)
          .borderRadius(60)

          Row() {
            Image($rawfile("common/address.png"))
              .width(20)
              .height(20)

            Text("华为深圳软件研发基地")
              .fontColor('#676767')
              .margin({
                left: 10
              })
          }
          .margin({
            top: 20
          })
        }
      }
      .justifyContent(FlexAlign.Center)
      .height(180)
      .width('100%')
      .margin({
        bottom: 20
      })

      // 下班时间
      Row() {
        Text()
          .backgroundColor('#ffb867')
          .width(10)
          .height(10)
          .borderRadius(5)
        Text("上班时间 18:00")
          .margin(
            { left: 15 }
          )
          .fontSize(14)
          .fontColor('#101010')
      }
      .width('100%')
      .height(40)

      Row() {
        Column() {
          Text("下班打卡\n\n18:30") {
          }
          .fontColor(Color.White)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .backgroundColor('#4749a1')
          .width(120)
          .height(120)
          .borderRadius(60)
          Row() {
            Image($rawfile("common/address.png"))
              .width(20)
              .height(20)

            Text("华为深圳软件研发基地")
              .fontColor('#676767')
              .margin({
                left: 10
              })
          }
          .margin({
            top: 20
          })
        }
      }
      .justifyContent(FlexAlign.Center)
      .height(180)
      .width('100%')
      .margin({
        bottom: 20
      })
    }
    .margin({
      top: 15
    })
    .backgroundColor(Color.White)
    .width('100%')
    .padding(15)
    .borderRadius(8)
  }

  build() {
    Column(){
      NavBar({title: "考勤打卡"})

      Column(){
        // 渲染头部
        this.buildHeader()

        // 渲染内容
        this.buildContent()
      }
      .padding(15)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}