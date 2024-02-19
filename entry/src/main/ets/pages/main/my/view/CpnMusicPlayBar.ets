import router from '@ohos.router'
import { ClickEffectLayout, RouterUrls, SizeConstant } from 'lib_common'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { MusicPlayController, PlayStore, STORAGE_PLAY_STORE, PlayerStatus, MusicPlayListDialog } from '../../../..'

@Component
export struct CpnMusicPlayBar {
  @StorageLink(STORAGE_PLAY_STORE) playerStore: Partial<PlayStore> = {}
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  customDialogController: CustomDialogController = new CustomDialogController({
    builder: MusicPlayListDialog(), // 结构 CustomBuilder结构 可以传组件结构
    customStyle: true, // 自由设置样式-builder样式才不会受影响
    alignment: DialogAlignment.Bottom,
    autoCancel: true
  })

  build() {
    Column() {
      ClickEffectLayout({ click: () => {
        router.pushUrl({ url: RouterUrls.MusicPlay })
      } }) {
        Row() {
          Image(MusicPlayController.playList[this.playerStore.index]?.al?.picUrl??"")
            .width(30)
            .height(30)
            .borderRadius(SizeConstant.RADIUS_M)
            .margin({ right: SizeConstant.SPACE_S })

          Text() {
            Span(MusicPlayController.playList[this.playerStore.index]?.name??"").fontSize(SizeConstant.TEXT_M)
              .fontColor(AppTheme.palette(this.themeType).firstText)
            Span(` - ${MusicPlayController.playList[this.playerStore.index]?.ar[0]?.name??""}`)
              .fontSize(SizeConstant.TEXT_M)
              .fontColor(AppTheme.palette(this.themeType).thirdText)
          }.layoutWeight(1)

          Row() {
            ClickEffectLayout({ click: () => {
              if (this.playerStore.playerStats == PlayerStatus.STARTED) {
                MusicPlayController.pause()
              } else {
                MusicPlayController.start()
              }
            } }) {
              Image(this.playerStore.playerStats == PlayerStatus.STARTED ? $r('app.media.ic_play_stop') : $r('app.media.ic_play_start'))
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
