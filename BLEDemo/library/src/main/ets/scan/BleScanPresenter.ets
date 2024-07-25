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


import BleScanner from '../scan/BleScanner'
import BleDevice from '../data/BleDevice'
import BleScanPresenterImp from '../callback/BleScanPresenterImp'
import BleLog from '../utils/BleLog'
import HexUtil from '../utils/HexUtil'
import TextUtils from '../utils/TextUtils'
import ArrayUitls from '../utils/ArrayUtils'
import ble from '@ohos.bluetooth.ble'

abstract class BleScanPresenter {
  private mDeviceNames: string[] = [];
  private mDeviceMac: string = '';
  private mFuzzy: boolean = false;
  private mNeedConnect: boolean = false;
  private mScanTimeout: number = 0;
  private mBleScanPresenterImp: BleScanPresenterImp | null = null;
  private mBleDeviceList: BleDevice[] = [];

  public prepare(names: string[], mac: string, fuzzy: boolean, needConnect: boolean,
                 timeOut: number, bleScanPresenterImp: BleScanPresenterImp): void {
    this.mDeviceNames = names;
    this.mDeviceMac = mac;
    this.mFuzzy = fuzzy;
    this.mNeedConnect = needConnect;
    this.mScanTimeout = timeOut;
    this.mBleScanPresenterImp = bleScanPresenterImp;
  }

  public isNeedConnect(): boolean {
    return this.mNeedConnect;
  }

  public getBleScanPresenterImp(): BleScanPresenterImp | null {
    return this.mBleScanPresenterImp;
  }

  private handleResult(bleDevice: BleDevice): void {
    this.onLeScan(bleDevice);
    let gattClient = ble.createGattClientDevice(bleDevice.getMac());
    let that = this
    gattClient.getDeviceName((err, data) => {
      bleDevice.setName(data);
      that.checkDevice(bleDevice);
    })
  }

  public handleScanResults(data: Array<ble.ScanResult>): void {
    for (let i = 0; i < data.length; i++) {
      let item = data[i];
      let device: BleDevice = new BleDevice(item.deviceId, "", item.rssi, new Uint8Array(item.data), new Date().getTime());
      this.handleResult(device);
    }
  }

  private checkDevice(bleDevice: BleDevice): void {
    if (TextUtils.isEmpty(this.mDeviceMac) && ArrayUitls.isEmpty(this.mDeviceNames)) {
      this.correctDeviceAndNextStep(bleDevice);
      return;
    }

    if (!TextUtils.isEmpty(this.mDeviceMac)) {
      if (this.mDeviceMac.toLowerCase() != bleDevice.getMac().toLowerCase())
        return;
    }

    if (!ArrayUitls.isEmpty(this.mDeviceNames)) {
      let found = false;
      for (let i = 0; i < this.mDeviceNames.length; i++) {
        let remoteName: string = bleDevice.getName();
        if (remoteName == null || remoteName == undefined) {
          remoteName = "";
        }
        let name = this.mDeviceNames[i]
        if (this.mFuzzy ? (remoteName.indexOf(name) >= 0) : (remoteName == name)) {
          found = true;
        }
      }

      if (!found) {
        return;
      }
    }

    this.correctDeviceAndNextStep(bleDevice);
  }

  private correctDeviceAndNextStep(bleDevice: BleDevice): void {
    if (this.mNeedConnect) {
      BleLog.i("devices detected  ------"
        + "  name:" + bleDevice.getName()
        + "  mac:" + bleDevice.getMac()
        + "  Rssi:" + bleDevice.getRssi()
        + "  scanRecord:" + HexUtil.formatHexString(bleDevice.getScanRecord()));

      this.mBleDeviceList.push(bleDevice);
      BleScanner.getInstance().stopLeScan();

    } else {

      let hasFound: boolean = false;
      for (let i = 0; i < this.mBleDeviceList.length; i++) {
        if (this.mBleDeviceList[i].getMac() == bleDevice.getMac()) {
          hasFound = true;
          break;
        }
      }

      if (!hasFound) {
        BleLog.i("device detected  ------"
          + "  name: " + bleDevice.getName()
          + "  mac: " + bleDevice.getMac()
          + "  Rssi: " + bleDevice.getRssi()
          + "  scanRecord: " + HexUtil.formatHexString(bleDevice.getScanRecord(), true));

        this.mBleDeviceList.push(bleDevice);
        this.onScanning(bleDevice);
      }
    }
  }

  public notifyScanStarted(success: boolean): void {
    this.mBleDeviceList = [];

    if (success && this.mScanTimeout > 0) {
      setTimeout(() => {
        BleScanner.getInstance().stopLeScan();
      }, this.mScanTimeout);
    }

    this.onScanStarted(success);
  }

  public notifyScanStopped(): void {
    this.onScanFinished(this.mBleDeviceList);
  }

  public abstract onScanStarted(success: boolean): void;

  public abstract onLeScan(bleDevice: BleDevice): void;

  public abstract onScanning(bleDevice: BleDevice): void;

  public abstract onScanFinished(bleDeviceList: BleDevice[]): void;
}

export default BleScanPresenter;