import { ClickEffectLayout, CpnLoading, ListDataSource } from 'lib_common'
import { SizeConstant } from 'lib_common'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { MusicPlayController, SongBean, PlayerMode, EventIds, PlayerStatus } from '../../../..'
import emitter from '@ohos.events.emitter'

/**
 * 当前播放列表组件（底部播放列表弹框中）
 */
@Component
export struct CurrentMusicPlayList {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  lazyDataSource: ListDataSource = new ListDataSource()
  // 播放模式
  @State playerMode: PlayerMode | undefined = undefined
  // 播放状态
  @State playerStatus: PlayerStatus | undefined = undefined
  // 当前播放索引
  @State playerIndex: number = 0

  aboutToAppear() {
    this.lazyDataSource.reloadData(MusicPlayController.playList)
    this.playerMode = MusicPlayController.playerMode
    this.playerIndex = MusicPlayController.playerIndex
    this.playerStatus = MusicPlayController.playerStatus
    // 监听播放模式
    emitter.on({ eventId: EventIds.PLAYER_MODE }, (data) => {
      const newPlayerMode = data.data.playerMode
      if ((this.playerMode == PlayerMode.RANDOM && newPlayerMode != PlayerMode.RANDOM)
      || (this.playerMode != PlayerMode.RANDOM && newPlayerMode == PlayerMode.RANDOM)) {
        this.lazyDataSource.reloadData(MusicPlayController.playList)
      }
      this.playerMode = newPlayerMode
    })
    // 监听播放列表索引
    emitter.on({ eventId: EventIds.PLAYER_INDEX }, (data) => {
      this.playerIndex = data.data.index
    })
    // 监听播放播放状态
    emitter.on({ eventId: EventIds.PLAYER_STATUS }, (data) => {
      this.playerStatus = data.data.status
    })
  }

  @Builder ActionHeaderBuilder() {
    Row() {
      ClickEffectLayout({ click: () => {
        if (this.playerMode == PlayerMode.LOOP) {
          MusicPlayController.setPlayMode(PlayerMode.SINGLE)
        } else if (this.playerMode == PlayerMode.SINGLE) {
          MusicPlayController.setPlayMode(PlayerMode.RANDOM)
        } else {
          MusicPlayController.setPlayMode(PlayerMode.LOOP)
        }
      } }) {
        Row() {
          Image(this.getPlayModeIcon())
            .width(SizeConstant.ICON_S)
            .height(SizeConstant.ICON_S)
            .margin({ right: SizeConstant.SPACE_S })
            .fillColor(AppTheme.palette(this.themeType).secondIcon)
          Text(this.getPlayModeText())
            .fontSize(SizeConstant.TEXT_M)
            .fontColor(AppTheme.palette(this.themeType).secondText)
        }
        .backgroundColor(AppTheme.palette(this.themeType).navBarBackground)
        .height(28)
        .border({ width: "1px", color: AppTheme.palette(this.themeType).divider, radius: 14 })
        .width(86)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }

      Row() {
        Image($r('app.media.ic_play_download'))
          .width(SizeConstant.ICON_M + SizeConstant.SPACE_S * 2)
          .height(SizeConstant.ICON_M + SizeConstant.SPACE_S * 2)
          .padding(SizeConstant.SPACE_S)
          .margin({ right: SizeConstant.SPACE_M })
          .fillColor(AppTheme.palette(this.themeType).secondIcon)
        Image($r('app.media.ic_delete'))
          .width(SizeConstant.ICON_M + SizeConstant.SPACE_S * 2)
          .height(SizeConstant.ICON_M + SizeConstant.SPACE_S * 2)
          .padding(SizeConstant.SPACE_S)
          .fillColor(AppTheme.palette(this.themeType).secondIcon)
      }
    }
    .width("100%")
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({
      top: SizeConstant.SPACE_S,
      bottom: SizeConstant.SPACE_M,
    })
    .padding({
      left: SizeConstant.SPACE_L,
      right: SizeConstant.SPACE_L
    })
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

  getPlayModeText(): string {
    if (this.playerMode == PlayerMode.SINGLE) {
      return "单曲循环"
    } else if (this.playerMode == PlayerMode.LOOP) {
      return "循环播放"
    } else {
      return "随机播放"
    }
  }

  @Builder ListBuilder() {
    List() {
      LazyForEach(this.lazyDataSource,
        (item, index) => {
          ListItem() {
            this.MusicItemBuilder(item, index)
          }
        },
        (item: object, index: number) => {
          return `${index}-${JSON.stringify(item)}`
        }
      )
    }.width("100%").layoutWeight(1)
  }

  @Builder MusicItemBuilder(bean: SongBean, index: number) {
    ClickEffectLayout({ click: () => {
      MusicPlayController.play(index)
    } }) {
      Row() {
        if (index == this.playerIndex && this.playerStatus == PlayerStatus.STARTED) {
          CpnLoading({ loadingWidth: 13, loadingHeight: 11 }).margin({ right: SizeConstant.SPACE_M })
        }
        Text() {
          Span(bean.name).fontColor(AppTheme.palette(this.themeType).firstText).fontSize(SizeConstant.TEXT_L)
          Span("  ·  " + bean.ar[0].name)
            .fontColor(AppTheme.palette(this.themeType).thirdText)
            .fontSize(SizeConstant.TEXT_M)
        }
      }
      .width("100%")
      .height(40)
      .padding({ left: SizeConstant.SPACE_XL, right: SizeConstant.SPACE_XL })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
    }
  }

  build() {
    Column() {
      this.ActionHeaderBuilder()
      this.ListBuilder()
    }
  }
}