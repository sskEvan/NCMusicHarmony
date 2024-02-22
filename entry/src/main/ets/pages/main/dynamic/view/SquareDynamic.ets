import { AppTheme, THEME_TYPE, ThemeType } from 'lib_theme'

/**
 * 首页-动态-广场页面
 */
@Component
export struct SquareDynamicPage {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT

  build() {
    Stack() {
      Text("TODO:广场").fontColor(AppTheme.palette(this.themeType).firstText)
    }.width("100%").height("100%").backgroundColor(AppTheme.palette(this.themeType).commonBackground)
  }
}