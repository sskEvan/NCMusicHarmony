import { DarkThemePalette, DefaultThemePalette, IThemePalette, OriginThemePalette, GreenThemePalette, ThemeType } from '.'

// 默认主题
export const defaultThemePalette = new DefaultThemePalette()
// 黑色主题
export const darkThemePalette = new DarkThemePalette()
// 橙色主题
export const originThemePalette = new OriginThemePalette()
// 绿色主题
export const greenThemePalette = new GreenThemePalette()

export class AppTheme {
  /**
   * 获取主题取色盘
   */
  static palette(themeType: ThemeType): IThemePalette {
    if (themeType == ThemeType.DEFAULT) {
      return defaultThemePalette
    } else if (themeType == ThemeType.DARK) {
      return darkThemePalette
    } else if (themeType == ThemeType.ORIGIN) {
      return originThemePalette
    } else if (themeType == ThemeType.GREEN) {
      return greenThemePalette
    } else {
      return defaultThemePalette
    }
  }
}

// 主题类型
export const THEME_TYPE = "THEME_TYPE"

