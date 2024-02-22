import router from '@ohos.router'
import { ClickEffectLayout, RouterUrls, SizeConstant } from 'lib_common'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { MusicPlayController, PlayerStatus, MusicPlayListDialog, EventIds } from '../../../..'
import emitter from '@ohos.events.emitter'

/**
 * 底部音乐播放栏组件
 */
@Component
export struct CpnMusicPlayBar {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  customDialogController: CustomDialogController = new CustomDialogController({
    builder: MusicPlayListDialog(),
    customStyle: true,
    alignment: DialogAlignment.Bottom,
    autoCancel: true
  })
  // 当前播放索引
  @State playerIndex: number = 0
  // 播放状态
  @State playerStatus: PlayerStatus | undefined = undefined

  aboutToAppear() {
    this.playerIndex = MusicPlayController.playerIndex
    // 监听播放列表索引
    emitter.on({ eventId: EventIds.PLAYER_INDEX }, (data) => {
      this.playerIndex = data.data.index
    })
    // 监听播放状态
    emitter.on({ eventId: EventIds.PLAYER_STATUS }, (data) => {
      this.playerStatus = data.data.status
    })
  }


  build() {
    Column() {
      ClickEffectLayout({ click: () => {
        router.pushUrl({ url: RouterUrls.MusicPlay })
      } }) {
        Row() {
          Image(MusicPlayController.playList[this.playerIndex]?.al?.picUrl??"")
            .width(30)
            .height(30)
            .borderRadius(SizeConstant.RADIUS_M)
            .margin({ right: SizeConstant.SPACE_S })

          Text() {
            Span(MusicPlayController.playList[this.playerIndex]?.name??"").fontSize(SizeConstant.TEXT_M)
              .fontColor(AppTheme.palette(this.themeType).firstText)
            Span(` - ${MusicPlayController.playList[this.playerIndex]?.ar[0]?.name??""}`)
              .fontSize(SizeConstant.TEXT_M)
              .fontColor(AppTheme.palette(this.themeType).thirdText)
          }.layoutWeight(1)

          Row() {
            ClickEffectLayout({ click: () => {
              if (this.playerStatus == PlayerStatus.STARTED) {
                MusicPlayController.pause()
              } else {
                MusicPlayController.start()
              }
            } }) {
              Image(this.playerStatus == PlayerStatus.STARTED ? $r('app.media.ic_play_stop') : $r('app.media.ic_play_start'))
                .width(SizeConstant.ICON_L + SizeConstant.SPACE_S * 2)
                .height(SizeConstant.ICON_L + SizeConstant.SPACE_S * 2)
                .padding(SizeConstant.SPACE_S)
                .fillColor(AppTheme.palette(this.themeType).secondIcon)
                .margin({ right: SizeConstant.SPACE_M })
            }

            ClickEffectLayout({ click: () => {
              this.customDialogController.open()
            } }) {
              Image($r('app.media.ic_play_list'))
                .width(SizeConstant.ICON_L + SizeConstant.SPACE_S * 2)
                .height(SizeConstant.ICON_L + SizeConstant.SPACE_S * 2)
                .padding(SizeConstant.SPACE_S)
                .fillColor(AppTheme.palette(this.themeType).secondIcon)
            }
          }
        }
        .width("100%")
        .height(SizeConstant.MUSIC_PLAY_BAR_HEIGHT)
        .padding({ left: SizeConstant.SPACE_L, right: SizeConstant.SPACE_L })
        .alignItems(VerticalAlign.Center)
      }

      Stack()
        .height(`0.5px`)
        .width("100%")
        .backgroundColor(AppTheme.palette(this.themeType).divider)
    }.height(SizeConstant.MUSIC_PLAY_BAR_HEIGHT)
    .backgroundColor(AppTheme.palette(this.themeType).navBarBackground)
  }
}
