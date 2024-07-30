import BleManager from '../BleManager';
import { common } from '../proto/common';
import { config } from '../proto/config';
import { TransmitCompleteCommand } from '../TransmitCompleteCommand';
import { ArrayBufferUtil } from '../utils/ArrayBufferUtil';

export class ConfigService {
  private deviceBleManager: BleManager

  constructor(deviceBleManager: BleManager) {
    this.deviceBleManager = deviceBleManager
  }

  private async sendConfigCommand(
    commandMainServiceType: number,
    configServiceType: number,
    configOperateType: number,
    sendData: ArrayBuffer,
    isReceiveFinish: ((checkData: ArrayBuffer | null, storedData: Uint8Array) => boolean) | null = null
  ): Promise<ArrayBuffer> {

    if (isReceiveFinish == null) {
      isReceiveFinish = (checkData: ArrayBuffer | null, storedData: Uint8Array) => {
        if (!checkData) {
          return false
        }
        const completeCommand = new TransmitCompleteCommand(checkData)
        return (
          completeCommand.mainService === commandMainServiceType &&
            completeCommand.mainOperation === configOperateType &&
            completeCommand.secondService === configServiceType
        )
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
    const commandMainServiceType = common.service_type_index.enum_SERVICE_TYPE_INDEX_CONFIG
    const configServiceType = config.CONFIG_SERVICE_TYPE.enum_CONFIG_SERVICE_TYPE_SOUND
    const configOperateType = config.CONFIG_OPERATE_TYPE.enum_CONFIG_OPERATE_TYPE_SET

    const responseBytes = await this.sendConfigCommand(commandMainServiceType, configServiceType, configOperateType, sendData)
    return ArrayBufferUtil.isCommandStatusSuccess(responseBytes) ?? false
  }
}