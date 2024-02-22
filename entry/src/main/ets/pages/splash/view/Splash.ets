import {RouterUrls } from 'lib_common'
import { AppTheme, THEME_TYPE, ThemeType } from 'lib_theme'
import router from '@ohos.router'
import { IUserInfoBean, UserInfoBean, UserManager, STORAGE_USER_INFO } from '../../..'


/**
 * 欢迎页面
 */
@Entry
@Component
export default struct SplashPage {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  @StorageLink(STORAGE_USER_INFO) userInfo: UserInfoBean = new UserInfoBean({} as IUserInfoBean)

  async aboutToAppear() {
    this.userInfo = await UserManager.getUserInfo()
    setTimeout(() => {
      router.replaceUrl({ url: this.userInfo ? RouterUrls.Index : RouterUrls.Login })
    }, 1000)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Image($r('app.media.ic_app_logo'))
        .width(80)
        .height(80)
        .margin({ top: 300 })
        .borderRadius(40)
        .sharedTransition('imgAppLogo', {
          duration: 300,
          curve: Curve.Linear
        })

    }.width("100%").height("100%").backgroundColor(AppTheme.palette(this.themeType).primary)
  }

  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 300, curve: Curve.Linear })
      .opacity(0)
    PageTransitionEnter({ type: RouteType.Pop, duration: 300, curve: Curve.Linear })
      .opacity(1)
    PageTransitionExit({ type: RouteType.Push, duration: 300, curve: Curve.Linear })
      .opacity(1)
    PageTransitionExit({ type: RouteType.Pop, duration: 300, curve: Curve.Linear })
      .opacity(0)
  }
}

