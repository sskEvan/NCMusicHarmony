import {
  ClickEffectLayout,
  CommonAppBar,
  CpnProgressBar,
  LogUtil,
  SizeConstant,
  TimeUtil,
  TabLayoutPagerMediator,
  TabPager
} from 'lib_common'
import {
  MusicPlayListDialog,
  CpnLyric,
  PlayerMode,
  MusicPlayController,
  PlayerStatus,
  SongBean,
  EventIds
} from '../../..'
import animator, { AnimatorOptions, AnimatorResult } from '@ohos.animator'
import emitter from '@ohos.events.emitter'

/**
 * 音乐播放页面
 */
@Entry
@Component
export struct MusicPlayPage {
  // 当前播放进度
  @State progress: number = 0
  @State @Watch("tabMediatorChange") tabMediator: TabLayoutPagerMediator = new TabLayoutPagerMediator({})
  // 磁针角度
  @State neededAngle: number = 0
  // 是否显示歌词组件
  @State showCpnLyric: boolean = false
  // 歌曲列表弹框
  customDialogController: CustomDialogController = new CustomDialogController({
    builder: MusicPlayListDialog(),
    customStyle: true,
    alignment: DialogAlignment.Bottom,
    autoCancel: true
  })
  // 标记当前进度条是否处于拖拽状态
  isProgressBarDragging: boolean = false
  // 唱片旋转动画相关
  diskRotateAnimatorOptions: AnimatorOptions = {
    duration: 8000,
    easing: "linear",
    delay: 0,
    fill: "none",
    direction: "normal",
    iterations: -1,
    begin: 0,
    end: 360
  }
  diskRotateAnimator: AnimatorResult = animator.create(this.diskRotateAnimatorOptions)
  @State diskRotateAngle: number = 0
  // 播放状态
  @State playerStatus: PlayerStatus | undefined = undefined
  // 当前播放时长
  @State currentDuring: number = 0
  // 播放模式
  @State playerMode: PlayerMode | undefined = undefined
  // 当前播放索引
  @State index: number = 0
  // 总时长
  @State totalDuring: number = 0
  timerId: number = -1

  aboutToAppear() {
    this.playerStatus = MusicPlayController.playerStatus
    this.playerMode = MusicPlayController.playerMode
    this.index = MusicPlayController.playerIndex
    this.totalDuring = MusicPlayController.totalDuring
    this.currentDuring = MusicPlayController.currentDuring
    if (this.totalDuring != 0) {
      this.progress = this.currentDuring * 100 / this.totalDuring
    }
    this.diskRotateAnimator.onframe = (progress) => {
      this.diskRotateAngle = progress
    }
    this.tabMediator = new TabLayoutPagerMediator({
      tabItems: MusicPlayController.playList,
      cacheCount: 1,
      currentIndex: this.index
    })

    // 订阅当前播放时长
    emitter.on({ eventId: EventIds.PLAYER_TIME_UPDATE }, (data) => {
      this.currentDuring = data.data.timeUpdate
      if (this.currentDuring != 0 && this.totalDuring != 0) {
        if (!this.isProgressBarDragging) {
          this.progress = this.currentDuring * 100 / this.totalDuring
        }
      } else {
        this.progress = 0
      }
    })
    // 监听播放状态
    emitter.on({ eventId: EventIds.PLAYER_STATUS }, (data) => {
      // 播放状态改变时，暂停/开始暂停唱片旋转动画
      const newPlayerStatus = data.data.status
      if (newPlayerStatus == PlayerStatus.STARTED) {
        if (this.playerStatus != PlayerStatus.STARTED) {
          this.diskRotateAnimator.play()
        }
      } else {
        this.diskRotateAnimator.pause()
      }
      this.playerStatus = newPlayerStatus
      animateTo({
        duration: 300
      }, () => {
        // 磁针角度，this.tabMediator.currentIndex为整数，表示完成了一次左右切换，并且播放器已经处于播放状态，则磁针角度为0，否则磁针角度为25
        this.neededAngle = Number.isInteger(this.tabMediator.currentIndex) && this.playerStatus == PlayerStatus.STARTED ? 0 : -25
      })
      LogUtil.debug("--PLAYER_STATUS neededAngle" + (Number.isInteger(this.tabMediator.currentIndex) && this.playerStatus == PlayerStatus.STARTED ? 0 : -25).toString())
    })
    // 监听播放总时长
    emitter.on({ eventId: EventIds.PLAYER_DURING }, (data) => {
      this.totalDuring = data.data.during
    })
    // 监听播放模式
    emitter.on({ eventId: EventIds.PLAYER_MODE }, (data) => {
      const newPlayerMode = data.data.playerMode
      LogUtil.debug("--MusicPlayPage--监听播放模式：" + newPlayerMode)
      // 播放模式变化时，切换TabLayout数据源
      if ((newPlayerMode == PlayerMode.RANDOM && this.playerMode != PlayerMode.RANDOM)
      || (newPlayerMode != PlayerMode.RANDOM && this.playerMode == PlayerMode.RANDOM)) {
        this.tabMediator = new TabLayoutPagerMediator({
          tabItems: MusicPlayController.playList,
          cacheCount: 1,
          currentIndex: MusicPlayController.playerIndex
        })
        this.tabMediator.jumpToIndex(MusicPlayController.playerIndex)
        // LogUtil.debug("--MusicPlayPage--重置歌单列表,单曲播放：" + MusicPlayController.playList[MusicPlayController.playerIndex].name + ",index=" + MusicPlayController.playerIndex)
        // for (let i = 0; i < MusicPlayController.playList.length; i++) {
        //   LogUtil.debug("--" + MusicPlayController.playList[i].name)
        // }
      }
      this.playerMode = newPlayerMode
    })
    // 监听播放列表索引
    emitter.on({ eventId: EventIds.PLAYER_INDEX }, (data) => {
      this.index = data.data.index
      LogUtil.debug("--MusicPlayPage--监听播放列表索引：" + this.index + ",播放歌曲：" + MusicPlayController.playList[this.index].name)
      // 用户通过歌单列表、上一曲、下一曲按钮切换歌曲时，同步切换唱片TabLayout
      // if (Number.isInteger(this.tabMediator.currentIndex) && this.tabMediator.currentIndex !== this.index) {
      if (this.tabMediator.currentIndex !== this.index) {
        LogUtil.debug("--MusicPlayPage--tabMediator.currentIndex：" + this.tabMediator.currentIndex + ",index:：" + this.index)
        this.diskRotateAnimator.cancel()
        this.diskRotateAngle = 0
        this.tabMediator.jumpToIndex(this.index)
      }
    })
  }

