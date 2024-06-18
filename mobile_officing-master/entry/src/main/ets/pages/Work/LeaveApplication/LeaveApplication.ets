import { NavBar } from '../../../components/NavBar'
import promptAction from '@ohos.promptAction'
import { addProcess } from '../../../api/Process'
import router from '@ohos.router'

@Entry
@Component
struct LeaveApplication {
  private typies = [
    { value: '年假' },
    { value: '事假' },
    { value: '病假' },
    { value: '调休' },
    { value: '婚假' },
    { value: '其他' }
  ]
  private type: string = ''
  private reason: string = ''

  // 提交
  submit = async () => {
    if (this.type === '') {
      promptAction.showToast({
        message: "请假类型不能为空",
        duration: 800,
        bottom: 400
      })
      return
    }
    if (this.reason === '') {
      promptAction.showToast({
        message: "请假事由不能为空",
        duration: 800,
        bottom: 400
      })
      return
    }

    // 准备好数据
    const extraData = {
      "type_id": "1",
      "type": "请假申请",
      "department": "技术部",
      "reason": this.reason,
      "days": "1",
      "initiator": "张三"
    }

    const res = await addProcess(extraData)

    promptAction.showToast({
      message: res.message,
      duration: 800,
      bottom: 400
    })

    if (res.code === 200) {
      setTimeout(() => {
        router.replaceUrl({
          url: "pages/Work/MyApplyFor/MyApplyFor"
        })
      }, 1000)
    }
  }

  build() {
    Stack() {
      NavBar({ title: "请假申请" })
      // NavBar
      Stack() {
        List() {
          ListItem() {
            Column() {
              // 2、请假类型
              Row() {
                Text("请假类型")
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)

                Select(this.typies)
                  .onSelect(index => {
                    this.type = this.typies[index].value
                  })
                  .value('请选择')
                  .selected(1)
                  .font({ size: 20 })
                  .fontColor('#182431')
                  .selectedOptionFont({ size: 20, weight: 400 })
                  .optionFont({ size: 20, weight: 400 })
                  .selectedOptionBgColor('#f5f5f5')
                  .selectedOptionFontColor('#182431')
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .padding({
                left: 10,
                right: 10
              })
              .width('100%')
              .height(80)
              .backgroundColor(Color.White)

              // 3、请假事由
              Row() {
                Column() {
                  Text("请假事由")
                    .fontSize(28)
                    .fontWeight(FontWeight.Bold)
                    .width('100%')
                    .padding(10)
                  TextArea({ placeholder: "请输入" })
                    .onChange(value => {
                      this.reason = value
                    })
                    .margin({ top: 10 })
                    .placeholderFont({ size: 20 })
                    .fontSize(20)
                    .layoutWeight(1)
                    .borderRadius(0)
                    .backgroundColor(Color.White)
                }
              }
              .alignItems(VerticalAlign.Top)
              .margin({ top: 20 })
              .width('100%')
              .height(300)
              .backgroundColor(Color.White)

              // 4、审批流程
              Row() {
                Column() {
                  Text("审批流程")
                    .fontSize(28)
                    .fontWeight(FontWeight.Bold)
                    .width('100%')
                    .padding(10)
                  Row() {
                    Column() {
                      Text()
                        .width(60)
                        .height(60)
                        .borderRadius(30)
                        .backgroundColor('#587fea')
                      Text("发起人").fontSize(18)
                        .fontColor('#666666')
                        .margin({
                          top: 10
                        })
                    }
                    .height('100%')

                    Image($rawfile("common/arrow_right1.png"))
                      .objectFit(ImageFit.Cover)
                      .width(60)
                      .padding({ top: 10, left: 10, right: 10 })

                    Column() {
                      Text()
                        .width(60)
                        .height(60)
                        .borderRadius(30)
                        .backgroundColor('#587fea')
                      Text("部门领导").fontSize(18)
                        .fontColor('#666666')
                        .margin({
                          top: 10
                        })
                    }
                    .height('100%')

                    Image($rawfile("common/arrow_right1.png"))
                      .objectFit(ImageFit.Cover)
                      .width(60)
                      .padding({ top: 10, left: 10, right: 10 })
                    Column() {
                      Text()
                        .width(60)
                        .height(60)
                        .borderRadius(30)
                        .backgroundColor('#587fea')
                      Text("人事部").fontSize(18)
                        .fontColor('#666666')
                        .margin({
                          top: 10
                        })
                    }
                    .height('100%')
                  }
                  .justifyContent(FlexAlign.Start)
                  .alignItems(VerticalAlign.Top)
                  .padding({
                    left: 10,
                    right: 10
                  })
                  .width('100%')
                  .layoutWeight(1)
                }
              }
              .margin({ top: 20 })
              .width('100%')
              .height(160)
              .backgroundColor(Color.White)

              // 5、抄送人
              Row() {
                Text("抄送人")
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)

                Text("+")
                  .textAlign(TextAlign.Center)
                  .fontColor('#999999')
                  .fontSize(40)
                  .width(40)
                  .height(40)
                  .lineHeight(40)
                  .borderRadius(20)
                  .border({
                    width: 2,
                    color: '#999999'
                  })
              }
              .padding(10)
              .margin({ top: 20 })
              .width('100%')
              .height(80)
              .justifyContent(FlexAlign.SpaceBetween)
              .backgroundColor(Color.White)
            }
          }
        }
        .padding({
          bottom: 100
        })

        Row() {
          Button("提交")
            .borderRadius(3)
            .height(60)
            .width('90%')
            .backgroundColor('#4749a1')
            .type(ButtonType.Normal)
            .onClick(() => {
              this.submit()
            })
        }
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
        .alignItems(VerticalAlign.Center)
        .height(80)
        .width('100%')
      }
      .alignContent(Alignment.BottomEnd)
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
    .alignContent(Alignment.TopStart)
  }
}