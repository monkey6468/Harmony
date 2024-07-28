import { student } from '../model/student';

@Styles
function textStyle() {
  .padding(10)
  .borderRadius(5)
  .stateStyles({
    normal: {
      .backgroundColor(Color.Gray)
      .border({ width: 1, color: Color.Gray })
    },
    pressed: {
      .backgroundColor(Color.Blue)
      .border({ width: 1, color: Color.Blue })
    },
  })
}

@Builder
export function Cell(stu: student,
  updateClick: (stu: student) => void,
  deleteClick: (stu: student) => void) {
  Row() {
    Text(stu.name)
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .width("20%")
    Text(stu.age + "")
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .width("20%")
    Text(stu.school)
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .width("20%")
    Row() {
      Text("Update")
        .textStyle()
        .fontColor(Color.White)
        .onClick(() => {
          updateClick(stu)
        })
      Text("Delete")
        .textStyle()
        .fontColor(Color.White)
        .margin({ left: 10 })
        .onClick(() => {
          deleteClick(stu)
        })
    }.width("40%")
    .justifyContent(FlexAlign.Center)
  }.width("100%")
  .padding(5)
}