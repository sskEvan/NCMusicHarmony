import router from '@ohos.router'
import { ClickEffectLayout, RouterUrls, SizeConstant } from 'lib_common'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { AlbumBean } from '../../../..'

/**
 * 专辑item组件
 */
@Component
export struct CpnAlbumItem {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  albumBean: AlbumBean

  build() {
    ClickEffectLayout({ click: () => {
      router.pushUrl({ url: RouterUrls.SongSheetDetail })
    } }) {
      Row() {
        Image(this.albumBean.picUrl)
          .width(48)
          .height(48)
          .borderRadius(SizeConstant.RADIUS_M)
          .margin({ right: SizeConstant.SPACE_M })
        Column() {
          Text(this.albumBean.name)
            .fontSize(SizeConstant.TEXT_L)
            .fontColor(AppTheme.palette(this.themeType).firstText)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: SizeConstant.SPACE_S })
          Row() {
            Text(`${this.albumBean.size}首`)
              .fontSize(SizeConstant.TEXT_S)
              .fontColor(AppTheme.palette(this.themeType).secondText)
            Text(`  ·  ${this.albumBean.artists[0].name}`)
              .fontSize(SizeConstant.TEXT_S)
              .fontColor(AppTheme.palette(this.themeType).secondText)
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
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