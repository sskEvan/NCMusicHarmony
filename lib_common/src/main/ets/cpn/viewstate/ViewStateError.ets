import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { ClickEffectLayout } from '..'
import { SizeConstant } from '../..'

/**
 * 错误状态布局组件
 */
@Preview
@Component
export struct ViewStateError {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  private errorCode?: number
  private errorMessage?: string
  yPosition: string = "40%"
  retryCallback: () => void = () => {
  }

  getErrorTip() {
    if (this.errorCode == 2300006) {
      return "网络错误，点击重试"
    } else {
      return `${this.errorMessage ? this.errorMessage : "未知错误"}，点击重试`
    }
  }

  build() {
    ClickEffectLayout({click: this.retryCallback}) {
      Stack() {
        Column() {
          Image($r('app.media.ic_error')).width(92).height(60)
          Text(this.getErrorTip())
            .fontSize(SizeConstant.TEXT_M)
            .fontColor(AppTheme.palette(this.themeType).secondText)
            .fontWeight(FontWeight.Normal)
            .margin(SizeConstant.SPACE_M)
        }
        .position({ y: this.yPosition }).width("100%").alignItems(HorizontalAlign.Center)

      }
      .width('100%')
      .height('100%')
    }
  }
}