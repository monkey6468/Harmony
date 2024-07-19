import axios, { AxiosResponse } from '@ohos/axios';
import { OilPriceModel } from '../model/OilPriceModel';
import { ApiRes } from './Data';

export class NetWorkManger {
  private static tag: string = NetWorkManger.name

  // 支持async/await用法
  static async requsetCmd(): Promise<OilPriceModel> {
    try {
      let baseUrl: string = "https://api.oioweb.cn/api/common/GasolinePriceQuery"
      const response: AxiosResponse = await axios.get<string, AxiosResponse<OilPriceModel>, null>(baseUrl, {
        // params: {
        //   params: enStr,
        //   v: 2,
        //   cmd: cmd
        // }
      });
      let retModel: OilPriceModel = response.data
      console.log(NetWorkManger.tag, JSON.stringify(response.data))
      return (retModel)
    } catch (error) {
      return (error as OilPriceModel)
      console.error(JSON.stringify(error))
      // return JSON.stringify(error)
    }
  }
}