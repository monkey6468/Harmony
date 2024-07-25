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


import BleManager from '../BleManager';
import BleBluetooth from '../bluetooth/BleBluetooth';
import BleIndicateCallback from '../callback/BleIndicateCallback';
import BleMtuChangedCallback from '../callback/BleMtuChangedCallback';
import BleNotifyCallback from '../callback/BleNotifyCallback';
import BleReadCallback from '../callback/BleReadCallback';
import BleRssiCallback from '../callback/BleRssiCallback';
import BleWriteCallback from '../callback/BleWriteCallback';
import BleMsg from '../data/BleMsg';
import BleWriteState from '../data/BleWriteState';
import GattException from '../exception/GattException';
import OtherException from '../exception/OtherException';
import TimeoutException from '../exception/TimeoutException';
import { Message, Handler } from '../utils/Handler';
import ble from '@ohos.bluetooth.ble';

type UUID = string;
type byte = number;

export default class BleConnector {
  private static readonly UUID_CLIENT_CHARACTERISTIC_CONFIG_DESCRIPTOR = "00002902-0000-1000-8000-00805f9b34fb";
  private mBluetoothGatt: ble.GattClientDevice | null = null;
  private mGattService: ble.GattService | null = null;
  private mCharacteristic: ble.BLECharacteristic | null = null;
  private mBleBluetooth: BleBluetooth;
  private mHandler: Handler;

  constructor(bleBluetooth: BleBluetooth) {
    this.mBleBluetooth = bleBluetooth;
    this.mBluetoothGatt = bleBluetooth.getBluetoothGatt();
    this.mHandler = new BleConnectorHandler(this)
  }

  private withUUID(serviceUUID: UUID, characteristicUUID: UUID): BleConnector {
    if (serviceUUID != null && this.mBluetoothGatt != null) {
      let services = this.mBleBluetooth.getServices();
      for (let i = 0; i < services.length; i++) {
        if (services[i].serviceUuid == serviceUUID) {
          this.mGattService = services[i];
          break;
        }
      }
      if (this.mGattService != null && characteristicUUID != null) {
        let characteristics = this.mGattService.characteristics;
        for (let i = 0; i < characteristics.length; i++) {
          if (characteristics[i].characteristicUuid == characteristicUUID) {
            this.mCharacteristic = characteristics[i];
            break;
          }
        }
      }
    }
    return this;
  }

  public withUUIDString(serviceUUID: string, characteristicUUID: string): BleConnector {
    return this.withUUID(serviceUUID, characteristicUUID);
  }

  /*------------------------------- main operation ----------------------------------- */


  /**
   * notify
   */
  public enableCharacteristicNotify(bleNotifyCallback: BleNotifyCallback, uuid_notify: string,
                                    userCharacteristicDescriptor: boolean): void {
    if (this.mCharacteristic != null && this.mBluetoothGatt != null
    ) {

      this.handleCharacteristicNotifyCallback(bleNotifyCallback, uuid_notify);
      this.setCharacteristicNotification(this.mBluetoothGatt, this.mCharacteristic, userCharacteristicDescriptor, true, bleNotifyCallback);
      this.mBluetoothGatt.on('BLECharacteristicChange', (bleCharacteristic: ble.BLECharacteristic) => {
        bleNotifyCallback.onCharacteristicChanged(new Uint8Array(bleCharacteristic.characteristicValue))
      })
    } else {
      if (bleNotifyCallback != null) {
        bleNotifyCallback.onNotifyFailure(new OtherException("this characteristic not support notify!"));
      }
    }
  }

  /**
   * stop notify
   */
  public disableCharacteristicNotify(useCharacteristicDescriptor: boolean): boolean {
    if (this.mCharacteristic != null
    /*&& (this.mCharacteristic.getProperties() | bluetooth.BLECharacteristic.PROPERTY_NOTIFY) > 0*/
    ) {
      return this.setCharacteristicNotification(this.mBluetoothGatt, this.mCharacteristic,
        useCharacteristicDescriptor, false, null);
    } else {
      return false;
    }
  }

  getDescriptor(characteristic: ble.BLECharacteristic, uuid: UUID): ble.BLEDescriptor | null {
    for (let descriptor of characteristic.descriptors) {
      if (descriptor.descriptorUuid.toUpperCase() == uuid.toUpperCase()) {
        return descriptor;
      }
    }
    return null;
  }

