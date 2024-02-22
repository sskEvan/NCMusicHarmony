import { CollapsibleMediator, SizeConstant } from 'lib_common'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'

/**
 * 首页-我的-播客-全部页面
 */
@Component
export struct AllPodcastPage {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  mediator: CollapsibleMediator
  scroller: Scroller

  build() {
    List({ scroller: this.scroller }) {
      ListItem() {
        Stack() {
          Text("TODO:我的全部播客").fontColor(AppTheme.palette(this.themeType).firstText).fontSize(SizeConstant.TEXT_M)
        }.width("100%").margin({ top: 100 })
      }
    }
    .edgeEffect(EdgeEffect.None)
    .height("100%")
    .width("100%")
    .backgroundColor(AppTheme.palette(this.themeType).commonBackground)
    .onScrollFrameBegin((offset: number) => {
      return { offsetRemain: this.mediator?.getScrollerFrameRemainOffset(offset) }
    })
  }
}
