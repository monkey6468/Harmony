import picker from '@ohos.file.picker'
import fs from '@ohos.file.fs'
import common from '@ohos.app.ability.common'
import request from '@ohos.request'

export const uploadFile = (mimeType = picker.PhotoViewMIMETypes.IMAGE_TYPE, maxSelectNumber = 1): Promise<string> => {
  return new Promise((resolve, reject) => {

    try { // 先做文件选择
      let PhotoSelectOptions = new picker.PhotoSelectOptions()
      PhotoSelectOptions.MIMEType = mimeType
      PhotoSelectOptions.maxSelectNumber = maxSelectNumber
      let photoPicker = new picker.PhotoViewPicker()

      photoPicker.select(PhotoSelectOptions).then((photoSelectResult) => {
        // 获取选中图片地址（选中一个）
        const url = photoSelectResult.photoUris[0]

        const file = fs.openSync(url, fs.OpenMode.READ_ONLY)

        // 把选中的地址转换成缓存目录下的地址
        const dateStr = new Date().getTime().toString()
        const context = getContext(this) as common.Context
        let newPath = context.cacheDir + `/${dateStr}.png`
        fs.copyFile(file.fd, newPath).then(() => {
          let uploadFileUri = 'internal://cache/' + newPath.split('cache/')[1]

          // 上传操作开始
          // 上传任务配置项
          let uploadConfig = {
            url: 'https://huangjiangjun.top:3002/admin/file/chats/upload',
            header: { key1: 'value1', key2: 'value2' },
            method: 'POST',
            files: [{ filename: `/${dateStr}.png`, name: 'file', uri: uploadFileUri, type: 'png' }],
            data: [{ name: 'name', value: 'value' }]
          }

          // 将本地应用文件上传至网络服务器
          try {
            request.uploadFile(context, uploadConfig).then(uploadTask => {
              uploadTask.on('complete', taskStates => {
                for (let i = 0; i < taskStates.length; i++) {
                  console.info(`---upload complete taskState: ${JSON.stringify(taskStates[i])}`)
                }

                // 返回图片地址
                resolve(url)
              })
            }).catch(err => {
              console.error(`---555 err:, code is ${err.code}, message is ${err.message}`)
            })
          } catch (err) {
            console.error(`---444 err:, code is ${err.code}, message is ${err.message}`)
          }
        })
      }).catch((err) => {
        console.error('PhotoViewPicker.select failed with err: ' + err);
      });

    } catch (err) {

    }


  })
}