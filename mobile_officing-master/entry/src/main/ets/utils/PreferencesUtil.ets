import dataPreferences from '@ohos.data.preferences'

const PREFERENCES_NAME = 'myPreferences' // 首选项名字
const TOKEN_KEY = 'TOKEN_KEY' // 首选项Key字段

export default class PreferencesUtil{
  static preference = null

  // 创建Preferences
  static async createPreferences(context) {
    this.preference = await dataPreferences.getPreferences(context,PREFERENCES_NAME)
  }

  // 保存token
  static saveToken(token: string){
    this.preference.put(TOKEN_KEY,token)
    // 只有调用该方法，才能持久化存储
    this.preference.flush()
  }

  // 获取token
  static async getToken() {
    return this.preference.get(TOKEN_KEY,"")
  }
}