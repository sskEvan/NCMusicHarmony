import { EventIds, NCPlayer, PlayerStatus, SongBean, STORAGE_PLAY_STORE } from '../..'
import { LogUtil } from 'lib_common'
import emitter from '@ohos.events.emitter'

export class MusicPlayController {
  static originPlayList?: SongBean[]
  static playList?: SongBean[]
  static playListId: number = 0

  static async init() {
    await NCPlayer.initPlayer()
    // 监听播放状态
    emitter.on({ eventId: EventIds.PLAYER_STATUS }, (data) => {
      LogUtil.debug("--MusicPlayController--监听播放器状态:" + data.data.status)
      const playerStore = this.getPlayStore()
      playerStore.playerStats = data.data.status as PlayerStatus
      this.updatePlayStore(playerStore)
    })
    // 监听播放总长度
    emitter.on({ eventId: EventIds.PLAYER_DURING }, (data) => {
      const playerStore = this.getPlayStore()
      playerStore.totalDuring = data.data.during
      this.updatePlayStore(playerStore)
    })
    // 监听当前播放长度
    emitter.on({ eventId: EventIds.PLAYER_TIME_UPDATE }, (data) => {
      LogUtil.debug("--MusicPlayController--监听当前播放长度:" + data.data.timeUpdate)
      const playerStore = this.getPlayStore()
      playerStore.currentDuring = data.data.timeUpdate
      this.updatePlayStore(playerStore)
    })
  }

  static setDataSource(playListId: number, playList: SongBean[]) {
    if (playListId != MusicPlayController.playListId) {
      MusicPlayController.originPlayList = playList
      MusicPlayController.playList = playList
      MusicPlayController.playListId = playListId
    }
  }

  static play(index: number) {
    NCPlayer.stop()
    const playerStore = this.getPlayStore()
    playerStore.index = index
    playerStore.currentDuring = 0
    playerStore.totalDuring = 0
    this.updatePlayStore(playerStore)
    NCPlayer.setDataSource(this.playList[index])
  }

  static start() {
    NCPlayer.start()
  }

  static pause() {
    NCPlayer.pause()
  }

  static seekTo(progress: number) {
    const playerStore = this.getPlayStore()
    playerStore.currentDuring = playerStore.totalDuring * progress / 100
    this.updatePlayStore(playerStore)
    LogUtil.debug("------------------MusicPlayController--------------seekTo:" + playerStore.currentDuring)
    if (playerStore.currentDuring != 0 && playerStore.totalDuring != 0) {
      NCPlayer.seekTo(playerStore.totalDuring * progress / 100)
    }
  }

  static stop() {
    NCPlayer.stop()
  }

  static setPlayMode(playMode: PlayModeType) {
    const playerStore = this.getPlayStore()
    if (playMode == PlayModeType.RANDOM) {
      const shuffledIndices = Array.from({ length: MusicPlayController.playList.length }, (_, i) => i)
        .sort(() => Math.random() - 0.5);
      const shuffledArr = shuffledIndices.map(i => MusicPlayController.playList[i])
      MusicPlayController.playList = shuffledArr
      const currentPlayIndex = MusicPlayController.playList.findIndex((item: SongBean) => {
        return item.id == MusicPlayController.originPlayList[playerStore.index].id
      })
      if (currentPlayIndex != playerStore.index && currentPlayIndex != -1) {
        const temp = MusicPlayController.playList[playerStore.index]
        MusicPlayController.playList[playerStore.index] = MusicPlayController.originPlayList[playerStore.index]
        MusicPlayController.playList[currentPlayIndex] = temp
        LogUtil.debug("替换歌曲," + currentPlayIndex + "=>" + playerStore.index)
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
        return item.id == MusicPlayController.playList[playerStore.index].id
      })
      if (currentPlayIndex != playerStore.index && currentPlayIndex != -1) {
        LogUtil.debug("替换歌曲索引," + playerStore.index + "=>" + +currentPlayIndex)
        playerStore.index = currentPlayIndex
      }
      MusicPlayController.playList = MusicPlayController.originPlayList
      for (let index = 0; index < MusicPlayController.playList.length; index++) {
        const element = MusicPlayController.playList[index];
        LogUtil.debug(element.name)
      }
    }
    playerStore.playMode = playMode
    this.updatePlayStore(playerStore)
  }

  static playNext() {
    const playerStore = this.getPlayStore()
    let targetIndex = 0
    if (playerStore.index == this.playList.length - 1) {
      targetIndex = 0
    } else {
      targetIndex = playerStore.index + 1
    }
    this.play(targetIndex)
  }

  static playPre() {
    const playerStore = this.getPlayStore()
    let targetIndex = 0
    if (playerStore.index == 0) {
      targetIndex = this.playList.length - 1
    } else {
      targetIndex = playerStore.index - 1
    }
    this.play(targetIndex)
  }

  private  static getPlayStore(): PlayStore {
    return AppStorage.Get<PlayStore>(STORAGE_PLAY_STORE)
  }

  private static updatePlayStore(playerStore: PlayStore) {
    AppStorage.Set(STORAGE_PLAY_STORE, new PlayStore(playerStore))
  }
}

export enum PlayModeType {
  LOOP = 0,
  SINGLE = 1,
  RANDOM = 2
}

export interface IPlayStore {
  index?: number
  totalDuring?: number
  currentDuring?: number
  playMode?: PlayModeType
  playerStats?: PlayerStatus
}

export class PlayStore implements IPlayStore {
  index: number = 0
  totalDuring: number = 0
  currentDuring: number = 0
  playMode: PlayModeType = PlayModeType.LOOP
  playerStats: PlayerStatus = PlayerStatus.IDLE

  constructor(model: IPlayStore) {
    if (model.index) {
      this.index = model.index
    }
    if (model.totalDuring) {
      this.totalDuring = model.totalDuring
    }
    if (model.currentDuring) {
      this.currentDuring = model.currentDuring
    }
    if (model.playMode) {
      this.playMode = model.playMode
    }

    if (model.playerStats) {
      this.playerStats = model.playerStats
    }
  }
}
