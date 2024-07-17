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

import { BleManager } from '@ohos/fastble'
import { BleException } from '@ohos/fastble'
import { BleDevice } from '@ohos/fastble'
import { BleReadCallback } from '@ohos/fastble';

import { BleIndicateCallback } from '@ohos/fastble';
import { BleNotifyCallback } from '@ohos/fastble';
import { BleWriteCallback } from '@ohos/fastble';

import { HexUtil } from '@ohos/fastble';
import { TextUtils } from '@ohos/fastble';
import { CharacteristicConsts } from './CharacteristicConsts'
import { GlobalContext } from '../pages/GlobalContext'
import resourceManager from '@ohos.resourceManager';
import ble from '@ohos.bluetooth.ble'
import Prompt from '@system.prompt'
import { buffer, util } from '@kit.ArkTS'

@Entry
@Preview
@Component
struct Page {
  private device: BleDevice | undefined = undefined;
  private characteristic: ble.BLECharacteristic | undefined = undefined;
  private charaProp: number = 0;

  private loadStrings() {
    let manager: resourceManager.ResourceManager = (GlobalContext.getContext()
      .getValue('context') as Context).resourceManager;
    manager.getString($r('app.string.data_changed').id).then((text: string) => {
      if (this.characteristic !== undefined) {
        this.title_text = this.characteristic.characteristicUuid + text;
      }
    })
    manager.getString($r('app.string.input_hex').id).then((text: string) => {
      this.input_hint = text;
    })
  }

  @State input_hint: string = '';
  @State input_text: string = '';
  @State input_text_visible: boolean = true;
  @State button_text: Resource = $r('app.string.write');
  @State title_text: string = '';
  @State content_text: string = '';

