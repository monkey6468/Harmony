import { TabBarItem } from '../../types/TabBarItem'
import { AddressBook } from '../AddressBook/AddressBook'
import { Message } from '../Message/Message'
import { My } from '../My/My'
import { Work } from '../Work/Work'

@Entry
@Component
struct Home {
  @State currentIndex: number = 0
  tabBarItems: TabBarItem[] = [
    {
      text: $r("app.string.work"),
      icon: $rawfile("tabBarItemImages/book.png"),
      activeIcon: $rawfile("tabBarItemImages/book_active.png")
    },
    {
      text: $r("app.string.message"),
      icon: $rawfile("tabBarItemImages/message.png"),
      activeIcon: $rawfile("tabBarItemImages/message_active.png")
    },
    {
      text: $r("app.string.address_book"),
      icon: $rawfile("tabBarItemImages/address_book.png"),
      activeIcon: $rawfile("tabBarItemImages/address_book_active.png")
    },
    {
      text: $r("app.string.my"),
      icon: $rawfile("tabBarItemImages/my.png"),
      activeIcon: $rawfile("tabBarItemImages/my_active.png")
    }
  ]

  @Builder TabItemBuilder(index: number) {
    Column() {
      Image(this.currentIndex === index ? this.tabBarItems[index].activeIcon : this.tabBarItems[index].icon)
        .width(24)
        .height(24)
        .margin({ bottom: 4 })
        .objectFit(ImageFit.Contain)
      Text(this.tabBarItems[index].text)
        .fontColor(this.currentIndex === index ? '#4749a1' : '#9a9a9a')
        .fontSize(10)
        .fontWeight(500)
        .lineHeight(14)
    }.width('100%')
  }

  build() {
    Column() {
      Text()
      .decoration(TextDecorationType.)
      Tabs({ barPosition: BarPosition.End }) {
        ForEach(this.tabBarItems, (items: TabBarItem, index: number) => {
          TabContent() {
            if (index == 0) {
              Work()
            } else if (index == 1) {
              Message()
            } else if (index == 2) {
              AddressBook()
            } else if (index == 3) {
              My()
            }
          }.tabBar(this.TabItemBuilder(index))
        })
      }.onChange(index => {
        this.currentIndex = index
      })
    }
    .width('100%')
    .height("100%")
  }
}
