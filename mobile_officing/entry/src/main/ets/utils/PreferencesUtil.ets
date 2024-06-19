import dataPreferences from '@ohos.data.preferences'

const PREFERENCES_NAME = "myPreferences"
const TOKEN_KEY = "myToken"

export default class PreferencesUtil {
  static preference = null

  static async createPreferences(context) {
    this.preference = await dataPreferences.getPreferences(context, PREFERENCES_NAME)
  }

  static saveToken(token: string) {
    this.preference.put(TOKEN_KEY, token)
    this.preference.flush()
  }

  static async getToken() {
    return this.preference.get(TOKEN_KEY, "")
  }
}