  aboutToDisappear() {
    this.diskRotateAnimator.cancel()
    // emitter.off(EventIds.PLAYER_TIME_UPDATE)
    // emitter.off(EventIds.PLAYER_STATUS)
    // emitter.off(EventIds.PLAYER_DURING)
    // emitter.off(EventIds.PLAYER_INDEX)
    // emitter.off(EventIds.PLAYER_MODE)
  }

  // 切换用户左右滑动tabLayout
  tabMediatorChange() {
    if (Number.isInteger(this.tabMediator.currentIndex) && this.tabMediator.currentIndex !== MusicPlayController.playerIndex) {
      this.diskRotateAnimator.cancel()
      this.diskRotateAngle = 0
      this.index = this.tabMediator.currentIndex
      LogUtil.debug("--MusicPlayPage--tabMediatorChange, MusicPlayController.play, this.tabMediator.currentIndex" + this.tabMediator.currentIndex + ",MusicPlayController.playerIndex：" + MusicPlayController.playerIndex)
      MusicPlayController.play(this.tabMediator.currentIndex)
    }
    if (!Number.isInteger(this.tabMediator.currentIndex) || this.playerStatus != PlayerStatus.STARTED) {
      animateTo({
        duration: 300
      }, () => {
        // 磁针角度，this.tabMediator.currentIndex为整数，表示完成了一次左右切换，并且播放器已经处于播放状态，则磁针角度为0，否则磁针角度为25
        this.neededAngle = -25
      })
    } else {
      if (this.timerId != -1) {
        clearTimeout(this.timerId)
        this.timerId = -1
      }
      this.timerId = setTimeout(() => {
        if (Number.isInteger(this.tabMediator.currentIndex) && this.playerStatus == PlayerStatus.STARTED) {
          animateTo({
            duration: 300
          }, () => {
            // 磁针角度，this.tabMediator.currentIndex为整数，表示完成了一次左右切换，并且播放器已经处于播放状态，则磁针角度为0，否则磁针角度为25
            this.neededAngle = 0
          })
        }

      }, 100)
    }

    LogUtil.debug("--tabMediatorChange neededAngle" + (Number.isInteger(this.tabMediator.currentIndex) && this.playerStatus == PlayerStatus.STARTED ? 0 : -25).toString())
    // 处于播放状态时，用户左右滑动切歌过程中，暂停唱片旋转动画
    if (this.playerStatus == PlayerStatus.STARTED) {
      if (Number.isInteger(this.tabMediator.currentIndex)) {
        this.diskRotateAnimator.play()
      } else {
        this.diskRotateAnimator.pause()
      }
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      this.BlurBackgroundBuilder()
      Column() {
        // 标题栏
        this.AppBarBuilder()
        Stack({ alignContent: Alignment.Top }) {
          if (this.showCpnLyric) {
            // 歌词组件
            CpnLyric({ index: this.index, currentDuring: this.currentDuring })
              .transition({ type: TransitionType.Insert, opacity: 0, scale: { x: 0, y: 0 } })
              .transition({ type: TransitionType.Delete, opacity: 0, scale: { x: 0, y: 0 } })
          } else {
            // 唱片TabLayout
            this.DiskPagerBuilder()
          }
        }.margin({ top: 12 }).layoutWeight(1)
        .onClick(() => {
          animateTo({
            duration: 300
          }, () => {
            this.showCpnLyric = !this.showCpnLyric
          })
        })
        // 页面中间控制按钮布局
        this.MiddleActionLayoutBuilder()
        // 播放进度条
        this.PlayProgressBarBuilder()
        // 页面底部控制按钮布局
        this.BottomActionLayoutBuilder()
      }.width("100%")
      .height("100%")
    }.width("100%")
    .height("100%")
  }

