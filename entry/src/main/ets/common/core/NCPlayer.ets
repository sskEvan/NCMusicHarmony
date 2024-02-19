import { SongBean, STORAGE_PLAY_STORE } from '../..'


export class NCPlayer {
  static initPlayer() {

  }

  // static play(index: number) {
  //   const playerStore = this.getPlayerStore()
  //   playerStore.index = index
  //   this.updatePlayerStore(playerStore)
  // }

  static setDataSource(songBean: SongBean) {

  }



}

export enum PlayerStatus {
  IDLE,
  PREPARED,
  STARTED,
  PAUSED,
  STOPPED,
  COMPLETED,
  ERROR
}

