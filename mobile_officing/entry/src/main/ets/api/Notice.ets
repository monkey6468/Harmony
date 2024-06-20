import { request } from '../utils/Request'
import { Notice } from '../types/Notice'

// 获取公司公告列表
export const getNoticeList = () => {
  return request<Notice[]>({
    url: 'notice/list'
  })
}