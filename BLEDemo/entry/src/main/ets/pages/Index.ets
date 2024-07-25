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

import router from '@ohos.router';

import geolocation from '@ohos.geolocation';
import prompt from '@system.prompt';

import {
  BleDevice,
  BleException,
  BleGattCallback,
  BleManager,
  BleScanCallback,
  BleScanRuleConfig
} from '@ohos/fastble';
import { ArrayHelper, PermissionHelper } from './Utils';
import ProgressDialog from './ProgressDialog';
import { GlobalContext } from './GlobalContext';
import { Permissions } from '@ohos.abilityAccessCtrl';
import ble from '@ohos.bluetooth.ble';
import access from '@ohos.bluetooth.access';

@Entry
@Preview
@Component
struct Page {
  @State edit_text_uuid: string = '';
  @State edit_text_name: string = '';
  @State edit_text_mac: string = '';
  @State switch_auto_connect: boolean = false;
  @State setting_visibility: Visibility = Visibility.None;
  @State search_setting_text: Resource = $r('app.string.expand_search_settings');
  @State btn_scan_text: Resource = $r('app.string.start_scan');
  @State is_loading: boolean = false;
  @State loading_rotate: number = 0;
  @State bleDeviceList: BleDevice[] = [];
  @State connectedDevices: string[] = [];
  @State private toast_open_bluetooth: string = '';
  @State private toast_connect_fail: string = '';
  @State private toast_disconnected: string = '';
  @State private toast_active_disconnected: string = '';
  private progressDialogCtrl: CustomDialogController = new CustomDialogController({
    builder: ProgressDialog()
  });

  build() {
    Column() {
      Stack() {
        Button(this.btn_scan_text)
          .onClick(() => this.onSearchClick())
          .fontSize(18)
          .height(80)
          .fontWeight(FontWeight.Bold)
        LoadingProgress()
          .width(40)
          .height(40)
          .align(Alignment.Center)
          .color($r('app.color.colorPrimary'))
          .markAnchor({ x: 40 + 10, y: -20 })
          .position({ x: '100%', y: 0 })
          .visibility(this.is_loading ? Visibility.Visible : Visibility.None)
      }.width('100%')

      List() {
        ForEach(this.bleDeviceList, (device: BleDevice) => {
          ListItem() {
            Row() {
              if (this.isConnected(device)) {
                Image($r('app.media.ic_blue_connected')).objectFit(ImageFit.None).width(30).height(30)
                Column() {
                  Text(device.getName()).margin({ bottom: 2 }).fontSize(14).fontColor($r('app.color.colorPrimary'))
                  Text(device.getMac()).margin({ top: 2 }).fontSize(12).fontColor($r('app.color.colorPrimary'))
                }.layoutWeight(1).margin({ left: 10 }).alignItems(HorizontalAlign.Start)

                Row() {
                  Text($r('app.string.connected')).fontColor($r('app.color.colorPrimary')).fontSize(14)
                  Button($r('app.string.disconnect'))
                    .width(100)
                    .height(80)
                    .margin({ left: 5 })
                    .fontSize(12)
                    .onClick(() => this.onDisconnectClick(device))
                  Button($r('app.string.enter'))
                    .width(100)
                    .height(80)
                    .margin({ left: 5 })
                    .fontSize(12)
                    .onClick(() => this.onDetailClick(device))
                }
              } else {
                Image($r('app.media.ic_blue_remote')).objectFit(ImageFit.None).width(30).height(30)
                Column() {
                  Text(device.getName()).margin({ bottom: 2 }).fontSize(14)
                  Text(device.getMac()).margin({ top: 2 }).fontSize(12)
                }.layoutWeight(1).margin({ left: 10 }).alignItems(HorizontalAlign.Start)

                Row() {
                  Text('' + device.getRssi()).fontSize(14)
                  Image($r('app.media.ic_rssi')).objectFit(ImageFit.ScaleDown).width(18).height(18).margin({ left: 5 });
                  Button($r('app.string.connect'))
                    .width(100)
                    .height(80)
                    .margin({ left: 5 })
                    .fontSize(12)
                    .onClick(() => this.onConnectClick(device))
                }
              }
            }.width('100%')
          }
        }, (item: BleDevice) => item.getMac())
      }
      .width('100%')
      .layoutWeight(1)
      .margin({ top: 10 })
      .padding({ left: 5, right: 5 })
      .divider({ strokeWidth: 0.5, color: '#aaa' })
    }.width('100%').height('100%')
  }

  public clearConnectedDevice() {
    for (let i = 0; i < this.bleDeviceList.length; i++) {
      let device: BleDevice = this.bleDeviceList[i];
      if (BleManager.getInstance().isConnected(device)) {
        ArrayHelper.removeIndex(this.bleDeviceList, i);
      }
    }
  }

  public clearScanDevice() {
    for (let i = 0; i < this.bleDeviceList.length; i++) {
      let device: BleDevice = this.bleDeviceList[i];
      if (!BleManager.getInstance().isConnected(device)) {
        ArrayHelper.removeIndex(this.bleDeviceList, i);
      }
    }
  }

  public clear() {
    this.bleDeviceList = [];
  }

