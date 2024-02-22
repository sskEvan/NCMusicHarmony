import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'

/**
 * 首页-发现页面
 */
@Component
export struct DiscoveryPage {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT

  build() {
    Stack() {
      Text("TODO:发现").fontColor(AppTheme.palette(this.themeType).firstText)
    }.width("100%").height("100%").backgroundColor(AppTheme.palette(this.themeType).commonBackground)
  }
}





