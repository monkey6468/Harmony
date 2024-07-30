import BleManager from '../BleManager';
import { HexUtil } from '../utils/HexUtil';

export class ConfigService {
  private deviceBleManager: BleManager

  constructor(deviceBleManager: BleManager) {
    this.deviceBleManager = deviceBleManager
  }

  private async sendConfigCommand(
    sendData: ArrayBuffer,
    isReceiveFinish: ((checkData: ArrayBuffer | null, storedData: Uint8Array) => boolean) | null = null
  ): Promise<ArrayBuffer> {

    if (isReceiveFinish == null) {
      isReceiveFinish = (checkData: ArrayBuffer | null, storedData: Uint8Array) => {
        if (!checkData) {
          return false
        }
        return true
      }
    }

    return await this.deviceBleManager.writeUartRXCharacteristic(sendData, isReceiveFinish)
  }

  /**
   * 写入声音配置
   * @param soundSetMsg
   * @returns
   */
  async writeSoundSetting(sendData: ArrayBuffer): Promise<boolean> {
    const responseBytes = await this.sendConfigCommand(sendData)
    return HexUtil.isCommandStatusSuccess(responseBytes) ?? false
  }
}