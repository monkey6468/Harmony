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


import BleDevice from '../data/BleDevice'
import BleException from '../exception/BleException'
import ble from '@ohos.bluetooth.ble'

export default abstract class BleGattCallback {
  public abstract onStartConnect();

  public abstract onConnectFail(bleDevice: BleDevice, exception: BleException);

  public abstract onConnectSuccess(bleDevice: BleDevice, gatt: ble.GattClientDevice, status: number);

  public abstract onDisConnected(isActiveDisConnected: boolean, device: BleDevice, gatt: ble.GattClientDevice, status: number);
}