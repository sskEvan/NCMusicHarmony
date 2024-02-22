import { CollapsibleMediator, SizeConstant } from 'lib_common'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'

/**
 * 动态点赞用户列表页面
 */
@Component
export struct DynamicLikeListPage {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  mediator: CollapsibleMediator
  scroller: Scroller

  build() {
    List({ scroller: this.scroller }) {
      ListItem() {
        Stack() {
          Text("TODO:动态喜欢列表").fontColor(AppTheme.palette(this.themeType).firstText).fontSize(SizeConstant.TEXT_M)
        }.width("100%").margin({ top: 100 })
        .backgroundColor(AppTheme.palette(this.themeType).commonBackground)
      }
    }
    .edgeEffect(EdgeEffect.None)
    .height("100%")
    .width("100%")
    .onScrollFrameBegin((offset: number) => {
      return { offsetRemain: this.mediator?.getScrollerFrameRemainOffset(offset) }
    })
  }
}
