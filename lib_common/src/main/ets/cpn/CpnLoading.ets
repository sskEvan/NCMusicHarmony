import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'

/**
 * 加载组件
 */
@Preview
@Component
export struct CpnLoading {
  private loadingRectArray: Array<LoadingRect> = [new LoadingRect({ startRatio: 0.7, endRatio: 0.15, animDuring: 600 }),
    new LoadingRect({ startRatio: 0.23, endRatio: 0.85, animDuring: 550 }),
    new LoadingRect({ startRatio: 0.55, endRatio: 0.3, animDuring: 500 }),
    new LoadingRect({ startRatio: 0.26, endRatio: 0.78, animDuring: 600 })]
  @State private rect1HeightPercent: number = 0.7
  @State private rect2HeightPercent: number = 0.23
  @State private rect3HeightPercent: number = 0.55
  @State private rect4HeightPercent: number = 0.26
  private loadingWidth = 26
  private loadingHeight = 22
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT

  build() {
    Row() {
      Stack().height(this.loadingHeight * this.rect1HeightPercent).rectStyle()
      Stack().height(this.loadingHeight * this.rect2HeightPercent).rectStyle()
      Stack().height(this.loadingHeight * this.rect3HeightPercent).rectStyle()
      Stack().height(this.loadingHeight * this.rect4HeightPercent).rectStyle()
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Bottom)
    .width(this.loadingWidth)
    .height(this.loadingHeight)
    .onVisibleAreaChange([0, 1], (isVisible: boolean, currentRatio: number) => {
      if (isVisible) {
        console.log("CpnLoading", "CpnLoading isVisible=" + isVisible + ",currentRatio:" + currentRatio)
        this.doAnim()
      }
    })
  }

  private doAnim() {
    for (let index = 0; index < this.loadingRectArray.length; index++) {
      const rect = this.loadingRectArray[index];
      animateTo({
        duration: rect.animDuring,
        playMode: PlayMode.Alternate,
        iterations: -1,
      }, () => {
        if (index == 0) {
          this.rect1HeightPercent = rect.endRatio
        } else if (index == 1) {
          this.rect2HeightPercent = rect.endRatio
        } else if (index == 2) {
          this.rect3HeightPercent = rect.endRatio
        } else if (index == 3) {
          this.rect4HeightPercent = rect.endRatio
        }
      })
    }
  }

  @Styles rectStyle() {
    .width("18%")
    .backgroundColor(AppTheme.palette(this.themeType).primary)
    .borderRadius({ topLeft: this.loadingWidth * 0.15 * 0.4, topRight: this.loadingWidth * 0.15 * 0.4 })

  }
}

interface ILoadingRect {
  startRatio: number
  endRatio: number
  animDuring: number
}

export class LoadingRect implements ILoadingRect {
  startRatio: number = 0
  endRatio: number = 0
  animDuring: number = 0

  constructor(model: ILoadingRect) {
    this.startRatio = model.startRatio
    this.endRatio = model.endRatio
    this.animDuring = model.animDuring
  }
}
