
import { ClickEffectLayout, SizeConstant } from 'lib_common'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'


@Component
export struct CpnPodcastSheetItem {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  index: number = 0

  build() {
    ClickEffectLayout() {
      Row() {
        Image($r('app.media.ic_default_place_holder'))
          .width(48)
          .height(48)
          .borderRadius(SizeConstant.RADIUS_M)
          .margin({ right: SizeConstant.SPACE_M })
        Column() {
          Text("钢琴纯音乐")
            .fontSize(SizeConstant.TEXT_M)
            .fontColor(AppTheme.palette(this.themeType).firstText)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: SizeConstant.SPACE_S })
          Text("60年代末,艺术摇滚在摇滚界方兴未艾,有着Kinks和Who的摇滚歌剧、Deep Purple与皇家爱乐乐团的合作演出,Pink Floyd也与前卫作曲家Ron Geesin一起合作了这张专辑")
            .fontSize(SizeConstant.TEXT_M)
            .fontColor(AppTheme.palette(this.themeType).secondText)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
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