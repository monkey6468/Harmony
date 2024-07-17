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

import router from '@ohos.router'

import { BleDevice } from '@ohos/fastble'
import { BluetoothGattCharacteristic } from '@ohos/fastble'
import ListDialog from './ListDialog'
import ProgressDialog from './ProgressDialog'
import { CharacteristicConsts } from './CharacteristicConsts'
import { GlobalContext } from './GlobalContext'
import ble from '@ohos.bluetooth.ble'

class ListDialogInfo {
  title: string | Resource = '';
  propNameList: string[] = [];
  propList: number[] = [];
  characteristic: ble.BLECharacteristic | undefined = undefined;
}

@Entry
@Preview
@Component
struct Page {
  @State characteristic_name_text: string = '';
  private device: BleDevice | undefined = undefined;
  private service: ble.GattService | undefined = undefined;
  @State characteristicList: /*bluetooth.BLECharacteristic*/ESObject[] = [];
  @State dlgInfo: ListDialogInfo = new ListDialogInfo();
  dialogController: CustomDialogController = new CustomDialogController({
    builder: ListDialog({
      title: this.dlgInfo.title,
      items: this.dlgInfo.propNameList,
      onclick: (which: number) => {
        console.info("onItemClick which:" + which);
        router.push({
          url: 'pages/CharacteristicOperationPage',
          params: {
            device: this.device,
            characteristic: this.dlgInfo.characteristic,
            charaProp: this.dlgInfo.propList[which]
          }
        });
      }
    }),
    autoCancel: true
  })

  private loadStrings() {
    let manager = (GlobalContext.getContext().getValue('context') as Context).resourceManager;
    manager.getString($r('app.string.characteristic').id).then(text => {
      this.characteristic_name_text = text;
    })
  }

  build() {
    Column() {
      List() {
        ForEach(this.characteristicList.map((item1: ESObject, index1: number) => {
          return new CharacteristicListMapClass(index1, item1);
        }), //(service: /*bluetooth.BLECharacteristic*/any, index)
          (item: CharacteristicListMapClass) => {
            ListItem() {
              Row() {
                Column() {
                  Text(this.characteristic_name_text + '(' + item.index + ')').fontSize(14).fontWeight(FontWeight.Bold)
                  Text(item.characteristic.characteristicUuid).margin({ top: 5 }).fontSize(12)
                  Text(this.characteristic_name_text + ' ' + item.characteristic.propertyText)
                    .margin({ top: 5 })
                    .fontSize(12)
                }.layoutWeight(1).padding({ top: 5, bottom: 5 }).alignItems(HorizontalAlign.Start)

                Image($r('app.media.ic_enter')).objectFit(ImageFit.Contain).width(15).height(15)
                  .visibility(item.characteristic.propertyText.length > 0 ? Visibility.Visible : Visibility.None)
              }.width('100%')
            }.onClick(() => this.onItemClick(item.characteristic))
          },
          (item: CharacteristicListMapClass) => item.toString())
      }
      .width('100%')
      .layoutWeight(1)
      .margin({ top: 15 })
      .padding({ left: 10, right: 10 })
      .divider({ strokeWidth: 0.5, color: '#aaa' })
    }
    .width('100%')
    .height('100%')
  }

  private getCharacteristicPropText(characteristic: ble.BLECharacteristic): string {
    let property: string = '';
    if (characteristic?.properties?.read) {
      property = property.concat("Read");
      property = property.concat(" , ");
    }
    if (characteristic?.properties?.write) {
      property = property.concat("Write");
      property = property.concat(" , ");
    }
    if (characteristic?.properties?.writeNoResponse) {
      property = property.concat("Write No Response");
      property = property.concat(" , ");
    }
    if (characteristic?.properties?.notify) {
      property = property.concat("Notify");
      property = property.concat(" , ");
    }
    if (characteristic?.properties?.indicate) {
      property = property.concat("Indicate");
      property = property.concat(" , ");
    }
    if (property.length > 1) {
      property = property.substr(0, property.length - 2);
    }
    if (property.length > 0) {
      property = "( " + property + ")";
    }
    return property;
  }

  private progressDialogCtrl: CustomDialogController = new CustomDialogController({
    builder: ProgressDialog()
  });

  private onItemClick(characteristic: ble.BLECharacteristic): void {
    let propList: Array<number> = new Array();
    let propNameList: Array<string> = new Array();
    if (characteristic?.properties?.read) {
      propList.push(CharacteristicConsts.PROPERTY_READ);
      propNameList.push("Read");
    }
    if (characteristic?.properties?.write) {
      propList.push(CharacteristicConsts.PROPERTY_WRITE);
      propNameList.push("Write");
    }
    if (characteristic?.properties?.writeNoResponse) {
      propList.push(CharacteristicConsts.PROPERTY_WRITE_NO_RESPONSE);
      propNameList.push("Write No Response");
    }
    if (characteristic?.properties?.notify) {
      propList.push(CharacteristicConsts.PROPERTY_NOTIFY);
      propNameList.push("Notify");
    }
    if (characteristic?.properties?.indicate) {
      propList.push(CharacteristicConsts.PROPERTY_INDICATE);
      propNameList.push("Indicate");
    }

    console.info("onItemClick propList.length:" + propList.length);
    if (propList.length > 1) {
      this.dlgInfo.title = $r('app.string.select_operation_type');
      this.dlgInfo.propNameList = propNameList;
      this.dlgInfo.propList = propList;
      this.dlgInfo.characteristic = characteristic;
      this.dialogController.open();
    } else if (propList.length > 0) {
      router.push({
        url: 'pages/CharacteristicOperationPage',
        params: { device: this.device, characteristic: characteristic, charaProp: propList[0] }
      });
    }
  }

  private load(): void {
    this.device = BleDevice.copy((router.getParams() as Record<string, BleDevice>)['device']);
    this.service = (router.getParams() as Record<string, ble.GattService>)['service'];
    this.characteristicList = this.service.characteristics;
    for (let i = 0; i < this.characteristicList.length; i++) {
      this.characteristicList[i].propertyText = this.getCharacteristicPropText(this.characteristicList[i]);
    }

    this.loadStrings();
  }

  aboutToAppear() {
    this.load();
  }

  aboutToDisappear() {
  }
}

class CharacteristicListMapClass {
  public index: number;
  public characteristic: ESObject;

  constructor(index: number, characteristic: ESObject) {
    this.index = index;
    this.characteristic = characteristic;
  }
}
