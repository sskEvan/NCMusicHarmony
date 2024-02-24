import { ApiConstant, EventIds, SongBean, SongUrlResultBean } from '../..'
import media from '@ohos.multimedia.media'
import { LogUtil, ApiRequest, RequestOptions } from 'lib_common'
import promptAction from '@ohos.promptAction'
import emitter from '@ohos.events.emitter'

/**
 * 音乐播放器，通过AVPlayer实现音乐播放功能
 */
export class NCPlayer  {
  static player: media.AVPlayer | null = null
  private static lastStatus: PlayerStatus | null = null
  private static isSeeking = false

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
        // LogUtil.debug("--NCPlayer--timeUpdate: isSeeking=" + this.isSeeking + ",lastStatus=" + this.lastStatus)
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

  /**
   * 设置播放资源
   * @param songBean
   */
  static async setDataSource(songBean: SongBean) {
    await this.player.reset()
    this.isSeeking = false
    LogUtil.debug("--NCPlayer--setDataSource:" + songBean.name)
    // 获取歌曲URL
    const songUrlResult = await ApiRequest.get<SongUrlResultBean>(
      new RequestOptions({
        url: ApiConstant.URL_SONG_URL,
        data: { "id": songBean.id, "br": 128000 },
      }))
    if (songUrlResult && songUrlResult.data && songUrlResult.data.length > 0) {
      if (this.lastStatus != PlayerStatus.IDLE) {
        await this.player.reset()
      }
      this.player.url = songUrlResult.data[0].url
      LogUtil.debug("--NCPlayer--setDataSource url:" + this.player.url)
    } else {
      promptAction.showToast({ message: "无法播放该歌曲" })
    }
  }

  /**
   * 播放
   */
  static async start() {
    if (this.lastStatus == PlayerStatus.PREPARED
    || this.lastStatus == PlayerStatus.PAUSED
    || this.lastStatus == PlayerStatus.COMPLETED
    ) {
      LogUtil.debug("--NCPlayer--play")
      await this.player.play()
    }
  }

  /**
   * 暂停
   */
  static async pause() {
    if (this.lastStatus == PlayerStatus.STARTED) {
      LogUtil.debug("--NCPlayer--pause")
      this.player.pause()
    }
  }

  /**
   * 停止
   */
  static async stop() {
    LogUtil.debug("--NCPlayer--stop")
    this.player.stop()
  }

  /**
   * 拖动进度
   */
  static seekTo(ms: number) {
    LogUtil.debug("--NCPlayer--seekTo")
    this.isSeeking = true
    this.player.seek(ms)
  }

  /**
   * 通知播放状态
   * @param status
   */
  private static notifyPlayerStatus(status: PlayerStatus) {
    if (this.lastStatus != status) {
      this.lastStatus = status
      emitter.emit({ eventId: EventIds.PLAYER_STATUS}, { data: { status } })
    }
  }

  /**
   * 通知播放总时长
   */
  private static notifyDuring(during) {
    emitter.emit({ eventId: EventIds.PLAYER_DURING }, { data: { during } })
  }

  /**
   * 通知当前播放时间
   */
  private static notifyTimeUpdate(timeUpdate) {
    emitter.emit({ eventId: EventIds.PLAYER_TIME_UPDATE }, { data: { timeUpdate } })
  }
}

/**
 * 播放状态
 */
export enum PlayerStatus {
  // 无
  NONE,
  // 空闲
  IDLE,
  // 准备完成
  PREPARED,
  // 播放中
  STARTED,
  // 暂停
  PAUSED,
  // 停止
  STOPPED,
  // 完成
  COMPLETED,
  // 播放出错
  ERROR
}

/**
 * 播放模式
 */
export enum PlayerMode {
  // 循环播放
  LOOP = 0,
  // 单曲循环
  SINGLE = 1,
  // 随机播放
  RANDOM = 2
}

