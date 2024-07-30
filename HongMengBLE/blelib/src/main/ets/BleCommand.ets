import { ble } from '@kit.ConnectivityKit';
import { HexUtil } from './utils/HexUtil';
import { BusinessError } from '@kit.BasicServicesKit';
import { TimeoutManager } from './TimeoutManager';

/**
 * 基础命令类：包含通道信息、特征、数据、超时时间、重试机制等属性和方法。
 */
export class BleCommand {
  //保存设备返回的数据
  isReceiveFinish: ((checkData: ArrayBuffer | null, storedData: Uint8Array) => boolean) | null = null;
  private gatt: ble.GattClientDevice | null;
  private serviceUuid: string;
  private data: ArrayBuffer;
  private timeout: number;
  private retries: number;
  private currentRetries: number = 0;
  private resolve: ((value: ArrayBuffer | PromiseLike<ArrayBuffer>) => void) | null = null;
  private reject: ((reason?: object) => void) | null = null;
  private promise: Promise<ArrayBuffer>;
  //发送超时定时器
  private sendTimeoutManager = new TimeoutManager();
  //接收超时定时器
  private receiveTimeoutManager = new TimeoutManager();

  /**
   * 创建一个新的蓝牙命令实例
   * @param gatt Gatt 客户端设备实例
   * @param serviceUuid 服务 UUID
   * @param data 要写入的数据
   * @param timeout 命令超时时间（毫秒）
   * @param retries 命令失败后的重试次数
   */
  constructor(
    gatt: ble.GattClientDevice | null,
    serviceUuid: string,
    data: ArrayBuffer,
    timeout: number = 0,
    retries: number = 0
  ) {
    this.gatt = gatt;
    this.serviceUuid = serviceUuid;
    this.data = data;
    this.timeout = timeout;
    this.retries = retries;

    this.promise = new Promise((resolve, reject) => {
      this.resolve = resolve;
      this.reject = reject;
    });
  }

  /**
   * 设置命令失败后的重试次数
   * @param retries 新的重试次数
   */
  setRetries(retries: number): void {
    this.retries = retries;
  }

  fail(error: object) {
    if (this.reject) {
      this.reject(error);
    }
  }

  awaitResponse(): Promise<ArrayBuffer> {
    return this.promise;
  }

  /**
   * 执行命令
   * @returns Promise<void>
   */
  execute(): Promise<void> {
    return new Promise(async (resolve, reject) => {
      console.log('执行命令-> 开始')
      this.resolveFn = resolve;
      this.rejectFn = reject;
      if (!this.gatt) {
        return reject('Gatt 客户端设备实例为空');
      }

      //Gatt service
      let gattServiceList = await this.gatt.getServices()

      try {
        const service = gattServiceList.find(s => s.serviceUuid === this.serviceUuid);
        if (!service) {
          return reject(`执行命令-> 未找到服务 ${this.serviceUuid}`);
        }
        const characteristic = service.characteristics.find(c => c.properties?.write);
        if (!characteristic) {
          return reject(`执行命令-> 未找到特征`);
        }

        this.sendTimeoutManager.start(() => {
          this.retry()
        }, this.timeout);

        this.writeCharacteristicValue(this.data, this.gatt, characteristic);
      } catch (err) {
        reject(err);
      }
    });
  }

  // 当设备回复时调用
  async onDeviceResponse(responseData: ArrayBuffer) {
    console.log('执行命令-> 结束 收到设备回复')
    this.sendTimeoutManager.cancel();
    this.receiveTimeoutManager.start(() => {
      this.retry()
    }, this.timeout);
  }

  success(responseData: ArrayBuffer) {
    this.resolveFn();
    if (this.resolve) {
      this.resolve(responseData);
    }
  }

  failure() {
    this.rejectFn()
    if (this.reject) {
      this.reject()
    }
  }

  //重试
  retry() {
    if (this.currentRetries < this.retries) {
      this.currentRetries++;
      console.log(`执行命令-> 超时重试 开始 第${this.currentRetries}次重试`);
      this.execute().then(this.resolveFn).catch(this.rejectFn);
    } else {
      console.log(`执行命令-> 超时重试 结束 重试${this.currentRetries}次都失败了`);
      this.rejectFn(Error(`执行命令-> 命令在 ${this.timeout}ms 后超时`));
    }
  }

  // 用于标识命令是否完成的标志
  private resolveFn: () => void = () => {
  };
  private rejectFn: (reason?: object) => void = () => {
  };

  /**
   * 写入特征值
   * @param data 要写入的数据
   * @param gatt Gatt 客户端设备实例
   * @param characteristic 特征实例
   * @returns Promise<void>
   */
  private async writeCharacteristicValue(
    data: ArrayBuffer,
    gatt: ble.GattClientDevice | null,
    characteristic: ble.BLECharacteristic
  ): Promise<void> {
    return new Promise(async (resolve, reject) => {
      try {
        if (gatt) {
          console.log('BluetoothPage writeCharacteristicValue', JSON.stringify(characteristic));

          // 根据 MTUSize 分包
          const arrayBuffer = HexUtil.splitArrayBuffer(data, 20);
          for (let i = 0; i < arrayBuffer.length; i++) {
            const value = arrayBuffer[i]
            characteristic.characteristicValue = value
            await gatt.writeCharacteristicValue(characteristic, ble.GattWriteType.WRITE);
            console.log(`writeCharacteristicValue wrValue--> :  ${HexUtil.arrayBufferToHex(value)}`)
          }
          console.log('BluetoothPage writeCharacteristicValue finish');
          resolve();
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
}

// function concatenateArrayBuffers(buffers: ArrayBuffer[]): ArrayBuffer {
//   const totalLength = buffers.reduce((acc, buffer) => acc + buffer.byteLength, 0);
//   const result = new Uint8Array(totalLength);
//   let offset = 0;
//   for (const buffer of buffers) {
//     result.set(new Uint8Array(buffer), offset);
//     offset += buffer.byteLength;
//   }
//   return result.buffer;
// }

// function subArrayBuffer(buffer: ArrayBuffer, start: number, length?: number): ArrayBuffer {
//   return buffer.slice(start, length ? start + length : undefined);
// }
//
// function readInt32BE(buffer: ArrayBuffer, offset: number): number {
//   const view = new DataView(buffer);
//   return view.getInt32(offset, false);
// }
//
// function arrayBufferToByteArray(buffer: ArrayBuffer): Uint8Array {
//   return new Uint8Array(buffer);
// }