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
import { BleManager } from '@ohos/fastble'
import { GlobalContext } from './GlobalContext';
import resourceManager from '@ohos.resourceManager';
import ble from '@ohos.bluetooth.ble';


@Entry
@Preview
@Component
struct Page {
  @State private device_name_text: string = '';
  @State private mac_text: string = '';
  @State private service_text: string = '';
  private device: BleDevice | undefined = undefined;
  @State private serviceList: ble.GattService[] = [];

  private loadStrings() {
    let manager: resourceManager.ResourceManager = (GlobalContext.getContext()
      .getValue('context') as Context).resourceManager;
    manager.getString($r('app.string.name').id).then(text => {
      if (this.device !== undefined) {
        this.device_name_text = text + this.device.getName();
      }

    })
    manager.getString($r('app.string.mac').id).then(text => {
      if (this.device !== undefined) {
        this.mac_text = text + this.device.getMac();
      }

    })
    manager.getString($r('app.string.service').id).then(text => {
      this.service_text = text;
    })
  }

  build() {
    Column() {
      Column() {
        Text(this.device_name_text)
          .margin({ top: 10 })
          .padding({ left: 10, right: 10 })
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
        Text(this.mac_text).margin({ top: 5 }).padding({ left: 10, right: 10 }).fontSize(14).fontWeight(FontWeight.Bold)
      }.width('100%').alignItems(HorizontalAlign.Start)

      List() {
        ForEach(this.serviceList, //(service: /*bluetooth.GattService*/any, index)
          (item: ble.GattService, index: number) => {
            ListItem() {
              Row() {
                Column() {
                  Text(this.service_text + '(' + index + ')').fontSize(14).fontWeight(FontWeight.Bold)
                  Text(item.serviceUuid).margin({ top: 5 }).fontSize(12)
                  Text($r('app.string.type')).margin({ top: 5 }).fontSize(12)
                }.layoutWeight(1).padding({ top: 5, bottom: 5 }).alignItems(HorizontalAlign.Start)

                Image($r('app.media.ic_enter')).objectFit(ImageFit.Contain).width(15).height(15).margin({ right: 10 })
              }.width('100%')
            }.onClick(() => this.onItemClick(item))
          },
          (item: ble.GattService) => item.serviceUuid)
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

  private onItemClick(service: ble.GattService): void {
    console.info("onItemClick service:" + service.serviceUuid);
    router.push({
      url: 'pages/CharacteristicListPage',
      params: { device: this.device, service: service }
    });
  }

  private load(): void {
    this.device = BleDevice.copy((router.getParams() as Record<string, BleDevice>)['device']);

    this.loadStrings();

    if (BleManager.MOCK_DEVICE) {
      for (let i = 0; i < 10; i++) {
        let characteristicList: ESObject[] = [];
        for (let j = 0; j < 10; j++) {
          characteristicList.push({ characteristicUuid: '0000-8812-3352-3235' });
        }
        this.serviceList.push({
          serviceUuid: '0000-8812-1000-0025',
          isPrimary: true,
          characteristics: characteristicList
        });
      }
      return;
    }

    BleManager.getInstance().getBluetoothGattServices(this.device, (err, services: ble.GattService[]) => {
      this.serviceList = services;
    });
  }

  aboutToAppear() {
    this.load();
  }

  aboutToDisappear() {
  }
}
