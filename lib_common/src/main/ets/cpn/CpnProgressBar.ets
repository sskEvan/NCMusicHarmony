import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'

/**
 * 进度条组件
 */
@Component
export struct CpnProgressBar {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  progressHeight: number = 1
  progressActiveHeight: number = 2
  progressThumbSize: number = 6
  progressThumbActiveSize: number = 12
  progressColor: ResourceColor = AppTheme.palette(this.themeType).primary
  bgColor: ResourceColor = Color.White
  thumbColor: ResourceColor = Color.White
  @Link progress: number
  @State isActive: boolean = false
  @State progressWidth: number = 0
  dragCallback: (isFinish: boolean) => void = null

  build() {
    Stack({ alignContent: Alignment.Start }) {
      Stack()
        .width("100%")
        .height(this.isActive ? this.progressActiveHeight : this.progressHeight)
        .backgroundColor(this.bgColor)
        .borderRadius(this.isActive ? this.progressActiveHeight / 2 : this.progressHeight / 2)
      Stack()
        .width(`${this.progress}%`)
        .height(this.isActive ? this.progressActiveHeight : this.progressHeight)
        .backgroundColor(this.progressColor)
        .borderRadius(this.isActive ? this.progressActiveHeight / 2 : this.progressHeight / 2)
      Stack()
        .width(this.isActive ? this.progressThumbActiveSize : this.progressThumbSize)
        .height(this.isActive ? this.progressThumbActiveSize : this.progressThumbSize)
        .backgroundColor(this.thumbColor)
        .borderRadius(this.isActive ? this.progressThumbActiveSize / 2 : this.progressThumbSize / 2)
        .offset({
          x: (this.progressWidth - (this.isActive ? this.progressThumbActiveSize : this.progressThumbSize)) * this.progress / 100.0
        })
    }
    .height("100%")
    .width("100%")
    .onAreaChange((_, newValue) => {
      this.progressWidth = newValue.width as number
    })
    .onTouch((event: TouchEvent) => {
      if (event.type == TouchType.Down || event.type == TouchType.Move) {
        this.isActive = true
        this.progress = Math.max(0, Math.min(100, event.touches[0].x / this.progressWidth * 100))
        if (this.dragCallback) {
          this.dragCallback(false)
        }
      } else if (event.type == TouchType.Up || event.type == TouchType.Cancel) {
        this.isActive = false
        this.progress = Math.max(0, Math.min(100, event.touches[0].x / this.progressWidth * 100))
        if (this.dragCallback) {
          this.dragCallback(true)
        }
      }
    })
  }
}