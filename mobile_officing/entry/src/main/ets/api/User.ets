import http from '@ohos.net.http'
import { User } from '../types/User'
import { request } from '../utils/Request'

// 登录
export const login = (extraData: {
  loginname: string;
  password: string
}) => {
  return request<{ token: string }>({
    url: 'user/login',
    method: http.RequestMethod.POST,
    extraData
  })
}

// 获取用户信息
export const getUserInfo = () => {
  return request<User>({
    url: "user/info"
  })
}

// 获取验证码
export const getSmsCode = (extraData: { phone: string }) => {
  return request<{ code: string }>({
    url: 'user/smscode',
    method: http.RequestMethod.GET,
    extraData
  })
}

// 更改手机号
export const changePhone = (extraData: {
  phone: string;
  code: string
}) => {
  return request({
    url: 'user/changePhone',
    method: http.RequestMethod.POST,
    extraData
  })
}

// 更改密码
export const changePassword = (extraData: {
  oldPassword: string
  newPassword: string
}) => {
  return request({
    url: 'user/changePassword',
    method: http.RequestMethod.POST,
    extraData
  })
}