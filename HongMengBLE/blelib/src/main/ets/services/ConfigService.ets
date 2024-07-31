import BleManager from '../BleManager';
import { HexUtil } from '../utils/HexUtil';

export class ConfigService {
  private deviceBleManager: BleManager

  constructor(deviceBleManager: BleManager) {
    this.deviceBleManager = deviceBleManager
  }

  /**
   * 写入声音配置
   * @param soundSetMsg
   * @returns
   */
  writeSoundSetting(sendData: ArrayBuffer): Promise<boolean> {
    let response = this.deviceBleManager.writeUartRXCharacteristic(sendData)
    return response
  }
}