  /**
   * Value used to enable notification for a client configuration descriptor
   */
  public static readonly ENABLE_NOTIFICATION_VALUE: byte[] = [0x01, 0x00];
  /**
   * Value used to enable indication for a client configuration descriptor
   */
  public static readonly ENABLE_INDICATION_VALUE: byte[] = [0x02, 0x00];
  /**
   * Value used to disable notifications or indicatinos
   */
  public static readonly DISABLE_NOTIFICATION_VALUE: byte[] = [0x00, 0x00];

  /**
   * notify setting
   */
  private setCharacteristicNotification(gatt: ble.GattClientDevice | null,
                                        characteristic: ble.BLECharacteristic,
                                        useCharacteristicDescriptor: boolean,
                                        enable: boolean,
                                        bleNotifyCallback: BleNotifyCallback | null): boolean {
    if (gatt == null || characteristic == null) {
      this.notifyMsgInit();
      if (bleNotifyCallback != null) {
        bleNotifyCallback.onNotifyFailure(new OtherException("gatt or characteristic equal null"));
      }
      return false;
    }


    try {
      gatt.setCharacteristicChangeNotification(characteristic, enable);
      this.notifyMsgInit();
      bleNotifyCallback?.onNotifySuccess()
    } catch (err) {
      this.notifyMsgInit();
      if (bleNotifyCallback != null) {
        bleNotifyCallback.onNotifyFailure(new OtherException("gatt setNotifyCharacteristicChanged fail"));
      }
      return false;
    }


    let descriptor: ble.BLEDescriptor | null = null;
    if (useCharacteristicDescriptor) {
      descriptor = this.getDescriptor(characteristic, characteristic.characteristicUuid);
    } else {
      descriptor = this.getDescriptor(characteristic, BleConnector.UUID_CLIENT_CHARACTERISTIC_CONFIG_DESCRIPTOR);
    }
    if (descriptor == null) {
      this.notifyMsgInit();
      if (bleNotifyCallback != null) {
        bleNotifyCallback.onNotifyFailure(new OtherException("descriptor equals null"));
      }
      return false;
    } else {
      let u8Array: Uint8Array = new Uint8Array(enable ? BleConnector.ENABLE_NOTIFICATION_VALUE : BleConnector.DISABLE_NOTIFICATION_VALUE)
      descriptor.descriptorValue = this.typedArrayToBuffer(u8Array);
      try {
        gatt.writeDescriptorValue(descriptor)
        return true
      } catch (e) {
        this.notifyMsgInit();
        if (bleNotifyCallback != null) {
          bleNotifyCallback.onNotifyFailure(new OtherException("gatt writeDescriptor fail"));
        }
        return false
      }
    }
  }

  /**
   * indicate
   */
  public enableCharacteristicIndicate(bleIndicateCallback: BleIndicateCallback, uuid_indicate: string,
                                      useCharacteristicDescriptor: boolean): void {
    if (this.mCharacteristic != null
    /*&& (this.mCharacteristic.getProperties() | bluetooth.BLECharacteristic.PROPERTY_NOTIFY) > 0*/
    ) {
      this.handleCharacteristicIndicateCallback(bleIndicateCallback, uuid_indicate);
      this.setCharacteristicIndication(this.mBluetoothGatt, this.mCharacteristic,
        useCharacteristicDescriptor, true, bleIndicateCallback);
    } else {
      if (bleIndicateCallback != null)
        bleIndicateCallback.onIndicateFailure(new OtherException("this characteristic not support indicate!"));
    }
  }


  /**
   * stop indicate
   */
  public disableCharacteristicIndicate(userCharacteristicDescriptor: boolean): boolean {
    if (this.mCharacteristic != null
    /*&& (this.mCharacteristic.getProperties() | bluetooth.BLECharacteristic.PROPERTY_NOTIFY) > 0*/
    ) {
      return this.setCharacteristicIndication(this.mBluetoothGatt, this.mCharacteristic,
        userCharacteristicDescriptor, false, null);
    } else {
      return false;
    }
  }

