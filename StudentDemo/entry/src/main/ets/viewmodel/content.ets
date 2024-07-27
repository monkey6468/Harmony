import { student } from '../model/student'
import { genitem } from '../view/content_list'

@Component
export struct content {
  @Link data: student[]
  updateck: (std: student) => void = () => {
  }
  deleteck: (std: student) => void = () => {
  }

  build() {
    List() {
      ForEach(this.data, (item: student) => {
        ListItem() {
          genitem(item, this.updateck, this.deleteck)
        }
      }, (item: student) => JSON.stringify(item))

    }.width("100%")
    .divider({ strokeWidth: 1, color: Color.Gray })
    .height("80%")
  }
}