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
  async writeSoundSetting(sendData: ArrayBuffer): Promise<boolean> {
    let response = this.deviceBleManager.writeUartRXCharacteristic(sendData)
    console.info('xwh22', JSON.stringify(response), response);
    return response
  }
}