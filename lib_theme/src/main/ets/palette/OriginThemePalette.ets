
import { IThemePalette } from '.'

/**
 * 默认主题取色盘
 */
export class OriginThemePalette implements IThemePalette {
  primary: ResourceColor = "#FFFF6633"
  secondary: ResourceColor = "#FFF3906F"
  pure: ResourceColor = "#FFFFFFFF"
  divider: ResourceColor = "#FFDDDDDD"
  commonBackground: ResourceColor = "#FFFFFFFF"
  deepenBackground: ResourceColor = "#FFEEEEEE"
  titleBackground: ResourceColor = "#FFFAFAFA"
  navBarBackground: ResourceColor = "#FFFAFAFA"
  drawerBackground: ResourceColor = "#FFFAFAFA"
  firstText: ResourceColor = "#FF333333"
  secondText: ResourceColor = "#FF666666"
  thirdText: ResourceColor = "#FF999999"
  firstIcon: ResourceColor = "#FF333333"
  secondIcon: ResourceColor = "#FF666666"
  thirdIcon: ResourceColor = "#FF999999"
}