  /**
   * indicate setting
   */
  private setCharacteristicIndication(gatt: ble.GattClientDevice | null,
                                      characteristic: ble.BLECharacteristic,
                                      useCharacteristicDescriptor: boolean,
                                      enable: boolean,
                                      bleIndicateCallback: BleIndicateCallback | null): boolean {
    if (gatt == null || characteristic == null) {
      this.indicateMsgInit();
      if (bleIndicateCallback != null) {
        bleIndicateCallback.onIndicateFailure(new OtherException("gatt or characteristic equal null"));
      }
      return false;
    }


    try {
      gatt.setCharacteristicChangeIndication(characteristic, enable)
    } catch (e) {
      this.indicateMsgInit();
      if (bleIndicateCallback != null) {
        bleIndicateCallback.onIndicateFailure(new OtherException("gatt setNotifyCharacteristicChanged fail"));
      }
      return false;
    }


    let descriptor: ble.BLEDescriptor | null;
    if (useCharacteristicDescriptor) {
      descriptor = this.getDescriptor(characteristic, characteristic.characteristicUuid);
    } else {
      descriptor = this.getDescriptor(characteristic, BleConnector.UUID_CLIENT_CHARACTERISTIC_CONFIG_DESCRIPTOR);
    }
    if (descriptor == null) {
      this.indicateMsgInit();
      if (bleIndicateCallback != null) {
        bleIndicateCallback.onIndicateFailure(new OtherException("descriptor equals null"));
      }
      return false;
    } else {
      let u8Array: Uint8Array = new Uint8Array(enable ? BleConnector.ENABLE_INDICATION_VALUE : BleConnector.DISABLE_NOTIFICATION_VALUE)
      descriptor.descriptorValue = this.typedArrayToBuffer(u8Array);

      try {
        gatt.writeDescriptorValue(descriptor)
        return true
      } catch (e) {
        this.indicateMsgInit();
        if (bleIndicateCallback != null) {
          bleIndicateCallback.onIndicateFailure(new OtherException("gatt writeDescriptor fail"));
        }
        return false
      }

    }
  }

  /**
   * write
   */
  public writeCharacteristic(data: Uint8Array, bleWriteCallback: BleWriteCallback, uuid_write: string): void {
    if (data == null || data.length <= 0) {
      if (bleWriteCallback != null) {
        bleWriteCallback.onWriteFailure(new OtherException("the data to be written is empty"));
      }
      return;
    }

    if (this.mCharacteristic == null
    /*|| (this.mCharacteristic.getProperties() & (bluetooth.BLECharacteristic.PROPERTY_WRITE | bluetooth.BLECharacteristic.PROPERTY_WRITE_NO_RESPONSE)) == 0*/
    ) {
      if (bleWriteCallback != null) {
        bleWriteCallback.onWriteFailure(new OtherException("this characteristic not support write!"));
      }
      return;
    }

    this.mCharacteristic.characteristicValue = this.typedArrayToBuffer(data);
    this.handleCharacteristicWriteCallback(bleWriteCallback, uuid_write);
    console.info("BleConnetor.writeCharacteristic calling gatt.writeCharacteristic");
    if (this.mBluetoothGatt !== null) {
      try {
        this.mBluetoothGatt.writeCharacteristicValue(this.mCharacteristic, ble.GattWriteType.WRITE)
        if (bleWriteCallback != null) {
          this.writeMsgInit();
          bleWriteCallback.onWriteSuccess(data.length, data.length, data);
        }

      } catch (e) {
        if (bleWriteCallback != null) {
          this.writeMsgInit();
          bleWriteCallback.onWriteFailure(new OtherException("gatt writeCharacteristic fail"));
        }
      }
    }
  }

  /**
   * read
   */
  public readCharacteristic(bleReadCallback: BleReadCallback, uuid_read: string): void {
    if (this.mCharacteristic != null
    /*&& (this.mCharacteristic.getProperties() & bluetooth.BLECharacteristic.PROPERTY_READ) > 0*/
    ) {
      this.handleCharacteristicReadCallback(bleReadCallback, uuid_read);
      this.mBluetoothGatt?.readCharacteristicValue(this.mCharacteristic, (err, characteristic: ble.BLECharacteristic) => {
        this.readMsgInit();
        if (bleReadCallback != null) {
          if (!err) {
            bleReadCallback.onReadSuccess(new Uint8Array(characteristic.characteristicValue));
          } else {
            bleReadCallback.onReadFailure(new OtherException("gatt readCharacteristic fail:" + err.message));
          }
        }
      });
    } else {
      if (bleReadCallback != null) {
        bleReadCallback.onReadFailure(new OtherException("this characteristic not support read!"));
      }
    }
  }

