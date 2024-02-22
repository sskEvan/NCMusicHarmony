import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { IUserInfoBean, STORAGE_MAIN_DRAWER_TOGGLE, STORAGE_USER_INFO, UserInfoBean } from '../../../../'
import animator, { AnimatorResult } from '@ohos.animator'
import display from '@ohos.display'
import { LogUtil } from 'lib_common/src/main/ets/util/LogUtil'
import { CommonNetworkImage, ScreenUtils, SizeConstant } from 'lib_common'
/**
 * 首页-侧边栏
 */
@Component
export struct MainDrawer {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  @StorageLink(STORAGE_MAIN_DRAWER_TOGGLE) @Watch("mainDrawerToggleChange") mainDrawerToggle: boolean = false
  @StorageLink(STORAGE_USER_INFO) userInfo: UserInfoBean = new UserInfoBean({} as IUserInfoBean)
  offsetAnimator: AnimatorResult | undefined = undefined
  @State contentOffset: number = 0
  contentWidth: number = 0

  aboutToAppear() {
    this.contentWidth = display.getDefaultDisplaySync().width * 0.8
    this.contentOffset = -this.contentWidth
  }

  mainDrawerToggleChange() {
    if (this.offsetAnimator) {
      this.offsetAnimator.cancel()
    }

    this.offsetAnimator = animator.create({
      duration: 200,
      easing: "linear",
      delay: 0,
      fill: "forwards",
      direction: "normal",
      iterations: 1,
      begin: this.mainDrawerToggle ? -this.contentWidth : 0,
      end: !this.mainDrawerToggle ? -this.contentWidth : 0
    })

    this.offsetAnimator.onframe = (progress) => {
      this.contentOffset = progress
      LogUtil.debug("MainDrawer this.contentOffset=" + this.contentOffset)
    }
    this.offsetAnimator.play()
  }

  build() {
    Stack({ alignContent: Alignment.Start }) {
      if (this.mainDrawerToggle) {
        this.Background()
      }
      if (this.contentOffset != -this.contentWidth) {
        this.Content()
      }
    }
  }

  @Builder
  Content() {
    Column() {
      this.UserInfo()
    }
    .width("80%")
    .height("100%")
    .backgroundColor(AppTheme.palette(this.themeType).commonBackground)
    .offset({ x: px2vp(this.contentOffset) })
    .justifyContent(FlexAlign.Start)
    .padding({ top: ScreenUtils.getStatusBarHeight() })
  }

  @Builder
  UserInfo() {
    Row() {
      CommonNetworkImage({
        url: this.userInfo.detail.profile.avatarUrl,
        placeHolder: $r('app.media.ic_default_avatar')
      })
        .margin({ right: SizeConstant.SPACE_M })
        .width(SizeConstant.ICON_XXL)
        .height(SizeConstant.ICON_XXL)
        .borderRadius(SizeConstant.ICON_XXL / 2)
        .clip(true)
      Text(this.userInfo.detail.profile.nickname)
        .fontSize(SizeConstant.TEXT_XL)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.palette(this.themeType).firstText)
    }
    .width("100%")
    .height(80)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({ left: SizeConstant.SPACE_XXL })
  }

  @Builder
  Background() {
    Stack()
      .width("100%")
      .height("100%")
      .backgroundColor("#33000000")
      .onClick(() => {
        this.mainDrawerToggle = false
      })
  }
}