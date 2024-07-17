/*
 * Copyright (c) 2021 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

@CustomDialog
struct ListDialog {
  controller: CustomDialogController
  title: string | Resource = 'title';
  items: string[] = ['item1', 'item2'];
  onclick: (which:number) => void = (which:number)=>{};

  build() {
    Column() {
      Text(this.title).fontSize(20).fontWeight(FontWeight.Bold)
      List(){
          ForEach(this.items,
              (item:string,index:number) => {
                  ListItem() {
                      Column(){
                          Text(item).fontSize(18).height(40)
                      }.width('100%').padding({top:5, bottom: 5}).alignItems(HorizontalAlign.Start)
                  }.onClick(() => {
                    this.controller.close();
                    this.onclick(index);
                  })
              },
              (item:string) => item)
      }.width('100%')
    }.margin(10)
  }
}

export default ListDialog;