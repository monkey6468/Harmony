import { request } from '../utils/Request'
import { Employee } from '../types/Employee'
import { Department } from '../types/Department'

// 获取常用联系人（雇员）列表
export const getEmployeeList = () => {
  return request<Employee[]>({
    url: 'employee/list'
  })
}

// 获取组织结构（部门）列表
export const getDepartmentList = () => {
  return request<Department[]>({
    url: 'employee/department/list'
  })
}