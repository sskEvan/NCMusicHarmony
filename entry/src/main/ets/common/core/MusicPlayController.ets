import { EventIds, NCPlayer, SongBean, PlayerStatus, PlayerMode } from '../..'
import { LogUtil } from 'lib_common'
import emitter from '@ohos.events.emitter'

/**
 * 音乐播放控制器，给UI层调用
 */
export class MusicPlayController {
  // 原始歌曲列表（随机播放模式恢复到原始顺序时用到）
  static originPlayList?: SongBean[]
  // 歌曲列表
  static playList?: SongBean[]
  // 歌曲列表id
  static playListId: number = 0
  // 当前播放索引
  static playerIndex: number = -1
  // 总时长
  static totalDuring: number = 0
  // 当前播放时长
  static currentDuring: number = 0
  // 播放模式
  static playerMode: PlayerMode | undefined = undefined
  // 播放状态
  static playerStatus: PlayerStatus | undefined = undefined

  static async init() {
    await NCPlayer.initPlayer()
    this.playerMode = PlayerMode.LOOP
    this.playerStatus = PlayerStatus.NONE
    // 订阅播放状态
    emitter.on({ eventId: EventIds.PLAYER_STATUS }, (data) => {
      LogUtil.debug("--MusicPlayController--监听播放器状态:" + data.data.status)
      this.playerStatus = data.data.status
      if (data.data.status == PlayerStatus.COMPLETED) {
        if (this.playerMode == PlayerMode.SINGLE) {
          this.play(this.playerIndex, true)
        } else {
          this.playNext()
        }
      }
    })

    // 订阅当前播放时长
    emitter.on({ eventId: EventIds.PLAYER_TIME_UPDATE }, (data) => {
      this.currentDuring = data.data.timeUpdate
    })

    // 订阅播放总时长
    emitter.on({ eventId: EventIds.PLAYER_DURING }, (data) => {
      this.totalDuring = data.data.during
    })

    // 订阅播放模式
    emitter.on({ eventId: EventIds.PLAYER_MODE }, (data) => {
      this.playerMode = data.data.playerMode
    })
  }

  /**
   * 设置歌曲列表资源
   */
  static setDataSource(playListId: number, playList: SongBean[]) {
    if (playListId != MusicPlayController.playListId) {
      MusicPlayController.originPlayList = playList
      MusicPlayController.playList = playList
      MusicPlayController.playListId = playListId
    }
  }

  /**
   * 根据索引播放歌曲
   */
  static async play(index: number, forceReset: boolean = false) {
    LogUtil.debug("--MusicPlayController--play,index:" + index + ",this.playerIndex=" + this.playerIndex + ",forceReset=" + forceReset)
    if (this.playerIndex != index || forceReset) {
      this.playerIndex = index
      // 重置播放时长
      const timeUpdate = 0
      const during = 0
      this.playerStatus == PlayerStatus.IDLE
      emitter.emit({ eventId: EventIds.PLAYER_TIME_UPDATE }, { data: { timeUpdate } })
      emitter.emit({ eventId: EventIds.PLAYER_DURING }, { data: { during } })
      emitter.emit({ eventId: EventIds.PLAYER_INDEX }, { data: { index } })
      await NCPlayer.setDataSource(this.playList[index])
    } else {
      await NCPlayer.start()
    }
  }

  /**
   * 播放
   */
  static start() {
    LogUtil.debug("--MusicPlayController--start")
    NCPlayer.start()
  }

  /**
   * 暂停播放
   */
  static pause() {
    LogUtil.debug("--MusicPlayController--pause")
    NCPlayer.pause()
  }

  /**
   * 拖动进度
   */
  static seekTo(ms: number) {
    LogUtil.debug("--MusicPlayController--seekTo:" + ms)
    NCPlayer.seekTo(ms)
  }

  /**
   * 停止播放
   */
  static stop() {
    LogUtil.debug("--MusicPlayController--stop")
    NCPlayer.stop()
  }

