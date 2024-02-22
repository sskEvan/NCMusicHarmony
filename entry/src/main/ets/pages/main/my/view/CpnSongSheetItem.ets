import router from '@ohos.router'
import { ClickEffectLayout, CommonNetworkImage, RouterUrls, SizeConstant } from 'lib_common'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { UserPlaylistBean } from '../../../..'

/**
 * 歌单item组件
 */
@Component
export struct CpnSongSheetItem {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  playListBean: UserPlaylistBean

  build() {
    ClickEffectLayout({ click: () => {
      router.pushUrl({ url: RouterUrls.SongSheetDetail, params: this.playListBean })
    } }) {
      Row() {
        CommonNetworkImage({url: this.playListBean.coverImgUrl})
          .width(48)
          .height(48)
          .borderRadius(SizeConstant.RADIUS_M)
          .margin({ right: SizeConstant.SPACE_M })
          .clip(true)
        Column() {
          Text(this.playListBean.name)
            .fontSize(SizeConstant.TEXT_L)
            .fontColor(AppTheme.palette(this.themeType).firstText)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: SizeConstant.SPACE_S })
          Row() {
            Text(`${this.playListBean.trackCount}首`)
              .fontSize(SizeConstant.TEXT_S)
              .fontColor(AppTheme.palette(this.themeType).secondText)
              .margin({ right: SizeConstant.SPACE_L })
            Text(`${this.playListBean.playCount}次播放`)
              .fontSize(SizeConstant.TEXT_S)
              .fontColor(AppTheme.palette(this.themeType).secondText)
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)


        Image($r('app.media.ic_more'))
          .width(SizeConstant.ICON_M)
          .height(SizeConstant.ICON_M)
          .fillColor(AppTheme.palette(this.themeType).thirdIcon)
      }
      .width("100%")
      .padding({
        left: SizeConstant.SPACE_L,
        right: SizeConstant.SPACE_L,
        top: SizeConstant.SPACE_S,
        bottom: SizeConstant.SPACE_S
      })
    }
  }
}