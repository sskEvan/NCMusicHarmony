import { DarkThemePalette, DefaultThemePalette, IThemePalette, ThemeType } from '.'

// 默认主题
const defaultThemePalette = new DefaultThemePalette()
// 黑色主题
const darkThemePalette = new DarkThemePalette()


export class AppTheme {
  /**
   * 获取主题取色盘
   */
  static palette(themeType: ThemeType): IThemePalette {
    if (themeType == ThemeType.DEFAULT) {
      return defaultThemePalette
    } else if (themeType == ThemeType.DARK) {
      return darkThemePalette
    } else {
      return defaultThemePalette
    }
  }
}

// 主题类型
export const THEME_TYPE = "THEME_TYPE"