  build() {
    Column() {
      Row() {
        TextInput({ placeholder: this.input_hint, text: this.input_text })
          .layoutWeight(1)
          .placeholderColor(Color.Gray)
          .placeholderFont({ size: 14 })
          .margin({ right: 10 })
          .type(InputType.Normal)
          .visibility(this.input_text_visible ? Visibility.Visible : Visibility.None)
          .onChange((value: string) => {
            this.input_text = value;
          })
        Button(this.button_text)
          .constraintSize({ minWidth: 70 })
          .height(80)
          .fontSize(18)
          .onClick(() => {
            this.buttonClick()
          })
        if (this.charaProp == CharacteristicConsts.PROPERTY_NOTIFY) {
          TextInput({ text: this.input_text })
            .onChange((value: string) => {
              this.input_text = value;
            })
            .height(80)
            .width(100)
            .fontSize(18)
          Button('写入特征值')
            .height(80)
            .fontSize(18)
            .onClick(() => {
              this.writeClick()
            })
        }
      }.width('100%').height('80')

      Text(this.title_text)
        .width('100%')
        .padding(10)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)
      Text(this.content_text).width('100%').padding(10).fontSize(13)
    }
    .width('100%')
    .height('100%')
    .margin(10)
  }

  private writeClick() {
    if (this.characteristic !== undefined && this.device !== undefined) {
      let hex: string = this.input_text;
      if (TextUtils.isEmpty(hex)) {
        return;
      }
      console.info("PROPERTY_WRITE calling write");

      class TempBleWriteCallback extends BleWriteCallback {
        public onWriteSuccess(current: number, total: number, justWrite: Uint8Array): void {
          console.info("PROPERTY_WRITE onWriteSuccess");
        }

        public onWriteFailure(exception: BleException): void {
          console.info("PROPERTY_WRITE onWriteFailure");
        }
      }

      let tempBleWriteCallback: BleWriteCallback = new TempBleWriteCallback()
      BleManager.getInstance().write(
        this.device,
        this.characteristic.serviceUuid,
        this.characteristic.characteristicUuid,
        new Uint8Array(buffer.from(this.input_text,'utf16le').buffer),
        true,
        true,
        0,
        tempBleWriteCallback);
    }
  };

  private buttonClick() {
    //判断输入的是否为16进制
    if (this.input_text_visible) {
      let reg: RegExp = new RegExp('^[A-Fa-f0-9]{1,4}$')
      if (!reg.test(this.input_text)) {
        Prompt.showToast({ message: "请输入16进制数" })
        return
      }
    }

    this.onclick();
  }

  private onclick: (event?: ClickEvent) => void = () => {
  };

  private load(): void {
    this.device = BleDevice.copy((router.getParams() as Record<string, BleDevice>)['device']);
    this.characteristic = (router.getParams() as Record<string, ble.BLECharacteristic>)['characteristic'];
    this.charaProp = (router.getParams() as Record<string, number>)['charaProp'];
    console.info("charaUUID:" + this.characteristic.characteristicUuid + ", charaProp:" + this.charaProp);

    this.loadStrings();

    let _this = this;
    switch (this.charaProp) {
      case CharacteristicConsts.PROPERTY_READ: {
        console.info("load CharacteristicConsts.PROPERTY_READ");
        this.input_text_visible = false;
        this.button_text = $r('app.string.read');
        this.onclick = () => {
          if (this.characteristic !== undefined && this.device !== undefined) {
            console.info("PROPERTY_READ calling read serviceUuid:" + this.characteristic.serviceUuid + ", characteristicUuid: " + this.characteristic.characteristicUuid);

            class BleReadClass extends BleReadCallback {
              public onReadSuccess(data: Uint8Array): void {
                console.info("PROPERTY_READ onReadSuccess");
                _this.appendDataText(HexUtil.formatHexString(data, true));
              }

              public onReadFailure(exception: BleException): void {
                console.info("PROPERTY_READ onReadFailure" + exception.toString());
                _this.appendDataText(exception.toString());
              }
            }

            let bleReadClass: BleReadCallback = new BleReadClass()

            BleManager.getInstance().read(
              this.device,
              this.characteristic.serviceUuid,
              this.characteristic.characteristicUuid,
              bleReadClass);
          }

        };
      }
        break;

      case CharacteristicConsts.PROPERTY_WRITE: {
        console.info("load CharacteristicConsts.PROPERTY_WRITE serviceUuid:" + this.characteristic.serviceUuid + ", characteristicUuid: " + this.characteristic.characteristicUuid);
        this.input_text_visible = true;
        this.button_text = $r('app.string.write');
        this.onclick = () => {
          if (this.characteristic !== undefined && this.device !== undefined) {
            let hex: string = this.input_text;
            if (TextUtils.isEmpty(hex)) {
              return;
            }
            console.info("PROPERTY_WRITE calling write");

            class TempBleWriteCallback extends BleWriteCallback {
              public onWriteSuccess(current: number, total: number, justWrite: Uint8Array): void {
                console.info("PROPERTY_WRITE onWriteSuccess");
                _this.appendDataText("write success, current: " + current
                  + " total: " + total
                  + " justWrite: " + HexUtil.formatHexString(justWrite, true));

              }

              public onWriteFailure(exception: BleException): void {
                console.info("PROPERTY_WRITE onWriteFailure");
                _this.appendDataText(exception.toString());
              }
            }

            let tempBleWriteCallback: BleWriteCallback = new TempBleWriteCallback()
            BleManager.getInstance().write(
              this.device,
              this.characteristic.serviceUuid,
              this.characteristic.characteristicUuid,
              HexUtil.hexStringToBytes(hex),
              true,
              true,
              0,
              tempBleWriteCallback);
          }
        };
      }
        break;

      case CharacteristicConsts.PROPERTY_WRITE_NO_RESPONSE: {
        console.info("load CharacteristicConsts.PROPERTY_WRITE_NO_RESPONSE");
        this.input_text_visible = true;
        this.button_text = $r('app.string.write');
        this.onclick = () => {

          let hex: string = this.input_text;
          if (TextUtils.isEmpty(hex)) {
            return;
          }

          if (this.characteristic !== undefined && this.device !== undefined) {
            console.info("PROPERTY_WRITE_NO_RESPONSE calling write serviceUuid:" + this.characteristic.serviceUuid + ", characteristicUuid: " + this.characteristic.characteristicUuid);

            class TempBleWriteCallback extends BleWriteCallback {
              public onWriteSuccess(current: number, total: number, justWrite: Uint8Array): void {
                console.info("PROPERTY_WRITE_NO_RESPONSE onWriteSuccess");
                _this.appendDataText("write success, current: " + current
                  + " total: " + total
                  + " justWrite: " + HexUtil.formatHexString(justWrite, true));

              }

              public onWriteFailure(exception: BleException): void {
                console.info("PROPERTY_WRITE_NO_RESPONSE onWriteFailure");
                _this.appendDataText(exception.toString());
              }
            }

            let tempBleWriteCallback: BleWriteCallback = new TempBleWriteCallback()

            BleManager.getInstance().write(
              this.device,
              this.characteristic.serviceUuid,
              this.characteristic.characteristicUuid,
              HexUtil.hexStringToBytes(hex),
              true,
              true,
              0,
              tempBleWriteCallback);
          }

        };
      }
        break;

      case CharacteristicConsts.PROPERTY_NOTIFY: {

        console.info("load CharacteristicConsts.PROPERTY_NOTIFY");
        this.input_text_visible = false;
        this.button_text = $r('app.string.open_notification');
        this.onclick = () => {
          if (this.characteristic !== undefined && this.device !== undefined) {
            if (this.button_text.id == $r('app.string.open_notification').id) {
              this.button_text = $r('app.string.close_notification');
              console.info("PROPERTY_NOTIFY calling notify serviceUuid:" + this.characteristic.serviceUuid + ", characteristicUuid: " + this.characteristic.characteristicUuid);

              class TempBleNotifyCallback extends BleNotifyCallback {
                public onNotifySuccess() {
                  console.info("PROPERTY_NOTIFY onNotifySuccess");
                  _this.appendDataText("notify success");
                }

                public onNotifyFailure(exception: BleException) {
                  console.info("PROPERTY_NOTIFY onNotifyFailure");
                  _this.appendDataText(exception.toString());
                }

                public onCharacteristicChanged(data: Uint8Array) {
                  console.info("PROPERTY_NOTIFY onCharacteristicChanged");
                  if (_this.characteristic !== undefined) {
                    let decoder = util.TextDecoder.create("utf-8");
                    _this.appendDataText(decoder.decodeWithStream(data));
                  }
                }
              }

              let tempBleNotifyCallback: TempBleNotifyCallback = new TempBleNotifyCallback();
              BleManager.getInstance().notify(
                this.device,
                this.characteristic.serviceUuid,
                this.characteristic.characteristicUuid,
                false,
                tempBleNotifyCallback);
            } else {
              this.button_text = $r('app.string.open_notification');
              console.info("PROPERTY_NOTIFY calling stopNotify serviceUuid:" + this.characteristic.serviceUuid + ", characteristicUuid: " + this.characteristic.characteristicUuid);
              BleManager.getInstance().stopNotify(
                this.device,
                this.characteristic.serviceUuid,
                this.characteristic.characteristicUuid);
            }
          }
        };
      }
        break;

      case CharacteristicConsts.PROPERTY_INDICATE: {
        console.info("load CharacteristicConsts.PROPERTY_INDICATE");
        this.input_text_visible = false;
        this.button_text = $r('app.string.open_notification');
        this.onclick = () => {
          if (this.characteristic !== undefined && this.device !== undefined) {
            if (this.button_text.id == $r('app.string.open_notification').id) {
              this.button_text = $r('app.string.close_notification');
              console.info("PROPERTY_INDICATE calling indicate serviceUuid:" + this.characteristic.serviceUuid + ", characteristicUuid: " + this.characteristic.characteristicUuid);

              class TempBleIndicateCallback extends BleIndicateCallback {
                public onIndicateSuccess(): void {
                  console.info("PROPERTY_INDICATE onIndicateSuccess");
                  _this.appendDataText("indicate success");
                }

                public onIndicateFailure(exception: BleException): void {
                  console.info("PROPERTY_INDICATE onIndicateFailure");
                  _this.appendDataText(exception.toString());
                }

                public onCharacteristicChanged(data: Uint8Array): void {
                  console.info("PROPERTY_INDICATE onCharacteristicChanged");
                  if (_this.characteristic !== undefined) {
                    _this.appendDataText(HexUtil.formatHexString(new Uint8Array(_this.characteristic.characteristicValue), true));
                  }
                }
              }

              let tempBleIndicateCallback: TempBleIndicateCallback = new TempBleIndicateCallback()
              BleManager.getInstance().indicate(
                this.device,
                this.characteristic.serviceUuid,
                this.characteristic.characteristicUuid,
                false,
                tempBleIndicateCallback)
            } else {
              this.button_text = $r('app.string.open_notification');
              console.info("PROPERTY_INDICATE calling stopIndicate serviceUuid:" + this.characteristic.serviceUuid + ", characteristicUuid: " + this.characteristic.characteristicUuid);
              BleManager.getInstance().stopIndicate(
                this.device,
                this.characteristic.serviceUuid,
                this.characteristic.characteristicUuid);
            }
          }
        };
      }
        break;
    }
  }

  private appendDataText(content: string): void {
    this.content_text += content;
    this.content_text += "\n";
  }

  aboutToAppear() {
    this.load();
  }

  aboutToDisappear() {
  }
}






