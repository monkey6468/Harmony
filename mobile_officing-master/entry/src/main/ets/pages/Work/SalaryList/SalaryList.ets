import { Salary } from '../../../types/Salary'
import { getSalaryList } from '../../../api/Salary'
import { NavBar } from '../../../components/NavBar'
import router from '@ohos.router'

@Entry
@Component
struct SalaryList {
  @State page: number = 1
  @State salaryList: Salary[] = []

  async getSalaryListData() {
    const res = await getSalaryList({ page: this.page, pageSize: 10 })
    this.salaryList = res.data.items
  }

  aboutToAppear() {
    this.getSalaryListData()
  }

  @Builder buildSalaryItem(salary: Salary) {
    Row() {
      Image($rawfile("salary/salary.png"))
        .width(30)
        .height(30)
      Column() {
        Text(`${salary.month}月份工资单`)
          .fontSize(16)
          .fontColor('#101010')
          .fontWeight(FontWeight.Bold)
        Text(`${salary.created_at}`)
          .fontSize(14)
          .fontColor('#999999')
      }
      .height('60%')
      .justifyContent(FlexAlign.SpaceAround)
      .layoutWeight(1)

      Text(`${salary.net_salary}`)
        .fontSize(26)
        .fontColor('#4749a1')
        .fontWeight(FontWeight.Bold)
        .width(60)
        .margin({
          right: 10
        })
      Image($rawfile("common/arraw_right.png"))
        .width(20)
        .height(20)
        .fillColor(Color.Red)
    }
    .onClick(() => {
      router.pushUrl({
        url: "pages/Work/SalaryDetail/SalaryDetail",
        params: {
          id: salary._id
        }
      })
    })
    .backgroundColor(Color.White)
    .padding({
      left: 15,
      right: 15
    })
    .width('100%')
    .height(100)
  }

  build() {
    Column(){
      NavBar({
        title: "工资单"
      })

      Column(){
        Row() {
          Select([{ value: '2018' },
            { value: '2019' },
            { value: '2020' },
            { value: '2021' },
            { value: '2022' },
            { value: '2023' }
          ])
            .value('请选择年份')
            .selected(1)
            .font({ size: 20 })
            .fontColor('#182431')
            .selectedOptionFont({ size: 20, weight: 400 })
            .optionFont({ size: 20, weight: 400 })
            .selectedOptionBgColor('#f5f5f5')
            .selectedOptionFontColor('#182431')
            .backgroundColor('#f5f5f5')
            .onSelect((index: number) => {
              console.info('Select:' + index)
            })

          Text("合计：38400.00元")
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .height(60)
        .padding({
          left: 10,
          right: 10
        })

        List() {
          ForEach(this.salaryList,(salary: Salary) => {
            this.buildSalaryItem(salary)
          })
        }
        .divider({ strokeWidth: 1, color: '#e4e4e4', startMargin: 20, endMargin: 20 }) // 每行之间的分界线
        .borderRadius(8)
        .padding({
          left: 15,
          right: 15
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}