  /**
   * rssi
   */
  public readRemoteRssi(bleRssiCallback: BleRssiCallback): void {
    this.handleRSSIReadCallback(bleRssiCallback);
    this.mBluetoothGatt?.getRssiValue((err, number) => {
      this.rssiMsgInit();
      if (bleRssiCallback != null) {
        if (!err) {
          bleRssiCallback.onRssiSuccess(number);
        } else {
          bleRssiCallback.onRssiFailure(new OtherException("gatt readRemoteRssi fail:" + err.message));
        }
      }
    });
  }

  /**
   * set mtu
   */
  public setMtu(requiredMtu: number, bleMtuChangedCallback: BleMtuChangedCallback): void {
    this.handleSetMtuCallback(bleMtuChangedCallback);

    try {
      if (this.mBluetoothGatt !== null) {
        this.mBluetoothGatt.setBLEMtuSize(requiredMtu)
      }
    } catch (e) {

      this.mtuChangedMsgInit();
      if (bleMtuChangedCallback != null) {
        bleMtuChangedCallback.onSetMTUFailure(new OtherException("gatt requestMtu fail"));
      }

    }
  }

  /**
   * requestConnectionPriority
   *
   * @param connectionPriority Request a specific connection priority. Must be one of
   *                           {@link BluetoothGatt#CONNECTION_PRIORITY_BALANCED},
   *                           {@link BluetoothGatt#CONNECTION_PRIORITY_HIGH}
   *                           or {@link BluetoothGatt#CONNECTION_PRIORITY_LOW_POWER}.
   * @throws IllegalArgumentException If the parameters are outside of their
   *                                  specified range.
   */
  public requestConnectionPriority(connectionPriority: number): boolean {
    //        return this.mBluetoothGatt.requestConnectionPriority(connectionPriority);
    return false; // not supported
  }


  /**************************************** Handle call back ******************************************/

  /**
   * notify
   */
  private handleCharacteristicNotifyCallback(bleNotifyCallback: BleNotifyCallback, uuid_notify: string): void {
    if (bleNotifyCallback != null) {
      this.notifyMsgInit();
      bleNotifyCallback.setKey(uuid_notify);
      bleNotifyCallback.setHandler(this.mHandler);
      this.mBleBluetooth.addNotifyCallback(uuid_notify, bleNotifyCallback);
      this.mHandler.sendMessageDelayed(
        this.mHandler.obtainMessage(BleMsg.MSG_CHA_NOTIFY_START, bleNotifyCallback),
        BleManager.getInstance().getOperateTimeout());
    }
  }

  /**
   * indicate
   */
  private handleCharacteristicIndicateCallback(bleIndicateCallback: BleIndicateCallback, uuid_indicate: string): void {
    if (bleIndicateCallback != null) {
      this.indicateMsgInit();
      bleIndicateCallback.setKey(uuid_indicate);
      bleIndicateCallback.setHandler(this.mHandler);
      this.mBleBluetooth.addIndicateCallback(uuid_indicate, bleIndicateCallback);
      this.mHandler.sendMessageDelayed(
        this.mHandler.obtainMessage(BleMsg.MSG_CHA_INDICATE_START, bleIndicateCallback),
        BleManager.getInstance().getOperateTimeout());
    }
  }

  /**
   * write
   */
  private handleCharacteristicWriteCallback(bleWriteCallback: BleWriteCallback, uuid_write: string): void {
    if (bleWriteCallback != null) {
      this.writeMsgInit();
      bleWriteCallback.setKey(uuid_write);
      bleWriteCallback.setHandler(this.mHandler);
      this.mBleBluetooth.addWriteCallback(uuid_write, bleWriteCallback);
      this.mHandler.sendMessageDelayed(
        this.mHandler.obtainMessage(BleMsg.MSG_CHA_WRITE_START, bleWriteCallback),
        BleManager.getInstance().getOperateTimeout());
    }
  }

  /**
   * read
   */
  private handleCharacteristicReadCallback(bleReadCallback: BleReadCallback, uuid_read: string): void {
    if (bleReadCallback != null) {
      this.readMsgInit();
      bleReadCallback.setKey(uuid_read);
      bleReadCallback.setHandler(this.mHandler);
      this.mBleBluetooth.addReadCallback(uuid_read, bleReadCallback);
      this.mHandler.sendMessageDelayed(
        this.mHandler.obtainMessage(BleMsg.MSG_CHA_READ_START, bleReadCallback),
        BleManager.getInstance().getOperateTimeout());
    }
  }