  // 高斯模糊背景
  @Builder BlurBackgroundBuilder() {
    Stack() {
      Image(MusicPlayController.playList[this.index].al.picUrl)
        .width("100%")
        .height("100%")
        .blur(100)
      Stack().width("100%")
        .height("100%").backgroundColor("#55000000")
    }.width("100%")
    .height("100%")
  }

  @Builder AppBarBuilder() {
    CommonAppBar({
      bgColor: Color.Transparent,
      rightIcons: [$r('app.media.ic_share')],
      contentColor: Color.White,
      leftIcon: $r('app.media.ic_arrow_down'),
      CustomerTitleBuilder: () => {
        this.CustomerTitleBuilder()
      }
    })
  }

  @Builder CustomerTitleBuilder() {
    Column({ space: SizeConstant.SPACE_S }) {
      Text(MusicPlayController.playList[this.index].name)
        .fontColor(Color.White)
        .fontSize(SizeConstant.TEXT_XL)
        .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(MusicPlayController.playList[this.index].ar[0].name)
        .fontColor(Color.White)
        .fontSize(SizeConstant.TEXT_M)
        .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .height("100%")
    .width("100%")
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder DiskPagerBuilder() {
    Stack({ alignContent: Alignment.Top }) {
      // 唱片半透明背景
      Stack()
        .width(280)
        .height(280)
        .backgroundColor("#55EEEEEE")
        .borderRadius(140)
        .margin({ top: 80 })

      // 唱片
      TabPager({ mediator: this.tabMediator,
        TabPageBuilder: (index) => {
          this.DiskBuilder(index)
        },
        keyGenerator: (index: number) => {
          // return this.playerMode.toString() + "--" + (this.tabMediator.tabItems[index] as SongBean).id.toString()
          return `${this.playerMode == PlayerMode.RANDOM ? "Random" : "Loop"}-${index}-${(this.tabMediator.tabItems[index] as SongBean).id}`

        }
      })
        .width("100%")
        .height(272)
        .margin({ top: 84 })

      // 磁针
      this.DiskNeedleBuilder()
    }
    .transition({ type: TransitionType.Insert, opacity: 0 })
    .transition({ type: TransitionType.Delete, opacity: 0 })
  }

  @Builder DiskBuilder(index: number) {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.ic_disk')).width(272).height(272).objectFit(ImageFit.Fill).borderRadius(95)
      Image(MusicPlayController.playList[index].al.picUrl)
        .width(186)
        .height(186)
        .objectFit(ImageFit.Fill)
        .borderRadius(93)
    }.rotate({
      centerX: "50%",
      centerY: "50%",
      angle: index == this.index ? this.diskRotateAngle : 0
    })
    .width("100%")
    .height("100%")
  }

  @Builder DiskNeedleBuilder() {
    // 磁针
    Image($r("app.media.ic_play_needle"))
      .margin({ left: 62 })
      .width(98)
      .height(148)
      .objectFit(ImageFit.Fill)
      .rotate({ centerX: "16.4%", centerY: "10.9%", angle: this.neededAngle })
  }

  @Builder MiddleActionLayoutBuilder() {
    Row() {
      ClickEffectLayout({ click: () => {
      } }) {
        Image($r('app.media.ic_play_like')).ActionIconStyle(SizeConstant.ICON_L)
      }

      ClickEffectLayout({ click: () => {
      } }) {
        Image($r('app.media.ic_play_download')).ActionIconStyle(SizeConstant.ICON_L)
      }

      ClickEffectLayout({ click: () => {
      } }) {
        Image($r('app.media.ic_play_sing')).ActionIconStyle(SizeConstant.ICON_L)
      }

      ClickEffectLayout({ click: () => {
      } }) {
        Image($r('app.media.ic_play_comment')).ActionIconStyle(SizeConstant.ICON_L)
      }

      ClickEffectLayout({ click: () => {
      } }) {
        Image($r('app.media.ic_play_more')).ActionIconStyle(SizeConstant.ICON_L)
      }
    }
    .width("100%")
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      bottom: SizeConstant.SPACE_L,
      top: SizeConstant.SPACE_L,
      left: SizeConstant.SPACE_XXL,
      right: SizeConstant.SPACE_XXL
    })
  }

  @Builder PlayProgressBarBuilder() {
    Row() {
      Text(TimeUtil.msToTime(this.currentDuring))
        .fontSize(SizeConstant.TEXT_M)
        .width(44)
        .fontColor(Color.White)
      CpnProgressBar({ progress: $progress,
        dragCallback: (isFinish) => {
          if (isFinish) {
            MusicPlayController.seekTo(this.totalDuring * this.progress / 100)
            this.isProgressBarDragging = false
          } else {
            this.isProgressBarDragging = true
          }
        } }).layoutWeight(1).height(32)
      Text(TimeUtil.msToTime(this.totalDuring))
        .fontSize(SizeConstant.TEXT_M)
        .width(44)
        .fontColor(Color.White)
        .textAlign(TextAlign.End)
    }
    .width("100%")
    .height(32)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .padding({ left: SizeConstant.SPACE_L, right: SizeConstant.SPACE_L })
  }

  @Builder BottomActionLayoutBuilder() {
    Row() {
      ClickEffectLayout({ click: () => {
        this.changePlayMode()
      } }) {
        Image(this.getPlayModeIcon()).ActionIconStyle(SizeConstant.ICON_L)
      }

      ClickEffectLayout({ click: () => {
        MusicPlayController.playPre()
      } }) {
        Image($r('app.media.ic_play_pre')).ActionIconStyle(SizeConstant.ICON_XL)
      }

      ClickEffectLayout({ click: () => {
        if (this.playerStatus == PlayerStatus.STARTED) {
          MusicPlayController.pause()
        } else {
          MusicPlayController.start()
        }
      } }) {
        Image(this.playerStatus == PlayerStatus.STARTED ? $r('app.media.ic_play_stop') : $r('app.media.ic_play_start'))
          .ActionIconStyle(SizeConstant.ICON_XXL)
      }

      ClickEffectLayout({ click: () => {
        MusicPlayController.playNext()
      } }) {
        Image($r('app.media.ic_play_next')).ActionIconStyle(SizeConstant.ICON_XL)
      }

      ClickEffectLayout({ click: () => {
        this.customDialogController.open()
      } }) {
        Image($r('app.media.ic_play_play_list')).ActionIconStyle(SizeConstant.ICON_L)
      }
    }
    .width("100%")
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ bottom: 40, top: SizeConstant.SPACE_L, left: SizeConstant.SPACE_XXL, right: SizeConstant.SPACE_XXL })
  }

  changePlayMode() {
    if (this.playerMode == PlayerMode.LOOP) {
      MusicPlayController.setPlayMode(PlayerMode.SINGLE)
    } else if (this.playerMode == PlayerMode.SINGLE) {
      MusicPlayController.setPlayMode(PlayerMode.RANDOM)
    } else {
      MusicPlayController.setPlayMode(PlayerMode.LOOP)
    }
  }

  getPlayModeIcon(): Resource {
    if (this.playerMode == PlayerMode.SINGLE) {
      return $r('app.media.ic_play_mode_single')
    } else if (this.playerMode == PlayerMode.LOOP) {
      return $r('app.media.ic_play_mode_repeat')
    } else {
      return $r('app.media.ic_play_mode_random')
    }
  }

  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 300, curve: Curve.Linear }).slide(SlideEffect.Bottom)
    PageTransitionExit({ type: RouteType.Pop, duration: 300, curve: Curve.Linear }).slide(SlideEffect.Bottom)
  }
}

@Extend(Image) function ActionIconStyle(size: number, fillColor: Color = Color.White) {
  .width(size + SizeConstant.SPACE_M * 2)
  .height(size + SizeConstant.SPACE_M * 2)
  .padding(SizeConstant.SPACE_M)
  .fillColor(fillColor)
}