  aboutToAppear() {
    BleManager.getInstance().init();
    BleManager.getInstance()
      .enableLog(true)
      .setReConnectCount(1, 5000)
      .setConnectOverTime(20000)
      .setOperateTimeout(5000);

    this.loadStrings();
  }

  aboutToDisappear() {
    BleManager.getInstance().disconnectAllDevice();
    BleManager.getInstance().destroy();
  }

  private loadStrings() {
    let manager = (GlobalContext.getContext().getValue('context') as Context).resourceManager;

    manager.getString($r('app.string.please_open_blue').id).then(text => {
      this.toast_open_bluetooth = text;
    })
    manager.getString($r('app.string.connect_fail').id).then(text => {
      this.toast_connect_fail = text;
    })
    manager.getString($r('app.string.disconnected').id).then(text => {
      this.toast_disconnected = text;
    })
    manager.getString($r('app.string.active_disconnected').id).then(text => {
      this.toast_active_disconnected = text;
    })
  }

  private isConnected(device: BleDevice): boolean {
    return ArrayHelper.contains(this.connectedDevices, device.getMac());
  }

  private onSearchClick(): void {
    if (this.btn_scan_text.id == $r('app.string.start_scan').id) {
      if (BleManager.MOCK_DEVICE) {
        this.startScan();
      } else {
        this.checkPermissions();
      }
    } else if (this.btn_scan_text.id == $r('app.string.stop_scan').id) {
      BleManager.getInstance().cancelScan();
    }
  }

  private onConnectClick(device: BleDevice) {
    if (!BleManager.getInstance().isConnected(device)) {
      BleManager.getInstance().cancelScan();
      this.connect(device);
    }
  }

  private onDisconnectClick(device: BleDevice) {
    BleManager.getInstance().disconnect(device);
  }

  private onDetailClick(device: BleDevice) {
    console.info("onDetailClick deviceName:" + device.getName());
    router.push({
      url: 'pages/ServiceListPage', params: { device: device }
    });
  }

  private checkPermissions(): void {
    let permissions: Permissions[] =
      ["ohos.permission.USE_BLUETOOTH", "ohos.permission.DISCOVER_BLUETOOTH", "ohos.permission.ACCESS_BLUETOOTH"];
    PermissionHelper.requestPermissions(permissions, results => {
      for (let i = 0; i < permissions.length; i++) {
        if (results[i] != 0) {
          let msg = "permission " + permissions[i] + " not granted!";
          prompt.showToast({ message: msg, duration: 2000 })
          return;
        }
      }

      let result = access.getState();
      console.info("checkPermissions bluetooth.state: " + result);
      if (result == access.BluetoothState.STATE_OFF) {
        prompt.showToast({ message: this.toast_open_bluetooth, duration: 300, })
        access.enableBluetooth(); //打开蓝牙
        return;
      }

      this.startScan();
    });
  }


  private startScan(): void {
    let _this = this;
    console.info("startScan");

    class TempBleScanCallback extends BleScanCallback {
      onScanStarted(success: boolean): void {
        console.info("onScanStarted success:" + success);
        _this.clearScanDevice();
        _this.is_loading = true;
        _this.loading_rotate = 360;
        _this.btn_scan_text = $r('app.string.stop_scan');
        _this.connectedDevices = BleManager.getInstance().getAllConnectedDevice();

      }

      onLeScan(bleDevice: BleDevice): void {
        console.info("onLeScan");
      }

      onScanning(bleDevice: BleDevice): void {
        console.info("onScanning");
        ArrayHelper.add(_this.bleDeviceList, bleDevice);

      }

      onScanFinished(scanResultList: Array<BleDevice>): void {

        console.info("onScanFinished");
        _this.is_loading = false;
        _this.loading_rotate = 0;
        _this.btn_scan_text = $r('app.string.start_scan');
        _this.connectedDevices = BleManager.getInstance().getAllConnectedDevice();
      }
    }

    BleManager.getInstance().scan(new TempBleScanCallback());
  }

  private connect(bleDevice: BleDevice): void {
    let _this = this;

    class IndexBleGattCallback extends BleGattCallback {
      public onStartConnect(): void {
        _this.progressDialogCtrl.open();
      }

      public onConnectFail(bleDevice: BleDevice, exception: BleException): void {

        _this.progressDialogCtrl.close();
        prompt.showToast({ message: _this.toast_connect_fail, duration: 300, })
      }

      public onConnectSuccess(bleDevice: BleDevice, gatt: ble.GattClientDevice, status: number): void {
        _this.progressDialogCtrl.close();
        ArrayHelper.add(_this.connectedDevices, bleDevice.getMac());
      }

      public onDisConnected(isActiveDisConnected: boolean, device: BleDevice, gatt: ble.GattClientDevice,
        status: number): void {

        _this.progressDialogCtrl.close();
        _this.connectedDevices = BleManager.getInstance().getAllConnectedDevice();

        if (isActiveDisConnected) {
          prompt.showToast({ message: _this.toast_active_disconnected, duration: 300 })
        } else {
          prompt.showToast({ message: _this.toast_disconnected, duration: 300 })
        }
      }
    }

    BleManager.getInstance().connect(bleDevice, new IndexBleGattCallback());
  }
}