  /**
   * rssi
   */
  private handleRSSIReadCallback(bleRssiCallback: BleRssiCallback): void {
    if (bleRssiCallback != null) {
      this.rssiMsgInit();
      bleRssiCallback.setHandler(this.mHandler);
      this.mBleBluetooth.addRssiCallback(bleRssiCallback);
      this.mHandler.sendMessageDelayed(
        this.mHandler.obtainMessage(BleMsg.MSG_READ_RSSI_START, bleRssiCallback),
        BleManager.getInstance().getOperateTimeout());
    }
  }

  /**
   * set mtu
   */
  private handleSetMtuCallback(bleMtuChangedCallback: BleMtuChangedCallback): void {
    if (bleMtuChangedCallback != null) {
      this.mtuChangedMsgInit();
      bleMtuChangedCallback.setHandler(this.mHandler);
      this.mBleBluetooth.addMtuChangedCallback(bleMtuChangedCallback);
      this.mHandler.sendMessageDelayed(
        this.mHandler.obtainMessage(BleMsg.MSG_SET_MTU_START, bleMtuChangedCallback),
        BleManager.getInstance().getOperateTimeout());
    }
  }

  public notifyMsgInit(): void {
    this.mHandler.removeMessages(BleMsg.MSG_CHA_NOTIFY_START);
  }

  public indicateMsgInit(): void {
    this.mHandler.removeMessages(BleMsg.MSG_CHA_INDICATE_START);
  }

  public writeMsgInit(): void {
    this.mHandler.removeMessages(BleMsg.MSG_CHA_WRITE_START);
  }

  public readMsgInit(): void {
    this.mHandler.removeMessages(BleMsg.MSG_CHA_READ_START);
  }

  public rssiMsgInit(): void {
    this.mHandler.removeMessages(BleMsg.MSG_READ_RSSI_START);
  }

  public mtuChangedMsgInit(): void {
    this.mHandler.removeMessages(BleMsg.MSG_SET_MTU_START);
  }

  private typedArrayToBuffer(array: Uint8Array): ArrayBuffer {
    return array.buffer.slice(array.byteOffset, array.byteLength + array.byteOffset)
  }
}

class BleConnectorHandler extends Handler {
  bleConnector: BleConnector;

  constructor(bleConnector: BleConnector) {
    super()
    this.bleConnector = bleConnector;
  }

