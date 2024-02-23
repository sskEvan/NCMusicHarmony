import { IThemePalette } from '.'

/**
 * 黑色主题取色盘
 */
export class DarkThemePalette implements IThemePalette {
  primary: ResourceColor = "#FFF0484E"
  secondary: ResourceColor = "#FFF0888C"
  pure: ResourceColor = "#FF000000"
  divider: ResourceColor = "#FF555555"
  commonBackground: ResourceColor = "#FF222222"
  deepenBackground: ResourceColor = "#FF444444"
  titleBackground: ResourceColor = "#FF333333"
  navBarBackground: ResourceColor = "#FF333333"
  drawerBackground: ResourceColor = "#FF333333"
  firstText: ResourceColor = "#FFFFFFFF"
  secondText: ResourceColor = "#FFBBBBBB"
  thirdText: ResourceColor = "#FF999999"
  firstIcon: ResourceColor = "#FFFFFFFF"
  secondIcon: ResourceColor = "#FFBBBBBB"
  thirdIcon: ResourceColor = "#FF999999"
}