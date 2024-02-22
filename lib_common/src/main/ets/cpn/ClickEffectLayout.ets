let globalClickEffecting: boolean = false

/**
 * 自定义点击效果容器
 * 点击的时候，被包裹的组件，会做透明度1->0.8,缩放1->0.97的动画
 */
@Component
export struct ClickEffectLayout {
  @BuilderParam private content: () => void
  @State private alphaState: number = 1
  @State private scaleState: number = 1
  private lastTouchX = 0
  private lastTouchY = 0
  private touchOffsetX = 0
  private touchOffsetY = 0
  private downTouchTimeStamp = 0
  private animEffect = false
  click?: (event?: ClickEvent) => void

  build() {
    Stack() {
      this.content()
    }.opacity(this.alphaState)
    .scale({
      centerX: "50%",
      centerY: "50%",
      x: this.scaleState,
      y: this.scaleState
    }).onTouch((event: TouchEvent) => {
      if (this.click) {
        if (event.type == TouchType.Down) {
          this.lastTouchX = event.touches[0].x
          this.lastTouchY = event.touches[0].y
          this.touchOffsetX = 0
          this.touchOffsetY = 0
          this.downTouchTimeStamp = event.timestamp
          this.animEffect = false
        } else if (event.type == TouchType.Move) {
          if (globalClickEffecting) {
            return
          }
          const cost = event.timestamp - this.downTouchTimeStamp
          const curTouchX = event.touches[0].x
          const curTouchY = event.touches[0].y
          const dx = curTouchX - this.lastTouchX
          const dy = curTouchY - this.lastTouchY
          this.touchOffsetX += dx
          this.touchOffsetY += dy
          this.lastTouchX = curTouchX
          this.lastTouchY = curTouchY
          if (event.timestamp - this.downTouchTimeStamp >= 80000000 && !this.animEffect) {
            if (Math.abs(this.touchOffsetX) <= 1 && Math.abs(this.touchOffsetY) <= 1) {
              this.animEffect = true
              globalClickEffecting = true
              animateTo({
                duration: 100,
              }, () => {
                this.alphaState = 0.8
                this.scaleState = 0.97
              })
            }
          }
        } else if (event.type == TouchType.Up || event.type == TouchType.Cancel) {
          if (this.alphaState !== 1 && this.scaleState !== 1) {
            this.restore()
          }
        }
      }
    }).onClick((event) => {
      if (this.click) {
        this.click(event)
        if (!this.animEffect) {
          globalClickEffecting = true
          animateTo({
            duration: 100,
            onFinish: () => {
              this.restore()
            }
          }, () => {
            this.alphaState = 0.8
            this.scaleState = 0.97
          })
        }
      }
    })
  }

  private restore() {
    animateTo({
      duration: 100,
      onFinish: () => {
        globalClickEffecting = false
      }
    }, () => {
      this.alphaState = 1
      this.scaleState = 1
    })
  }
}