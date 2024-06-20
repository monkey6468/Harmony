import { request } from '../utils/Request'
import { Process } from '../types/Process'
import http from '@ohos.net.http'

// 分页获取我的申请列表
/**
 * type_id：0：全部 1：人事管理 2：行政事务 3：财务类 4：业务相关
 */
export const getProcessList = (extraData: {
  type_id: number
  page: number
  pageSize: number
}) => {
  return request<{
    total: number
    items: Process[]
  }>({
    url: `process/list?type_id=${extraData.type_id}&page=${extraData.page}&pageSize=${extraData.pageSize}`
  })
}

// 新增请假申请流程
export const addProcess = (extraData: object) => {
  return request({
    url: 'process/add',
    method: http.RequestMethod.POST,
    extraData
  })
}