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

import BleManager from '../BleManager'
import BleScanState from '../data/BleScanState';
import BleScanPresenterImp from '../callback/BleScanPresenterImp'
import BleScanCallback from '../callback/BleScanCallback'
import BleScanAndConnectCallback from '../callback/BleScanAndConnectCallback'
import BleScanPresenter from './BleScanPresenter'
import BleDevice from '../data/BleDevice'
import BleLog from '../utils/BleLog'
import ble from '@ohos.bluetooth.ble';


type UUID = string;

export default class BleScanner {
  private static instance: BleScanner;

  private constructor() {
  }

  public static getInstance(): BleScanner {
    if (!BleScanner.instance) {
      BleScanner.instance = new BleScanner();
    }
    return BleScanner.instance;
  }

  private mBleScanState: BleScanState = BleScanState.STATE_IDLE;
  private readonly mBleScanPresenter: BleScanPresenter = new TempBleScanPresenter();

  public scan(serviceUuids: UUID[], names: string[], mac: string, fuzzy: boolean,
              timeOut: number, callback: BleScanCallback): void {
    this.startLeScan(serviceUuids, names, mac, fuzzy, false, timeOut, callback);
  }

  public scanAndConnect(serviceUuids: UUID[], names: string[], mac: string, fuzzy: boolean,
                        timeOut: number, callback: BleScanAndConnectCallback): void {
    this.startLeScan(serviceUuids, names, mac, fuzzy, true, timeOut, callback);
  }

  public mockStartLeScan(serviceUuids: UUID[], names: string[], mac: string, fuzzy: boolean, needConnect: boolean,
                         timeOut: number, imp: BleScanPresenterImp) {
    console.info("mockStartLeScan")
  }

  callback = (data: ESObject) => {
    this.mBleScanPresenter.handleScanResults(data);
  };

  public startLeScan(serviceUuids: UUID[], names: string[], mac: string, fuzzy: boolean,
                     needConnect: boolean, timeOut: number, imp: BleScanPresenterImp): void {
    console.info("startLeScan")

    if (this.mBleScanState != BleScanState.STATE_IDLE) {
      BleLog.w("scan action already exists, complete the previous scan action first");
      if (imp != null) {
        imp.onScanStarted(false);
      }
      return;
    }

    this.mBleScanPresenter.prepare(names, mac, fuzzy, needConnect, timeOut, imp);
    console.info("before on")
    if (BleManager.MOCK_DEVICE) {
      BleManager.mockBluetooth.onScan(this.callback);
    } else {
      ble.on('BLEDeviceFind', this.callback);
    }
    console.info("after on")

    let filterArry: ble.ScanFilter[] = [];


    for (let i = 0; i < serviceUuids.length; i++) {
      let filter: ble.ScanFilter = {
        serviceUuid: serviceUuids[i]
      };
      filterArry.push(filter);
    }

    let scanOption: ble.ScanOptions = {
      dutyMode: ble.ScanDuty.SCAN_MODE_LOW_POWER,
      matchMode: ble.MatchMode.MATCH_MODE_AGGRESSIVE,
      interval: 0
    };
    if (BleManager.MOCK_DEVICE) {
      BleManager.mockBluetooth.startBLEScan();
    } else {
      if (filterArry.length == 0) {
        ble.startBLEScan(null, scanOption);
      } else {
        ble.startBLEScan(filterArry, scanOption);
      }

    }

    this.mBleScanState = BleScanState.STATE_SCANNING;
    this.mBleScanPresenter.notifyScanStarted(true);
  }

  public stopLeScan(): void {
    if (BleManager.MOCK_DEVICE) {
      BleManager.mockBluetooth.stopBLEScan();
    } else {
      ble.stopBLEScan();
    }
    this.mBleScanState = BleScanState.STATE_IDLE;
    ble.off('BLEDeviceFind',this.callback)
    this.mBleScanPresenter.notifyScanStopped();
  }

  public getScanState(): BleScanState {
    return this.mBleScanState;
  }
}

class TempBleScanPresenter extends BleScanPresenter {
  public onScanStarted(success: boolean): void {
    let callback: BleScanPresenterImp | null = this.getBleScanPresenterImp();
    if (callback != null) {
      callback.onScanStarted(success);
    }
  }

  public onLeScan(bleDevice: BleDevice) {
    if (this.isNeedConnect()) {
      let callback: BleScanAndConnectCallback = this.getBleScanPresenterImp() as BleScanAndConnectCallback;
      if (callback != null) {
        callback.onLeScan(bleDevice);
      }
    } else {
      let callback: BleScanCallback = this.getBleScanPresenterImp() as BleScanCallback;
      if (callback != null) {
        callback.onLeScan(bleDevice);
      }
    }
  }

  public onScanning(result: BleDevice): void {
    let callback: BleScanPresenterImp | null = this.getBleScanPresenterImp();
    if (callback != null) {
      callback.onScanning(result);
    }
  }

  public onScanFinished(bleDeviceList: BleDevice[]): void {
    if (this.isNeedConnect()) {
      let callback: BleScanAndConnectCallback = this.getBleScanPresenterImp() as BleScanAndConnectCallback;
      if (bleDeviceList == null || bleDeviceList == undefined || bleDeviceList.length < 1) {
        if (callback != null) {
          callback.onScanFinished(null);
        }
      } else {
        if (callback != null) {
          callback.onScanFinished(bleDeviceList[0]);
        }
        let list: BleDevice[] = bleDeviceList;
        setTimeout(() => {
          BleManager.getInstance().connect(list[0], callback);
        }, 100)
      }
    } else {
      let callback: BleScanCallback = this.getBleScanPresenterImp() as BleScanCallback;
      if (callback != null) {
        callback.onScanFinished(bleDeviceList);
      }
    }
  }
}


