import { ble } from '@kit.ConnectivityKit';
import { promptAction, router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

import { BleManager } from '@ohos/blebib';
import Util from '../utils/Util';
import { DeviceConnectStatus } from '@ohos/blebib/src/main/ets/scan/BluetoothScanner';

@Entry
@Component
struct ClientDetail {
  device: ble.ScanResult = router.getParams() as ble.ScanResult;
  bleManager = BleManager.create()
  @State gattClient: ble.GattClientDevice | undefined = undefined;
  @State deviceName: string = '';
  //连接开关
  @State connectSwitch: boolean = false;
  //是否连接成功
  @State connectStateSwitch: boolean = false;
  //连接状态
  @State devConnectState: DeviceConnectStatus = DeviceConnectStatus.DeviceDisconnected;
  // 设备连接状态观察者
  deviceConnectStatusObserver = (connectStatus: DeviceConnectStatus) => {
    console.log(`设备连接状态观察者-> connectStatusObserver ${DeviceConnectStatus[connectStatus]}`);

    if (connectStatus == DeviceConnectStatus.DeviceReady) {
      this.connectStateSwitch = true;
    } else {
      this.connectStateSwitch = false;
    }
    this.devConnectState = connectStatus
  };

  aboutToAppear(): void {
    this.bleManager.deviceConnectStatus.subscribe(this.deviceConnectStatusObserver)
  }

  aboutToDisappear(): void {
    this.bleManager.deviceConnectStatus.unsubscribe(this.deviceConnectStatusObserver)
  }

  getConnectStateTitle(): string {
    let title = ""
    let connectionState = this.devConnectState
    switch (connectionState) {
      case 0:
        title = "正在连接"
        break
      case 1:
        title = "已连接"
        break
      case 2:
        title = "正在断开连接"
        break
      case 3:
        title = "已断开连接"
        break
      case 4:
        title = "准备就绪"
        break
    }
    return title
  }

  build() {
    Scroll() {
      Column({ space: 10 }) {
        Text() {
          Span('设备名称：  ')
          Span(this.deviceName)
        }
        .itemStyle()

        //连接状态
        Row() {
          Text('连接状态:' + this.getConnectStateTitle())
          Blank()

          if (this.devConnectState == DeviceConnectStatus.DeviceConnecting ||
            this.devConnectState == DeviceConnectStatus.DeviceConnected) {
            LoadingProgress().height(15).width(15)
          } else {
            Toggle({ type: ToggleType.Switch, isOn: this.connectStateSwitch })
              .enabled(false)
          }
        }
        .itemStyle()

        //连接
        Row() {
          Text('连接开关')
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.connectSwitch })
            .onChange((isOn: boolean) => {
              if (isOn) {
                this.connectServer()
              } else {
                this.disconnectServer()
              }
              console.info('ble server instanceSwitch status:' + isOn)
            })
        }
        .itemStyle()

        Row() {
          Button('打开灯').onClick(async () => {
            let uint8Array = new Uint8Array([0xff, 0x07, 0xf0, 0x32, 0xfe]);
            let sendData = Util.typedArrayToBuffer(uint8Array)

            this.bleManager.configService.writeSoundSetting(sendData)
              .then((response: Boolean) => {
                console.log(`xwh RX Characteristic write end response:${response} `)
                //提示写入成功
                promptAction.showToast({ message: `写入成功:${response}` })
              })
              .catch((error: Error) => {
                console.error('xwh RX Characteristic write failed:', error.message);
                //提示写入失败
                promptAction.showToast({ message: '写入失败' })
              })

          })
            .type(ButtonType.Normal)
            .width('100%')
        }

        Row() {
          Button('关闭灯').onClick(() => {

            let uint8Array = new Uint8Array([0xff, 0x07, 0x0f, 0x32, 0xfe]);
            let sendData = Util.typedArrayToBuffer(uint8Array)

            this.bleManager.configService.writeSoundSetting(sendData)
              .then((response: Boolean) => {
                console.log(`xwh RX Characteristic write end response:${response} `)
                //提示写入成功
                promptAction.showToast({ message: `写入成功:${response}` })
              })
              .catch((error: Error) => {
                console.error('xwh RX Characteristic write failed:', error.message);
                //提示写入失败
                promptAction.showToast({ message: '写入失败' })
              })
          })
            .type(ButtonType.Normal)
            .width('100%')
        }

        Row() {
          Button('查询定时器').onClick(() => {

            let uint8Array = new Uint8Array([0x24, 0x2a, 0x2b, 0x42]);
            let sendData = Util.typedArrayToBuffer(uint8Array)

            this.bleManager.configService.writeSoundSetting(sendData)
              .then((response: Boolean) => {
                console.log(`xwh RX Characteristic write end response:${response} `)
                //提示写入成功
                promptAction.showToast({ message: `写入成功:${response}` })
              })
              .catch((error: Error) => {
                console.error('xwh RX Characteristic write failed:', error.message);
                //提示写入失败
                promptAction.showToast({ message: '写入失败' })
              })
          })
            .type(ButtonType.Normal)
            .width('100%')
        }
      }
      .width('100%')
      .padding({
        left: 15,
        right: 15,
        top: 20,
        bottom: 20
      })
      .backgroundColor($r('app.color.light_gray'))
    }
    .scrollBar(BarState.Off)
  }

  /**
   * client端发起连接远端蓝牙低功耗设备 （连接ble设备）
   */
  connectServer() {
    if (!this.bleManager.isReady()) {
      //连接设备
      this.gattClient = this.bleManager.connect(this.device)!;

      //获取设备名称
      this.bleManager.getDeviceName().then(deviceName => {
        this.deviceName = deviceName
      }).catch((error: BusinessError) => {
        console.error('获取设备名称 BusinessError:', error);
      })
    }
  }

  /**
   * client端断开与远端蓝牙低功耗设备的连接 （断开ble设备）
   */
  disconnectServer() {
    this.bleManager.disconnect()
  }
}

@Styles
function itemStyle() {
  .width('100%')
  .padding({
    left: 15,
    right: 15,
    top: 8,
    bottom: 8
  })
  .backgroundColor($r('app.color.white'))
  .borderRadius(10)
}