import { media } from '@kit.MediaKit'
import { SongType } from '../model/music'
import { emitter } from '@kit.BasicServicesKit'

export default class AVPlayerClass {
  static player: media.AVPlayer = {} as media.AVPlayer
  static duration: number = 0
  static time: number = 0
  static isPlay: boolean = false
  static isPaused: boolean = false
  static playMode: "auto" | "loop" | "random" = "auto"
  static playList: SongType[] = []
  static playIndex: number = 0

  static async init() {

    AVPlayerClass.player = await media.createAVPlayer()

    AVPlayerClass.player.on("stateChange", (State) => {
      switch (State) {
        case "initialized":
          AVPlayerClass.player.prepare()
          break
        case "prepared":
          AVPlayerClass.player.play()
          break
      }
    })

    AVPlayerClass.player.on("durationUpdate", (duration) => {
      AVPlayerClass.duration = duration
    })

    AVPlayerClass.player.on("timeUpdate", (time) => {
      AVPlayerClass.updateStatus()
      AVPlayerClass.time = time
    })
  }

  static async singlePlay(song: SongType) {
    console.log("xwh singlePlay", JSON.stringify(song))
    const index = AVPlayerClass.playList.findIndex(item => item.id === song.id)
    if (index > -1) {
      // 正在播放
      if (AVPlayerClass.player.url === song.url) {
        // 继续播放
        console.log("xwh 继续播放")
      } else {
        // 切换
        // 重置
        AVPlayerClass.player.reset()
        AVPlayerClass.player.url = song.url
        console.log("xwh 切换歌曲")
      }
    } else {
      // 播放列表中不存在该歌曲，添加到列表中
      AVPlayerClass.playList.unshift(song)
      AVPlayerClass.playIndex = 0

      // 重置
      await AVPlayerClass.player.reset()
      AVPlayerClass.player.url = song.url
      console.log("xwh 添加到列表中")
    }
  }

  static updateStatus() {
    emitter.emit({
      eventId: 0
    }, {
      data: {
        duration: AVPlayerClass.duration,
        time: AVPlayerClass.time,
        isPlay: AVPlayerClass.isPlay,
        playMode: AVPlayerClass.playMode,
        playList: AVPlayerClass.playList,
        playIndex: AVPlayerClass.playIndex,
        img: AVPlayerClass.playList[AVPlayerClass.playIndex].img,
        name: AVPlayerClass.playList[AVPlayerClass.playIndex].name,
        author: AVPlayerClass.playList[AVPlayerClass.playIndex].author,
      }
    })
  }
}