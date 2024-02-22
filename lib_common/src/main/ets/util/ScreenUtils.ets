export class ScreenUtils {
  static avoidArea

  static init(avoidArea) {
    ScreenUtils.avoidArea = avoidArea
  }


  static getStatusBarHeight(): number{
    return px2vp(ScreenUtils.avoidArea.topRect.height)
  }


  static getNavigationBarHeight(): number{
    return ScreenUtils.avoidArea.bottomRect.height
  }
}
