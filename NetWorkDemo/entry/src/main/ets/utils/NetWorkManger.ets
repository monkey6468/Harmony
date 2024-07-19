import axios, { AxiosResponse } from '@ohos/axios';

export class Response<Object> {
  code?: number
  msg?: String
  result?: Object
}

export class NetWorkManger {
  private static tag: string = NetWorkManger.name

  // 支持async/await用法
  static async requsetCmd(): Promise<Response<object>> {
    let baseUrl: string = "https://api.oioweb.cn/api/common/GasolinePriceQuery"
    try {
      const response: AxiosResponse = await axios.get<string, AxiosResponse<Object>, null>(baseUrl, {
        // params: {
        //   params: enStr,
        //   v: 2,
        //   cmd: cmd
        // }
      });
      console.log(NetWorkManger.tag, JSON.stringify(response.data))
      return (response.data)
    } catch (error) {
      console.error(JSON.stringify(error))
      return (error)
    }
  }
}