  /**
   * 切换播放模式
   */
  static setPlayMode(playerMode: PlayerMode) {
    this.playerMode = playerMode
    if (playerMode == PlayerMode.RANDOM) {
      const shuffledIndices = Array.from({ length: MusicPlayController.playList.length }, (_, i) => i)
        .sort(() => Math.random() - 0.5);
      const shuffledArr = shuffledIndices.map(i => MusicPlayController.playList[i])
      MusicPlayController.playList = shuffledArr
      const currentPlayIndex = MusicPlayController.playList.findIndex((item: SongBean) => {
        return item.id == MusicPlayController.originPlayList[this.playerIndex].id
      })
      if (currentPlayIndex != this.playerIndex && currentPlayIndex != -1) {
        const temp = MusicPlayController.playList[this.playerIndex]
        MusicPlayController.playList[this.playerIndex] = MusicPlayController.originPlayList[this.playerIndex]
        MusicPlayController.playList[currentPlayIndex] = temp
        LogUtil.debug("替换歌曲," + currentPlayIndex + "=>" + this.playerIndex)
      }
      for (let index = 0; index < MusicPlayController.originPlayList.length; index++) {
        const element = MusicPlayController.originPlayList[index];
        LogUtil.debug(element.name)
      }
      for (let index = 0; index < MusicPlayController.playList.length; index++) {
        const element = MusicPlayController.playList[index];
        LogUtil.debug(element.name)
      }
    } else {
      const currentPlayIndex = MusicPlayController.originPlayList.findIndex((item: SongBean) => {
        return item.id == MusicPlayController.playList[this.playerIndex].id
      })
      if (currentPlayIndex != this.playerIndex && currentPlayIndex != -1) {
        LogUtil.debug("替换歌曲索引," + this.playerIndex + "=>" + +currentPlayIndex)
        this.playerIndex = currentPlayIndex
      }
      MusicPlayController.playList = MusicPlayController.originPlayList
      for (let index = 0; index < MusicPlayController.playList.length; index++) {
        const element = MusicPlayController.playList[index];
        LogUtil.debug(element.name)
      }
    }
    emitter.emit({ eventId: EventIds.PLAYER_MODE }, { data: { playerMode } })
  }

  /**
   * 播放下一首
   */
  static playNext() {
    let targetIndex = 0
    if (this.playerIndex == this.playList.length - 1) {
      targetIndex = 0
    } else {
      targetIndex = this.playerIndex + 1
    }
    LogUtil.debug("--MusicPlayController--playNext, curIndex:" + this.playerIndex + ",targetIndex=" + targetIndex)
    this.play(targetIndex)
  }

  /**
   * 播放上一首
   */
  static playPre() {
    let targetIndex = 0
    if (this.playerIndex == 0) {
      targetIndex = this.playList.length - 1
    } else {
      targetIndex = this.playerIndex - 1
    }
    LogUtil.debug("--MusicPlayController--playPre, curIndex:" + this.playerIndex + ",targetIndex=" + targetIndex)
    this.play(targetIndex)
  }
}


/**
 * 存储播放器中的一些关键信息，原本设计时把这些关键信息存进AppStorage中，从而驱动不同页面相关组件的UI渲染
 * 后面当界面中有一些循环动画的时候，例如音乐播放界面中的唱片旋转动画，频繁更新PlayStore会造成卡顿
 * 最后决定使用emitter通信，来通知、订阅播放过程中的一些关键信息。
 */
// export class PlayStore implements IPlayStore {
//   index: number = 0
//   totalDuring: number = 0
//   // currentDuring: number = 0
//   playMode: PlayModeType = PlayModeType.LOOP
//   playerStatus: PlayerStatus = PlayerStatus.IDLE
//
//   constructor(model: IPlayStore) {
//     if (model.index) {
//       this.index = model.index
//     }
//     if (model.totalDuring) {
//       this.totalDuring = model.totalDuring
//     }
//     // if (model.currentDuring) {
//     //   this.currentDuring = model.currentDuring
//     // }
//     if (model.playMode) {
//       this.playMode = model.playMode
//     }
//
//     if (model.playerStatus) {
//       this.playerStatus = model.playerStatus
//     }
//   }
// }

// export interface IPlayStore {
//   index?: number
//   totalDuring?: number
//   currentDuring?: number
//   playMode?: PlayModeType
//   playerStatus?: PlayerStatus
// }