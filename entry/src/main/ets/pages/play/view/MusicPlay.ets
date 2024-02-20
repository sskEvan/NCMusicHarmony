import {
  ClickEffectLayout,
  CommonAppBar,
  CpnProgressBar,
  LogUtil,
  SizeConstant,
  StringUtil,
  TabLayoutPagerMediator,
  TabPager
} from 'lib_common'
import {
  MusicPlayListDialog,
  CpnLyric,
  PlayStore,
  STORAGE_PLAY_STORE,
  PlayModeType,
  MusicPlayController,
  PlayerStatus,
  SongBean,
} from '../../..'

@Entry
@Component
export struct MusicPlayPage {
  @StorageLink(STORAGE_PLAY_STORE) @Watch("playerStoreChange") playerStore: Partial<PlayStore> = {}
  @State progress: number = 0
  @State @Watch("tabMediatorChange") tabMediator: TabLayoutPagerMediator = new TabLayoutPagerMediator({})
  @State neededAngle: number = 0
  @State showCpnLyric: boolean = false
  customDialogController: CustomDialogController = new CustomDialogController({
    builder: MusicPlayListDialog(),
    customStyle: true,
    alignment: DialogAlignment.Bottom,
    autoCancel: true
  })
  lastPlayMode: PlayModeType
  isProgressBarDragging: boolean = false

  aboutToAppear() {
    this.tabMediator = new TabLayoutPagerMediator({
      tabItems: MusicPlayController.playList,
      cacheCount: 1,
      currentIndex: this.playerStore.index
    })
  }

  tabMediatorChange() {
    animateTo({
      duration: 300
    }, () => {
      this.neededAngle = Number.isInteger(this.tabMediator.realTimeIndex) && this.playerStore.playerStats == PlayerStatus.STARTED ? 0 : -25
    })
    if (this.tabMediator.currentIndex !== this.playerStore.index) {
      MusicPlayController.play(this.tabMediator.currentIndex)
    }
  }

  playerStoreChange() {
    animateTo({
      duration: 300
    }, () => {
      this.neededAngle = Number.isInteger(this.tabMediator.realTimeIndex) && this.playerStore.playerStats == PlayerStatus.STARTED ? 0 : -25
    })
    if (this.tabMediator.currentIndex !== this.playerStore.index) {
      this.tabMediator.jumpToIndex(this.playerStore.index)
    }
    if ((this.lastPlayMode == PlayModeType.RANDOM && this.playerStore.playMode != PlayModeType.RANDOM)
    || (this.lastPlayMode != PlayModeType.RANDOM && this.playerStore.playMode == PlayModeType.RANDOM)) {
      this.tabMediator = new TabLayoutPagerMediator({
        tabItems: MusicPlayController.playList,
        cacheCount: 1,
        currentIndex: this.playerStore.index
      })
    }
    this.lastPlayMode = this.playerStore.playMode

    if (this.playerStore.currentDuring != 0 && this.playerStore.totalDuring != 0) {
      if (!this.isProgressBarDragging) {
        this.progress = this.playerStore.currentDuring * 100 / this.playerStore.totalDuring
      }
    } else {
      this.progress = 0
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      this.BlurBackgroundBuilder()
      Column() {
        this.AppBarBuilder()
        Stack({ alignContent: Alignment.Top }) {
          if (this.showCpnLyric) {
            CpnLyric()
              .transition({ type: TransitionType.Insert, opacity: 0, scale: { x: 0, y: 0 } })
              .transition({ type: TransitionType.Delete, opacity: 0, scale: { x: 0, y: 0 } })
          } else {
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

        this.MiddleActionLayoutBuilder()
        this.PlayProgressBarBuilder()
        this.BottomActionLayoutBuilder()
      }.width("100%")
      .height("100%")
    }.width("100%")
    .height("100%")
  }

  @Builder BlurBackgroundBuilder() {
    Stack() {
      Image(MusicPlayController.playList[this.playerStore.index].al.picUrl)
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
      Text(MusicPlayController.playList[this.playerStore.index].name)
        .fontColor(Color.White)
        .fontSize(SizeConstant.TEXT_XL)
        .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(MusicPlayController.playList[this.playerStore.index].ar[0].name)
        .fontColor(Color.White)
        .fontSize(SizeConstant.TEXT_M)
        .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .height("100%")
    .width("100%")
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.tabMediator.jumpToIndex(this.tabMediator.currentIndex + 40)
    })
  }

  @Builder DiskPagerBuilder() {
    Stack({ alignContent: Alignment.Top }) {
      // 磁盘半透明背景
      Stack()
        .width(280)
        .height(280)
        .backgroundColor("#55EEEEEE")
        .borderRadius(140)
        .margin({ top: 80 })

      // 磁盘
      TabPager({ mediator: this.tabMediator,
        TabPageBuilder: (index) => {
          this.DiskBuilder(index)
        },
        keyGenerator: (index: number) => {
          return (this.tabMediator.tabItems[index] as SongBean).id.toString() + this.playerStore.playMode.toString()
        }
      })
        .width("100%")
        .height(272)
        .margin({ top: 84 })

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
    }
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
      Text(StringUtil.msToTime(this.playerStore.currentDuring))
        .fontSize(SizeConstant.TEXT_M)
        .width(44)
        .fontColor(Color.White)
      CpnProgressBar({ progress: $progress,
        dragCallback: (isFinish) => {
          if (isFinish) {
            MusicPlayController.seekTo(this.progress)
            this.isProgressBarDragging = false
          } else {
            this.isProgressBarDragging = true
          }
        } }).layoutWeight(1).height(32)
      Text(StringUtil.msToTime(this.playerStore.totalDuring))
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
        if (this.playerStore.playerStats == PlayerStatus.STARTED) {
          MusicPlayController.pause()
        } else {
          MusicPlayController.start()
        }
      } }) {
        Image(this.playerStore.playerStats == PlayerStatus.STARTED ? $r('app.media.ic_play_stop') : $r('app.media.ic_play_start'))
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
    if (this.playerStore.playMode == PlayModeType.LOOP) {
      MusicPlayController.setPlayMode(PlayModeType.SINGLE)
    } else if (this.playerStore.playMode == PlayModeType.SINGLE) {
      MusicPlayController.setPlayMode(PlayModeType.RANDOM)
    } else {
      MusicPlayController.setPlayMode(PlayModeType.LOOP)
    }
  }

  getPlayModeIcon(): Resource {
    if (this.playerStore.playMode == PlayModeType.SINGLE) {
      return $r('app.media.ic_play_mode_single')
    } else if (this.playerStore.playMode == PlayModeType.LOOP) {
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