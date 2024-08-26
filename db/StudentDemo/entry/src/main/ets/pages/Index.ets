import { studentAll, studentDelete } from '../db/studentDao';
import { student } from '../model/student';
import { content } from '../viewmodel/content';
import { footer } from '../viewmodel/footer';
import { header } from '../viewmodel/header';
import { dialogcontent } from '../viewmodel/dialogcontent';
import { promptAction, ShowDialogSuccessResponse } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State data: student[] = []
  @State stu?: student | undefined = undefined
  controller: CustomDialogController = new CustomDialogController({
    builder: dialogcontent({ data: this.data, stu: this.stu })
  })

  async aboutToAppear() {
    this.data = await studentAll()
  }

  build() {
    Column() {
      header({ title: "Student Infomation" })
      content({
        data: this.data,
        updateClick: (stu: student) => {
          this.stu = stu
          this.controller.open()
        }, deleteClick: (stu: student) => {
          promptAction.showDialog({
            title: "Tip",
            message: `Are you sure to delete ${stu.name}?`,
            buttons: [{ text: "Sure", color: "#000" }, { text: "Cancel", color: "#333" }]
          }).then((v: ShowDialogSuccessResponse) => {
            if (v.index == 0) {
              studentDelete(stu.id ?? 0).then((v: number) => {
                if (v > 0) {
                  this.data.splice(this.data.indexOf(stu), 1)
                }
              })
            }
          })
        }
      })
      footer({
        okck: () => {
          this.stu = undefined
          this.controller.open()
        }
      })
    }
    .height('100%')
    .width('100%')
  }
}