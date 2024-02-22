import router from '@ohos.router'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { ScreenUtils } from '..'
import { SizeConstant } from '../constant'
import { ClickEffectLayout } from './ClickEffectLayout'

/**
 * 通用标题栏
 */
@Component
export struct CommonAppBar {
  private bgColor?: ResourceColor = null
  private contentColor?: ResourceColor = null
  private title?: string = null
  private leftIcon?: Resource = null
  private rightIcons?: Resource[] = null
  private titleCenter: Boolean = true
  private leftIconClickCallback?: () => void = null
  private rightIconsClickCallback?: (index: number) => void = null
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  @BuilderParam CustomerTitleBuilder: () => void = null
  @BuilderParam CustomerRightBuilder: () => void = null
  @BuilderParam CustomerContentBuilder: () => void = null

  build() {
    Column() {
      Stack().width("100%").height(ScreenUtils.getStatusBarHeight())

      if (this.CustomerContentBuilder) {
        this.CustomerContentBuilder()
      } else {
        RelativeContainer() {
          // 左边布局
          Row() {
            ClickEffectLayout({ click: () => {
              if (this.leftIconClickCallback) {
                this.leftIconClickCallback()
              } else {
                router.back()
              }
            } }) {
              Image(this.leftIcon ? this.leftIcon : $r('app.media.ic_back'))
                .width(SizeConstant.ICON_L + SizeConstant.SPACE_S * 2)
                .height(SizeConstant.ICON_L + SizeConstant.SPACE_S * 2)
                .padding(SizeConstant.SPACE_S)
                .fillColor(this.contentColor ? this.contentColor : AppTheme.palette(this.themeType).firstIcon)
            }
          }.alignItems(VerticalAlign.Center).padding({ left: SizeConstant.SPACE_M })
          .alignRules({
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            center: { anchor: '__container__', align: VerticalAlign.Center }
          })
          .id("left")

          // 中间布局
          Stack({ alignContent: Alignment.Start }) {
            if (this.CustomerTitleBuilder) {
              this.CustomerTitleBuilder()
            } else {
              if (this.title) {
                Text(this.title)
                  .fontSize(SizeConstant.TEXT_XL)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.contentColor ? this.contentColor : AppTheme.palette(this.themeType).firstText)
                  .maxLines(1)
                  .width("100%")
                  .textAlign(this.titleCenter ? TextAlign.Center : TextAlign.Start)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ left: SizeConstant.SPACE_M, right: SizeConstant.SPACE_M })
              }
            }
          }.width("56%")
          .alignRules(this.titleCenter ?
            {
              middle: { anchor: '__container__', align: HorizontalAlign.Center },
              center: { anchor: '__container__', align: VerticalAlign.Center }
            } :
            {
              left: { anchor: 'left', align: HorizontalAlign.End },
              center: { anchor: '__container__', align: VerticalAlign.Center }
            })
          .id("center")

          // 右边布局
          Row() {
            if (this.CustomerRightBuilder) {
              this.CustomerRightBuilder()
            } else {
              if (this.rightIcons) {
                ForEach(this.rightIcons,
                  (icon, index) => {
                    ClickEffectLayout({ click: () => {
                      if (this.rightIconsClickCallback) {
                        this.rightIconsClickCallback(index)
                      }
                    } }) {
                      Image(icon)
                        .width(SizeConstant.ICON_L + SizeConstant.SPACE_S * 2)
                        .height(SizeConstant.ICON_L + SizeConstant.SPACE_S * 2)
                        .padding(SizeConstant.SPACE_S)
                        .fillColor(this.contentColor ? this.contentColor : AppTheme.palette(this.themeType).firstIcon)
                    }
                  }
                )
              }
            }
          }
          .width("22%")
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.End)
          .padding({ right: SizeConstant.SPACE_M })
          .alignRules({
            right: { anchor: '__container__', align: HorizontalAlign.End },
            center: { anchor: '__container__', align: VerticalAlign.Center }
          })
          .id("right")
        }
        .width("100%")
        .height(SizeConstant.APP_BAR_HEIGHT)
      }
    }.width("100%")
    .height(SizeConstant.APP_BAR_HEIGHT + ScreenUtils.getStatusBarHeight())
    .backgroundColor(this.bgColor ? this.bgColor : AppTheme.palette(this.themeType).commonBackground)
    // .zIndex(1)
  }
}