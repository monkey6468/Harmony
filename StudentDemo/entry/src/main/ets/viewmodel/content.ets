import { student } from '../model/student'
import { Cell } from '../view/content_list'

@Component
export struct content {
  @Link data: student[]
  updateClick: (std: student) => void = () => {
  }
  deleteClick: (std: student) => void = () => {
  }

  build() {
    List() {
      ForEach(this.data, (item: student) => {
        ListItem() {
          Cell(item, this.updateClick, this.deleteClick)
        }
      }, (item: student) => JSON.stringify(item))

    }.width("100%")
    .divider({ strokeWidth: 1, color: Color.Gray })
    .height("80%")
  }
}