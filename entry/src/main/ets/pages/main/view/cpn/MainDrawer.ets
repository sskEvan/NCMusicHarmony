import {
  AppTheme,
  darkThemePalette,
  defaultThemePalette,
  greenThemePalette,
  IThemePalette,
  originThemePalette,
  ThemeType,
  THEME_TYPE
} from 'lib_theme'
import { IUserInfoBean, STORAGE_MAIN_DRAWER_TOGGLE, STORAGE_USER_INFO, UserInfoBean } from '../../../../'
import animator, { AnimatorResult } from '@ohos.animator'
import display from '@ohos.display'
import { CommonNetworkImage, ScreenUtils, SizeConstant, LogUtil, ClickEffectLayout } from 'lib_common'
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

  @Builder Content() {
    Column() {
      this.UserInfo()
      this.MenuCard()
    }
    .width("80%")
    .height("100%")
    .backgroundColor(AppTheme.palette(this.themeType).drawerBackground)
    .offset({ x: px2vp(this.contentOffset) })
    .justifyContent(FlexAlign.Start)
    .padding({ top: ScreenUtils.getStatusBarHeight(), left: SizeConstant.SPACE_XL, right: SizeConstant.SPACE_XL })
  }

  @Builder UserInfo() {
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
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({ top: SizeConstant.SPACE_XL, bottom: SizeConstant.SPACE_XL })
  }

  @Builder MenuCard() {
    Column() {
      Stack({ alignContent: Alignment.Start }) {
        Text("设置")
          .fontSize(SizeConstant.TEXT_M)
          .fontColor(AppTheme.palette(this.themeType).secondText)
      }
      .width("100%")
      .height(36)

      Divider().strokeWidth("1px").color(AppTheme.palette(this.themeType).divider)

      CpnChangeTheme()
    }
    .width("100%")
    .padding({ left: SizeConstant.SPACE_M, right: SizeConstant.SPACE_M })
    .backgroundColor(AppTheme.palette(this.themeType).commonBackground)
    .border({ radius: SizeConstant.RADIUS_M })
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


@Component
export struct CpnChangeTheme {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  @State themeList: ThemeItemModel[] = []
  @State showThemeList: boolean = false
  @State arrowAngle: number = 0
  @State themeListHeight: number = 0
  heightAnimator: AnimatorResult | undefined = undefined

  aboutToAppear() {
    this.themeList.push(new ThemeItemModel("默认", ThemeType.DEFAULT, defaultThemePalette))
    this.themeList.push(new ThemeItemModel("夜间", ThemeType.DARK, darkThemePalette, "#FF000000"))
    this.themeList.push(new ThemeItemModel("橙色", ThemeType.ORIGIN, originThemePalette))
    this.themeList.push(new ThemeItemModel("绿色", ThemeType.GREEN, greenThemePalette))
  }

  build() {
    Column() {
      ClickEffectLayout({ click: () => {
        this.showThemeList = !this.showThemeList
        animateTo({
          duration: 300
        }, () => {
          {
            this.arrowAngle = this.showThemeList ? 180 : 0
            // this.themeListHeight = this.showThemeList ? 48 * this.themeList.length : 0
          }
        })
        if (this.heightAnimator) {
          this.heightAnimator.cancel()
        }
        this.heightAnimator = animator.create({
          duration: 200,
          easing: "linear",
          delay: 0,
          fill: "forwards",
          direction: "normal",
          iterations: 1,
          begin: !this.showThemeList ? 48 * this.themeList.length : 0,
          end: this.showThemeList ? 48 * this.themeList.length : 0
        })
        this.heightAnimator.onframe = (progress) => {
          this.themeListHeight = progress
        }
        this.heightAnimator.play()
      } }) {
        Row() {
          Image($r('app.media.ic_theme'))
            .width(SizeConstant.ICON_L)
            .height(SizeConstant.ICON_L)
            .fillColor(AppTheme.palette(this.themeType).firstIcon)
            .margin({ right: SizeConstant.SPACE_M })
          Text("当前主题")
            .fontSize(SizeConstant.TEXT_L)
            .fontColor(AppTheme.palette(this.themeType).firstText)
            .layoutWeight(1)
          Image($r('app.media.ic_arrow_down'))
            .width(SizeConstant.ICON_M)
            .height(SizeConstant.ICON_M)
            .rotate({ angle: this.arrowAngle })
            .fillColor(AppTheme.palette(this.themeType).firstIcon)
        }
        .width("100%")
        .height(48)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
      }

      if (this.themeListHeight != 0) {
        List() {
          ForEach(this.themeList, (item: ThemeItemModel, _) => {
            this.CpnThemeItem(item)
          })
        }
        .height(this.themeListHeight)
      }
    }
  }

  @Builder CpnThemeItem(item: ThemeItemModel) {
    ClickEffectLayout({ click: () => {
      this.themeType = item.themeType
    } }) {
      Row() {
        Stack()
          .width(SizeConstant.ICON_M)
          .height(SizeConstant.ICON_M)
          .border({ radius: SizeConstant.ICON_M / 2 })
          .backgroundColor(item.displayColor)
          .margin({ right: SizeConstant.SPACE_M })
        Text(item.name)
          .fontSize(SizeConstant.TEXT_L)
          .fontColor(AppTheme.palette(this.themeType).firstText)
          .layoutWeight(1)
        if (item.themeType == this.themeType) {
          Image($r('app.media.ic_selected'))
            .width(SizeConstant.ICON_L)
            .height(SizeConstant.ICON_L)
            .fillColor(item.displayColor)
        }
      }
      .width("100%")
      .height(48)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
    }
  }
}

class ThemeItemModel {
  name: string
  themeType: ThemeType
  palette: IThemePalette
  displayColor: ResourceColor

  constructor(name: string, themeType: ThemeType, palette: IThemePalette, displayColor: ResourceColor = null) {
    this.name = name
    this.themeType = themeType
    this.palette = palette
    if (displayColor) {
      this.displayColor = displayColor
    } else {
      this.displayColor = this.palette.primary
    }
  }
}
