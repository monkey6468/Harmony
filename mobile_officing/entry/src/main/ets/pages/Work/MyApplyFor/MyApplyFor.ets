import { NavBar } from '../../../components/NavBar'
import { getProcessList } from '../../../api/Process'
import { Process } from '../../../types/Process'
import { ApplyForItem } from '../../../components/ApplyForItem'

@Entry
@Component
struct MyApplyFor {
  @State currentIndex: number = 0
  @State type_id: number = 0
  @State page: number = 1
  @State pageSize: number = 10
  @State processList: Process[] = []
  topList: String[] = ['全部', '人事管理','行政事务','财务类','业务相关']

  async getProcessListData() {
    const res = await getProcessList({
      type_id: this.type_id,
      page: this.page,
      pageSize: this.pageSize
    })

    this.processList = res.data.items
  }

  aboutToAppear() {
    this.getProcessListData()
  }

  @Builder TabBuilder(index: number, tabTitle: string) {
    Column() {
      Text(tabTitle)
        .fontColor(this.currentIndex === index ? '#101010' : '#666666')
        .fontSize(this.currentIndex === index ? 18 : 17)
        .fontWeight(this.currentIndex === index ? 500 : 400)

        .margin({ top: 10, right: 5, bottom: 10 })
      Divider()
        .strokeWidth(2)
        .color('#0475fa')
        .opacity(this.currentIndex === index ? 1 : 0)
        .width('50%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  @Builder buildApplyForItems() {
    Column() {
      List() {
        ForEach(this.processList, (process: Process) => {
          ListItem() {
            ApplyForItem({ process })
          }
        })
      }
      .backgroundColor(Color.White)
      .borderRadius(5)
    }
    .padding(15)
    .width('100%')
    .height('100%')
  }

  @Builder buildTopTab() {
    Tabs({ barPosition: BarPosition.Start }) {
      ForEach(this.topList, (name: string, index: number) => {
        TabContent() {
          this.buildApplyForItems()
        }.tabBar(this.TabBuilder(index, name))
      })
    }
    .onChange(index => {
      // 存在 循环 获取数据的问题
      this.currentIndex = index
      this.type_id = index
      this.getProcessListData()
    })
    .layoutWeight(1)
    .backgroundColor('#f5f5f5')
  }

  build() {
    Column() {
      // 顶部的NavBar组件
      NavBar({ title: "我的申请" })

      // 使用Tab渲染内容
      this.buildTopTab()
    }
    .width('100%')
    .height('100%')
  }
}