import { ble, constant } from '@kit.ConnectivityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import Observable from './utils/Observable'
import { ConfigService } from './services/ConfigService'
import { HexUtil } from './utils/HexUtil'
import { DeviceConnectStatus } from './scan/BluetoothScanner'

//通道1
const SERVICE_UUIDS = ["FFD5"] // 智能灯
// const SERVICE_UUIDS = ["FFF0"] // autophix设备

class BleManager {
  //配置相关
  configService = new ConfigService(this);
  //设备连接状态
  deviceConnectStatus = new Observable<DeviceConnectStatus>();
  //Gatt 客户端设备实例
  private gattClientDevice: ble.GattClientDevice | null = null;

  private constructor() {
  }

  public static create(): BleManager {
    return new BleManager()
  }

  public init(): void {
    console.log("BleManager initialization")
  }

  /**
   * client获取远端蓝牙低功耗设备名
   */
  getDeviceName(): Promise<string> {
    return new Promise((resolve, reject) => {
      const gattClient = this.gattClientDevice
      if (gattClient == null) {
        reject("gattClientDevice is null")
        return
      }
      gattClient.getDeviceName((err: BusinessError, data: string) => {
        if (err) {
          console.info('device name err ' + JSON.stringify(err));
          reject(err);
        } else {
          console.info('device name ' + JSON.stringify(data));
          resolve(data);
        }
      });
    });
  }

  //设备连接成功且通道加载完成
  isReady(): boolean {
    return this.deviceConnectStatus.getData() == DeviceConnectStatus.DeviceReady;
  }

  /**
   * 连接设备
   */
  connect(device: ble.ScanResult): ble.GattClientDevice | null {
    return this.connectById(device?.deviceId)
  }

  /**
   * 通过deviceId(address)连接设备
   * @param deviceId
   */
  connectById(deviceId: string): ble.GattClientDevice | null {
    const clientDevice = ble.createGattClientDevice(deviceId)
    this.gattClientDevice = clientDevice
    if (clientDevice) {

      //连接状态
      clientDevice.on('BLEConnectionStateChange', (state: ble.BLEConnectionChangeState) => {
        //let deviceId = state.deviceId;
        const connectState = state.state;
        console.log(`连接状态改变 state ${JSON.stringify(state)}`);

        switch (connectState) {
          case constant.ProfileConnectionState.STATE_DISCONNECTED: // 0设备已断开连接
            this.deviceConnectStatus.notify(DeviceConnectStatus.DeviceDisconnected);
            break;

          case constant.ProfileConnectionState.STATE_CONNECTING: // 1设备正在连接
            this.deviceConnectStatus.notify(DeviceConnectStatus.DeviceConnecting);
            break;

          case constant.ProfileConnectionState.STATE_CONNECTED: // 2设备已连接
            this.deviceConnectStatus.notify(DeviceConnectStatus.DeviceConnected);
            this.getServices();
            break;

          case constant.ProfileConnectionState.STATE_DISCONNECTING: // 3设备正在断开连接
            this.deviceConnectStatus.notify(DeviceConnectStatus.DeviceDisconnecting);
            break;

          default:
          // Handle unexpected states if necessary
            break;
        }

      })

      //连接
      try {
        this.gattClientDevice.connect()
      } catch (e) {

      }

    }
    return clientDevice
  }

  /**
   * client端断开与远端蓝牙低功耗设备的连接 （断开ble设备）
   */
  disconnect() {
    const gattClient = this.gattClientDevice
    if (gattClient) {
      //gattClient.off('BLEConnectionStateChange')
      gattClient.disconnect()
    }
  }

  /**
   * 通道1 写特征
   * @param data 要写入的数据
   * @returns Promise<void>
   */
  async writeUartRXCharacteristic(data: ArrayBuffer): Promise<boolean> {
    let gattServiceList = await this.gattClientDevice?.getServices()
    const service = gattServiceList!.find(s => s.serviceUuid.indexOf(SERVICE_UUIDS[0]) != -1);
    if (!service) {
      console.log(`执行命令-> 未找到服务 ${SERVICE_UUIDS[0]}`);
      return false
    }
    const characteristic = service.characteristics.find(c => c.properties?.write);
    if (!characteristic) {
      console.log(`执行命令-> 未找到特征`);
      return false
    }

    let response = this.writeCharacteristicValue(data, this.gattClientDevice, characteristic)
    return response
  }

