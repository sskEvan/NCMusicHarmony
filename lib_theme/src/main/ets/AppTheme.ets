import { DarkThemePalette, DefaultThemePalette, IThemePalette, ThemeType } from '.'

const defaultThemePalette = new DefaultThemePalette()
const darkThemePalette = new DarkThemePalette()


export class AppTheme {
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

