import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { CpnLoading } from '..'
import { SizeConstant } from '../..'

/**
 * 加载状态布局组件
 */
@Preview
@Component
export struct ViewStateLoading {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  private tip: string = ""
  flexAlign: FlexAlign = FlexAlign.Center
  yPosition: string = "40%"

  build() {
    Stack() {
      Column() {
        CpnLoading()
        Text(this.tip)
          .fontSize(SizeConstant.TEXT_M)
          .fontColor(AppTheme.palette(this.themeType).secondText)
          .fontWeight(FontWeight.Normal)
          .margin(SizeConstant.SPACE_M)
      }.position({ y: this.yPosition }).width("100%").alignItems(HorizontalAlign.Center)
    }.width('100%')
    .height('100%')
  }
}