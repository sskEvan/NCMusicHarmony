import { ApiConstant, EventIds, SongBean, SongUrlResultBean } from '../..'
import media from '@ohos.multimedia.media'
import { BaseViewModel, LogUtil, Request, RequestBean } from 'lib_common'
import promptAction from '@ohos.promptAction'
import emitter from '@ohos.events.emitter'


export class NCPlayer extends BaseViewModel {
  static player: media.AVPlayer | null = null
  private static lastStatus: PlayerStatus | null = null
  private static isSeeking = false
  private static lastTimeUpdate = 0

  static async initPlayer() {
    if (this.player === null) {
      this.player = await media.createAVPlayer()
      // 监听状态
      this.player.on('stateChange', (state) => {
        LogUtil.debug("--NCPlayer--stateChange:" + state)

        switch (state) {
          case 'idle': // 调用reset接口后触发
            this.notifyPlayerStatus(PlayerStatus.IDLE)
            break;
          case 'initialized': // 设置播放源后触发
            this.player.prepare()
            break;
          case 'prepared': // 调用prepare接口后触发
            this.notifyPlayerStatus(PlayerStatus.PREPARED)
            this.player.play()
            break;
          case 'playing': // 调用play接口后触发
            this.notifyPlayerStatus(PlayerStatus.STARTED)
            break;
          case 'paused': // 调用pause接口后触发
            this.notifyPlayerStatus(PlayerStatus.PAUSED)
            break;
          case 'completed': // 播放结束后触发
            this.notifyPlayerStatus(PlayerStatus.COMPLETED)
            break;
          case 'stopped': // 调用stop接口后触发
            this.notifyPlayerStatus(PlayerStatus.STOPPED)
            this.player.reset();
            break;
        }
      })
      // 监听seek操作结果
      this.player.on('seekDone', (seekDoneTime) => {
        LogUtil.debug("--NCPlayer--seekDone:" + seekDoneTime)
        this.player.play()
        this.isSeeking = false
      })
      // 监听播放进度
      this.player.on('timeUpdate', (time) => {
        LogUtil.debug("--NCPlayer--timeUpdate: isSeeking=" + this.isSeeking + ",lastStatus=" + this.lastStatus)
        if (!this.isSeeking) {
          this.notifyTimeUpdate(time)
        }
      })
      // 监听歌曲时长
      this.player.on('durationUpdate', (duration) => {
        this.notifyDuring(duration)
      })

      // 监听播放错误
      this.player.on('error', (err) => {
        LogUtil.debug("--NCPlayer--error:" + err)
        this.notifyPlayerStatus(PlayerStatus.ERROR)
      })
    }
  }

  static async setDataSource(songBean: SongBean) {
    await this.player.reset()
    this.isSeeking = false
    LogUtil.debug("--NCPlayer--setDataSource:" + songBean.name)
    const songUrlResult = await Request.get<SongUrlResultBean>(
      new RequestBean({
        url: ApiConstant.URL_SONG_URL,
        data: { "id": songBean.id, "br": 128000 },
      }))
    if (songUrlResult && songUrlResult.data && songUrlResult.data.length > 0) {
      this.player.url = songUrlResult.data[0].url
      LogUtil.debug("--NCPlayer--setDataSource url:" + this.player.url)
    } else {
      promptAction.showToast({ message: "无法播放该歌曲" })
    }
  }


  static start() {
    if (this.lastStatus == PlayerStatus.STARTED
    || this.lastStatus == PlayerStatus.PREPARED
    || this.lastStatus == PlayerStatus.PAUSED
    || this.lastStatus == PlayerStatus.COMPLETED
    ) {
      LogUtil.debug("--NCPlayer--play")
      this.player.play()
    }
  }

  static pause() {
    if (this.lastStatus == PlayerStatus.STARTED) {
      LogUtil.debug("--NCPlayer--pause")
      this.player.pause()
    }
  }

  static stop() {
    LogUtil.debug("--NCPlayer--stop")
    this.player.stop()
  }

  static seekTo(ms: number) {
    LogUtil.debug("--NCPlayer--seekTo")
    this.isSeeking = true
    this.player.seek(ms)
  }

  private static notifyPlayerStatus(status: PlayerStatus) {
    if (this.lastStatus != status) {
      this.lastStatus = status
      emitter.emit({ eventId: EventIds.PLAYER_STATUS }, { data: { status } })
    }
  }

  private static notifyDuring(during) {
    emitter.emit({ eventId: EventIds.PLAYER_DURING }, { data: { during } })
  }

  private static notifyTimeUpdate(timeUpdate) {
    if (Math.abs(this.lastTimeUpdate - timeUpdate) >= 800) {
      emitter.emit({ eventId: EventIds.PLAYER_TIME_UPDATE }, { data: { timeUpdate } })
      this.lastTimeUpdate = timeUpdate
    }
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

