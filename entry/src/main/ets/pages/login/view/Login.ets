import { SizeConstant } from 'lib_common'
import ViewStateLayout from 'lib_common/src/main/ets/cpn/viewstate/ViewStateLayout'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { QrcodeValueBean } from '../../../bean'
import loginViewModel, { LoginAuthStep, LoginViewModel } from '../viewmodel/LoginViewModel'

@Entry
@Component
struct LoginPage {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  @State qrcodeValueBean: Partial<QrcodeValueBean> = {}
  @State authStep: LoginAuthStep = LoginAuthStep.GENERATE_QRCODE_ING

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Image($r('app.media.ic_app_logo'))
        .width(60)
        .height(60)
        .margin({ top: 160 })
        .borderRadius(30)
        .sharedTransition('imgAppLogo', {
          duration: 300,
          curve: Curve.Linear
        })

      Column() {
        Text("扫码登陆体验")
          .fontSize(SizeConstant.TEXT_XXL)
          .fontColor(AppTheme.palette(this.themeType).firstText)
          .fontWeight(FontWeight.Medium)
        Stack() {
          this.QrcodeBuilder()
        }.layoutWeight(1)

        Text(this.getTextTip())
          .fontSize(SizeConstant.TEXT_M)
          .textAlign(TextAlign.Center)
          .fontColor(AppTheme.palette(this.themeType).thirdText)
          .fontWeight(FontWeight.Normal)
          .padding({ left: SizeConstant.SPACE_XXL, right: SizeConstant.SPACE_XXL })
      }
      .width("70%")
      .height(300)
      .margin(260)
      .padding({ top: SizeConstant.SPACE_XL, bottom: SizeConstant.SPACE_XL })
      .backgroundColor(AppTheme.palette(this.themeType).commonBackground)
      .borderRadius(SizeConstant.RADIUS_L)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.SpaceEvenly)
    }.width("100%").height("100%").backgroundColor(AppTheme.palette(this.themeType).primary)
  }

  getTextTip(): string {
    let tip = ""
    if (this.authStep == LoginAuthStep.GENERATE_QRCODE_ING) {
      tip = "正在生成登陆二维码"
    } else if (this.authStep == LoginAuthStep.GENERATE_QRCODE_SUCCESS) {
      tip = "请使用网易云音乐app扫码授权登陆"
    } else if (this.authStep == LoginAuthStep.AUTH_ING) {
      tip = "等待授权中"
    } else {
      tip = "同步用户信息中"
    }
    return tip + `\(仅供学习使用)`
  }

  @Builder QrcodeBuilder() {
    ViewStateLayout({ onLoadData: async (viewState) => {
      this.qrcodeValueBean = (await loginViewModel.qrcodeAuth(viewState,
        (authStep: LoginAuthStep) => {
          this.authStep = authStep
        })).data
    } }) {
      CpnQRCode({ qrcodeValueBean: this.qrcodeValueBean as QrcodeValueBean })
    }
  }

  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.Linear })
      .opacity(0)
    PageTransitionEnter({ type: RouteType.Pop, duration: 300, curve: Curve.Linear })
      .opacity(1)
    PageTransitionExit({ duration: 300, curve: Curve.Linear })
      .opacity(1)
    PageTransitionExit({ type: RouteType.Pop, duration: 300, curve: Curve.Linear })
      .opacity(0)
  }
}

@Component
struct CpnQRCode {
  @ObjectLink qrcodeValueBean: QrcodeValueBean

  build() {
    QRCode(this.qrcodeValueBean.qrurl).width(160).height(160)
  }
}