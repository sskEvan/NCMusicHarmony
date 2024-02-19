import { PlayerStatus, SongBean, STORAGE_PLAY_STORE } from '../..'
import { LogUtil } from 'lib_common'

export class MusicPlayController {
  static originPlayList?: SongBean[]
  static playList?: SongBean[]
  static playListId: number = 0

  static setDataSource(playListId: number, playList: SongBean[]) {
    if (playListId != MusicPlayController.playListId) {
      MusicPlayController.originPlayList = playList
      MusicPlayController.playList = playList
      MusicPlayController.playListId = playListId
    }
  }

  static play(index: number) {
    const playerStore = this.getPlayStore()
    playerStore.index = index
    playerStore.playerStats = PlayerStatus.STARTED
    this.updatePlayStore(playerStore)
    LogUtil.debug("-------------play-----------index=" + index + "," + MusicPlayController.playList[playerStore.index].name)
  }

  static start() {
    const playerStore = this.getPlayStore()
    playerStore.playerStats = PlayerStatus.STARTED
    this.updatePlayStore(playerStore)
  }

  static pause() {
    const playerStore = this.getPlayStore()
    playerStore.playerStats = PlayerStatus.PAUSED
    this.updatePlayStore(playerStore)
  }

  static stop() {
    const playerStore = this.getPlayStore()
    playerStore.playerStats = PlayerStatus.STOPPED
    this.updatePlayStore(playerStore)
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
      LogUtil.debug("-------------RANDOM-----------currentPlayIndex=" + currentPlayIndex + ",playerStore.index" + playerStore.index + "," + MusicPlayController.originPlayList[playerStore.index].name)
      if (currentPlayIndex != playerStore.index && currentPlayIndex != -1) {
        const temp = MusicPlayController.playList[playerStore.index]
        MusicPlayController.playList[playerStore.index] = MusicPlayController.originPlayList[playerStore.index]
        MusicPlayController.playList[currentPlayIndex] = temp
        LogUtil.debug("替换歌曲," + currentPlayIndex + "=>" + playerStore.index)
      }
      LogUtil.debug("-------------before random-----------")
      for (let index = 0; index < MusicPlayController.originPlayList.length; index++) {
        const element = MusicPlayController.originPlayList[index];
        LogUtil.debug(element.name)
      }
      LogUtil.debug("-------------after random-----------")
      for (let index = 0; index < MusicPlayController.playList.length; index++) {
        const element = MusicPlayController.playList[index];
        LogUtil.debug(element.name)
      }
    } else {
      const currentPlayIndex = MusicPlayController.originPlayList.findIndex((item: SongBean) => {
        return item.id == MusicPlayController.playList[playerStore.index].id
      })
      LogUtil.debug("-------------LOOP-----------currentPlayIndex=" + currentPlayIndex + ",playerStore.index" + playerStore.index)
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
    if (playerStore.index == this.playList.length - 1) {
      playerStore.index = 0
    } else {
      playerStore.index += 1
    }
    LogUtil.debug("-------------play-----------index=" + playerStore.index + "," + MusicPlayController.playList[playerStore.index].name)
    playerStore.playerStats = PlayerStatus.STARTED
    this.updatePlayStore(playerStore)
  }

  static playPre() {
    const playerStore = this.getPlayStore()
    if (playerStore.index == 0) {
      playerStore.index = this.playList.length - 1
    } else {
      playerStore.index -= 1
    }
    LogUtil.debug("-------------play-----------index=" + playerStore.index + "," + MusicPlayController.playList[playerStore.index].name)
    playerStore.playerStats = PlayerStatus.STARTED
    this.updatePlayStore(playerStore)
  }

  private  static getPlayStore(): PlayStore {
    return AppStorage.Get<PlayStore>(STORAGE_PLAY_STORE)
  }

  private  static async updatePlayStore(playerStore: PlayStore) {
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
