import { request } from '../utils/Request'
import { Salary } from '../types/Salary'

// 分页获取工资列表
export const getSalaryList = (extraData: {
  page: number;
  pageSize: number
}) => {
  return request<{
    total: number
    items: Salary[]
  }>({
    url: "salary/list",
    extraData
  })
}

// 获取工资详情
export const getSalaryInfo = (id: string) => {
  return request<Salary>({
    url: `salary/info?id=${id}`
  })
}