import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { ClickEffectLayout } from '../..'
import { SizeConstant } from '../../constant/SizeConstant'

/**
 * 空状态布局组件
 */
@Preview
@Component
export struct ViewStateEmpty {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  private tip: string = "暂无数据"
  retryCallback: () => void = () => {
  }
  yPosition: string = "40%"

  build() {
    ClickEffectLayout({ click: this.retryCallback }) {
      Stack() {
        Column() {
          Image($r('app.media.ic_empty')).width(60).height(60)
          Text(this.tip)
            .fontSize(SizeConstant.TEXT_M)
            .fontColor(AppTheme.palette(this.themeType).secondText)
            .fontWeight(FontWeight.Normal)
            .margin(SizeConstant.SPACE_M)
        }
        .position({ y: this.yPosition }).width("100%").alignItems(HorizontalAlign.Center)
      }.width('100%')
      .height('100%')
    }

  }
}