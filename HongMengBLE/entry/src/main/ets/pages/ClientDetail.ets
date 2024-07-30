import { ble } from '@kit.ConnectivityKit';
import { promptAction, router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

import { BleManager } from '@ohos/blebib';
import { DeviceConnectStatus } from '@ohos/blebib/src/main/ets/data/DeviceConnectStatus';

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
  //读取的电池特征（电量）
  @State characteristicValue: string = '';
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
          Text('连接状态')
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

        //读取指定通道（电量）的特征
        Column({ space: 10 }) {
          Button('client端读取蓝牙低功耗设备电量的特征值').onClick(async () => {
            const characteristicValue = await this.bleManager.readBattery()
            if (characteristicValue) {
              // 创建一个DataView来读取ArrayBuffer
              const dataView = new DataView(characteristicValue);
              // 从DataView中获取第一个字节的值
              const firstByte = dataView.getUint8(0); // 这里假设你想要获取的是无符号整数
              this.characteristicValue = '特征值：' + firstByte;
            }

          })

          Scroll() {
            if (this.characteristicValue) {
              Text(JSON.stringify(this.characteristicValue))
            } else {
              Text('暂无数据')
            }
          }
          .height(50)
          .scrollBar(BarState.Off)
        }
        .itemStyle()

        //写特征值(630按键音 开)
        Row() {
          Button('写特征值 (按键音 开)').onClick(async () => {
            let uint8Array = new Uint8Array([0xff, 0x07, 0xf0, 0x32, 0xfe]);
            let sendData = this.typedArrayToBuffer(uint8Array)

            console.log(`UART RX Characteristic write start responseData `)
            this.bleManager.configService.writeSoundSetting(sendData)
              .then((response: Boolean) => {
                console.log(`UART RX Characteristic write end response:${response} `)
                //提示写入成功
                promptAction.showToast({ message: '写入成功' })
              })
              .catch((error: Error) => {
                console.error('UART RX Characteristic write failed:', error.message);
                //提示写入失败
                promptAction.showToast({ message: '写入失败' })
              })

          })
            .type(ButtonType.Normal)
            .width('100%')
        }

        //写特征值 (630按键音 关)
        Row() {
          Button('写特征值 (按键音 关)').onClick(() => {

            let uint8Array = new Uint8Array([0xff, 0x07, 0x0f, 0x32, 0xfe]);
            let sendData = this.typedArrayToBuffer(uint8Array)

            this.bleManager.configService.writeSoundSetting(sendData)
              .then((response: Boolean) => {
                console.log(`UART RX Characteristic write end response:${response} `)
                //提示写入成功
                promptAction.showToast({ message: '写入成功' })
              })
              .catch((error: Error) => {
                console.error('UART RX Characteristic write failed:', error.message);
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

  private typedArrayToBuffer(array: Uint8Array): ArrayBuffer {
    return array.buffer.slice(array.byteOffset, array.byteLength + array.byteOffset)
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