  public handleMessage(msg: Message): void {
    switch (msg.what) {

      case BleMsg.MSG_CHA_NOTIFY_START: {
        let notifyCallback: BleNotifyCallback = msg.obj as BleNotifyCallback;
        if (notifyCallback != null)
          notifyCallback.onNotifyFailure(new TimeoutException());
        break;
      }

      case BleMsg.MSG_CHA_NOTIFY_RESULT: {
        this.bleConnector.notifyMsgInit();

        let notifyCallback: BleNotifyCallback = msg.obj as BleNotifyCallback;
        let status: number = msg.getData().get(BleMsg.KEY_NOTIFY_BUNDLE_STATUS);
        if (notifyCallback != null) {
          if (status == 0) {
            notifyCallback.onNotifySuccess();
          } else {
            notifyCallback.onNotifyFailure(new GattException(status));
          }
        }
        break;
      }

      case BleMsg.MSG_CHA_NOTIFY_DATA_CHANGE: {
        let notifyCallback: BleNotifyCallback = msg.obj as BleNotifyCallback;
        let value: Uint8Array = msg.getData().get(BleMsg.KEY_NOTIFY_BUNDLE_VALUE);
        if (notifyCallback != null) {
          notifyCallback.onCharacteristicChanged(value);
        }
        break;
      }

      case BleMsg.MSG_CHA_INDICATE_START: {
        let indicateCallback: BleIndicateCallback = msg.obj as BleIndicateCallback;
        if (indicateCallback != null)
          indicateCallback.onIndicateFailure(new TimeoutException());
        break;
      }

      case BleMsg.MSG_CHA_INDICATE_RESULT: {
        this.bleConnector.indicateMsgInit();

        let indicateCallback: BleIndicateCallback = msg.obj as BleIndicateCallback;
        let status: number = msg.getData().get(BleMsg.KEY_INDICATE_BUNDLE_STATUS);
        if (indicateCallback != null) {
          if (status == 0) {
            indicateCallback.onIndicateSuccess();
          } else {
            indicateCallback.onIndicateFailure(new GattException(status));
          }
        }
        break;
      }

      case BleMsg.MSG_CHA_INDICATE_DATA_CHANGE: {
        let indicateCallback: BleIndicateCallback = msg.obj as BleIndicateCallback;
        let value: Uint8Array = msg.getData().get(BleMsg.KEY_INDICATE_BUNDLE_VALUE);
        if (indicateCallback != null) {
          indicateCallback.onCharacteristicChanged(value);
        }
        break;
      }

      case BleMsg.MSG_CHA_WRITE_START: {
        let writeCallback: BleWriteCallback = msg.obj as BleWriteCallback;
        if (writeCallback != null) {
          writeCallback.onWriteFailure(new TimeoutException());
        }
        break;
      }

      case BleMsg.MSG_CHA_WRITE_RESULT: {
        this.bleConnector.writeMsgInit();

        let writeCallback: BleWriteCallback = msg.obj as BleWriteCallback;
        let status: number = msg.getData().get(BleMsg.KEY_WRITE_BUNDLE_STATUS);
        let value: Uint8Array = msg.getData().get(BleMsg.KEY_WRITE_BUNDLE_VALUE);
        if (writeCallback != null) {
          if (status == 0) {
            writeCallback.onWriteSuccess(BleWriteState.DATA_WRITE_SINGLE, BleWriteState.DATA_WRITE_SINGLE, value);
          } else {
            writeCallback.onWriteFailure(new GattException(status));
          }
        }
        break;
      }

      case BleMsg.MSG_CHA_READ_START: {
        let readCallback: BleReadCallback = msg.obj as BleReadCallback;
        if (readCallback != null)
          readCallback.onReadFailure(new TimeoutException());
        break;
      }

      case BleMsg.MSG_CHA_READ_RESULT: {
        this.bleConnector.readMsgInit();

        let readCallback: BleReadCallback = msg.obj as BleReadCallback;
        let status: number = msg.getData().get(BleMsg.KEY_READ_BUNDLE_STATUS);
        let value: Uint8Array = msg.getData().get(BleMsg.KEY_READ_BUNDLE_VALUE);
        if (readCallback != null) {
          if (status == 0) {
            readCallback.onReadSuccess(value);
          } else {
            readCallback.onReadFailure(new GattException(status));
          }
        }
        break;
      }

      case BleMsg.MSG_READ_RSSI_START: {
        let rssiCallback: BleRssiCallback = msg.obj as BleRssiCallback;
        if (rssiCallback != null)
          rssiCallback.onRssiFailure(new TimeoutException());
        break;
      }

      case BleMsg.MSG_READ_RSSI_RESULT: {
        this.bleConnector.rssiMsgInit();

        let rssiCallback: BleRssiCallback = msg.obj as BleRssiCallback;
        let status: number = msg.getData().get(BleMsg.KEY_READ_RSSI_BUNDLE_STATUS);
        let value: number = msg.getData().get(BleMsg.KEY_READ_RSSI_BUNDLE_VALUE);
        if (rssiCallback != null) {
          if (status == 0) {
            rssiCallback.onRssiSuccess(value);
          } else {
            rssiCallback.onRssiFailure(new GattException(status));
          }
        }
        break;
      }

      case BleMsg.MSG_SET_MTU_START: {
        let mtuChangedCallback: BleMtuChangedCallback = msg.obj as BleMtuChangedCallback;
        if (mtuChangedCallback != null)
          mtuChangedCallback.onSetMTUFailure(new TimeoutException());
        break;
      }

      case BleMsg.MSG_SET_MTU_RESULT: {
        this.bleConnector.mtuChangedMsgInit();

        let mtuChangedCallback: BleMtuChangedCallback = msg.obj as BleMtuChangedCallback;
        let status: number = msg.getData().get(BleMsg.KEY_SET_MTU_BUNDLE_STATUS);
        let value: number = msg.getData().get(BleMsg.KEY_SET_MTU_BUNDLE_VALUE);
        if (mtuChangedCallback != null) {
          if (status == 0) {
            mtuChangedCallback.onMtuChanged(value);
          } else {
            mtuChangedCallback.onSetMTUFailure(new GattException(status));
          }
        }
        break;
      }
    }
  }
}
