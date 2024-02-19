import { ClickEffectLayout, CpnLoading, ListDataSource, LogUtil } from 'lib_common'
import { SizeConstant } from 'lib_common'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { MusicPlayController, PlayStore, SongBean, STORAGE_PLAY_STORE, PlayModeType } from '../../../..'

@Component
export struct CurrentMusicPlayList {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  @StorageLink(STORAGE_PLAY_STORE) @Watch("playerStoreChange") playerStore: PlayStore = new PlayStore({})
  lazyDataSource: ListDataSource = new ListDataSource()
  lastPlayMode: PlayModeType

  aboutToAppear() {
    this.lazyDataSource.reloadData(MusicPlayController.playList)
    this.lastPlayMode = this.playerStore.playMode
  }

  playerStoreChange() {
    if ((this.lastPlayMode == PlayModeType.RANDOM && this.playerStore.playMode != PlayModeType.RANDOM)
    || (this.lastPlayMode != PlayModeType.RANDOM && this.playerStore.playMode == PlayModeType.RANDOM)) {
      this.lazyDataSource.reloadData(MusicPlayController.playList)
      // for (let index = 0; index < MusicPlayController.playList.length; index++) {
      //   LogUtil.debug("playerStoreChange reloadData: " + MusicPlayController.playList[index].name)
      // }
    }
    this.lastPlayMode = this.playerStore.playMode
  }

  @Builder ActionHeaderBuilder() {
    Row() {
      ClickEffectLayout({ click: () => {
        if (this.playerStore.playMode == PlayModeType.LOOP) {
          MusicPlayController.setPlayMode(PlayModeType.SINGLE)
        } else if (this.playerStore.playMode == PlayModeType.SINGLE) {
          MusicPlayController.setPlayMode(PlayModeType.RANDOM)
        } else {
          MusicPlayController.setPlayMode(PlayModeType.LOOP)
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
    if (this.playerStore.playMode == PlayModeType.SINGLE) {
      return $r('app.media.ic_play_mode_single')
    } else if (this.playerStore.playMode == PlayModeType.LOOP) {
      return $r('app.media.ic_play_mode_repeat')
    } else {
      return $r('app.media.ic_play_mode_random')
    }
  }

  getPlayModeText(): string {
    if (this.playerStore.playMode == PlayModeType.SINGLE) {
      return "单曲循环"
    } else if (this.playerStore.playMode == PlayModeType.LOOP) {
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
        if (index == this.playerStore.index) {
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