  /**
   * 写入特征值
   * @param data 要写入的数据
   * @param gatt Gatt 客户端设备实例
   * @param characteristic 特征实例
   * @returns Promise<void>
   */
  private writeCharacteristicValue(
    data: ArrayBuffer,
    gatt: ble.GattClientDevice | null,
    characteristic: ble.BLECharacteristic
  ): Promise<boolean> {
    return new Promise(async (resolve, reject) => {
      try {
        if (gatt) {
          console.log('BluetoothPage writeCharacteristicValue', JSON.stringify(characteristic));

          // 根据 MTUSize 分包
          const arrayBuffer = HexUtil.splitArrayBuffer(data, 20);
          for (let i = 0; i < arrayBuffer.length; i++) {
            const value = arrayBuffer[i]
            characteristic.characteristicValue = value
            gatt.writeCharacteristicValue(characteristic, ble.GattWriteType.WRITE);
            console.log(`writeCharacteristicValue wrValue--> :  ${HexUtil.arrayBufferToHex(value)}`)
          }
          console.log('BluetoothPage writeCharacteristicValue finish');
          resolve(true);
        } else {
          reject(new Error('Gatt client device is null or undefined'));
        }
      } catch (err) {
        const errorCode = (err as BusinessError).code;
        const errorMessage = (err as BusinessError).message;
        console.error('errCode: ' + errorCode + ', errMessage: ' + errorMessage);
        reject(new Error(`errCode: ${errorCode}, errMessage: ${errorMessage}`));
      }

    });
  }

  /**
   * client端获取蓝牙低功耗设备的所有服务，即服务发现 (获取所有服务)
   */
  private async getServices() {
    if (this.gattClientDevice) {
      const result: Array<ble.GattService> = await this.gattClientDevice.getServices();
      console.info('getServices successfully:' + JSON.stringify(result));

      // let gatt = this.gattClientDevice;

      // for (const item of result) {
      //   // 通道1
      //   if (item.serviceUuid === UART_SERVICE_UUID) {
      //     for (let characteristic of item.characteristics) {
      //       console.log(`getServices 通道1 characteristic = '${characteristic?.characteristicUuid}'`);
      //       // setNotification
      //       const success = await this.setNotificationChannel(gatt, item, characteristic, true);
      //       if (success) {
      //         console.log(`Notification set successfully for characteristic（通道1） ${characteristic.characteristicUuid}`);
      //       } else {
      //         console.log(`Failed to set notification for characteristic（通道1） ${characteristic.characteristicUuid}`);
      //       }
      //     }
      //   }
      // }

      //接收设备数据
      this.onBleCharacteristicChange()

      //通道加载完成
      this.deviceConnectStatus.notify(DeviceConnectStatus.DeviceReady)
    }
  }

  /**
   * 向服务端发送设置通知此indicate征值请求
   */
  // private async setNotificationChannel(
  //   gatt: ble.GattClientDevice | null,
  //   gattService: ble.GattService | undefined,
  //   characteristic: ble.BLECharacteristic,
  //   enable: boolean
  // ): Promise<boolean> {
  //   if (!gattService) {
  //     console.log('bluetooth gattServiceInfo is undefined ');
  //     return false; // 返回失败
  //   }
  //
  //   if (gatt == null) {
  //     console.log('gatt is null')
  //     return false; // 返回失败
  //   }
  //
  //   try {
  //     if (gatt) {
  //       console.log(`setNotificationChannel characteristic UUID: ${characteristic.characteristicUuid}, enable: ${enable}`);
  //       await gatt?.setCharacteristicChangeNotification(characteristic, enable)
  //       console.log('BluetoothPage setCharacteristicChangeNotification finish');
  //       return true; // 返回成功
  //     }
  //   } catch (err) {
  //     console.error('errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
  //     return false; // 返回失败
  //   }
  //   return false; // 如果没有gatt，返回失败
  // }

  /**
   * 订阅蓝牙低功耗设备的特征值变化事件 (接收消息)
   */
  private onBleCharacteristicChange() {
    try {
      if (this.gattClientDevice) {
        //监听
        this.gattClientDevice.on('BLECharacteristicChange', (characteristicChangeReq: ble.BLECharacteristic) => {
          console.log('xwh bleCharacteristicChange', JSON.stringify(characteristicChangeReq));
        })
      }
    } catch (err) {
      console.error('bleCharacteristicChange errCode: ' + (err as BusinessError).code + ', errMessage: ' +
      (err as BusinessError).message);
    }
  }

  // /**
  //  * client端读取蓝牙低功耗设备特定服务的特征值 (读取指定通道的特征)
  //  */
  // private async readCharacteristicValue(
  //   gatt: ble.GattClientDevice | null | undefined,
  //   characteristic: ble.BLECharacteristic,
  // ): Promise<ArrayBuffer | null> {
  //   return new Promise<ArrayBuffer | null>(async (resolve, reject) => {
  //     if (!gatt) {
  //       console.log('gatt is not available ');
  //       resolve(null);
  //     }
  //
  //     try {
  //       if (gatt) {
  //         const bleCharacteristicDataOut = await gatt.readCharacteristicValue(characteristic);
  //         const characteristicValue: ArrayBuffer = bleCharacteristicDataOut.characteristicValue;
  //         console.info(`readCharacteristicValue : ${HexUtil.arrayBufferToHex(characteristicValue)}, for: ${bleCharacteristicDataOut.characteristicUuid}`);
  //         resolve(characteristicValue);
  //       }
  //     } catch (err) {
  //       const errorMessage = 'Error occurred while reading characteristic value';
  //       console.error(errorMessage + ', err: ', err);
  //       reject(new Error(errorMessage));
  //     }
  //   });
  // }
}

export default BleManager;