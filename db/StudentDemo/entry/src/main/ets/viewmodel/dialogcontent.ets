import { studentAdd, studentUpdate } from '../db/studentDao'
import { student } from '../model/student'
import { header } from './header'

@CustomDialog
export struct dialogcontent {
  controller: CustomDialogController
  @Link data: student[]
  @Link stu?: student
  @State name?: string = this.stu?.name
  @State age: string = this.stu?.age == undefined ? "" : `${this.stu.age}`
  @State school?: string = this.stu?.school

  build() {
    Column() {
      header({ title: this.stu == undefined ? "Add Info" : `Update ${this.stu.name} Info` })
      Row() {
        Text("Name:")
        TextInput({ text: this.name })
          .type(InputType.USER_NAME)
          .width("80%")
          .margin({ left: 10 })
          .onChange((v) => {
            this.name = v
          })
      }.width("100%")
      .margin({ top: 10 })

      Row() {
        Text("Age:")
        TextInput({ text: this.age })
          .width("80%")
          .type(InputType.Number)
          .margin({ left: 10 })
          .onChange((v) => {
            this.age = v
          })
      }.width("100%")
      .margin({ top: 10 })

      Row() {
        Text("School:")
        TextInput({ text: this.school })
          .width("80%")
          .margin({ left: 10 })
          .onChange((v) => {
            this.school = v
          })
      }.width("100%")
      .margin({ top: 10 })

      Button("Ok")
        .width("80%")
        .onClick(() => {

          if (this.stu == undefined) {
            let stu: student = {
              id: -1,
              name: this.name ?? "",
              age: parseInt(this.age),
              school: this.school ?? ""
            }

            studentAdd(stu).then((id: number) => {
              if (id > 0) {
                stu.id = id
                this.data.push(stu)
                this.controller.close()
              }
            })
          } else {
            let stu: student = {
              id: this.stu.id,
              name: this.name ?? "",
              age: parseInt(this.age),
              school: this.school ?? ""
            }
            let index = this.data.findIndex((item: student) => item.id == stu.id)
            studentUpdate(stu).then((id: number) => {
              if (id > 0) {
                this.data[index] = stu
                this.controller.close()
              }
            })
          }
        })
    }.width("80%")
    .height("60%")
    .justifyContent(FlexAlign.SpaceEvenly)
    .backgroundColor(Color.White)
  }
}