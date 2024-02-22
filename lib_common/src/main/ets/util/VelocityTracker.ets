/**
 * 触摸滑动速度记录器
 */
export default class VelocityTracker {
  private touchYEvents: TouchEvent[] = []
  private touchXEvents: TouchEvent[] = []

  // 1: 向上滑动（dy<0） 2: 向下滑动（dy>0）
  private lastYDirection = 1
  // 1: 向左滑动（dy<0） 2: 向右滑动（dy>0）
  private lastXDirection = 1

  beginTrackYVelocity(event: TouchEvent) {
    this.touchYEvents.splice(0, this.touchYEvents.length)
    this.lastYDirection = 1
    this.touchYEvents.unshift(event)
  }

  addYMovement(event: TouchEvent) {
    if (this.touchYEvents.length > 0) {
      const lastTouchEvent = this.touchYEvents[0]
      const dy = event.touches[0].y - lastTouchEvent.touches[0].y
      const direction = dy < 0 ? 1 : 2
      if (direction != this.lastYDirection && this.touchYEvents.length > 1) {
        this.touchYEvents.splice(0, this.touchYEvents.length)
      }
      this.lastYDirection = direction
    }
    this.touchYEvents.unshift(event)
    this.touchYEvents.forEach((item: TouchEvent, index: number) => {
      if (event.timestamp - item.timestamp > 50000000) {
        this.touchYEvents.splice(index, 1)
      }
    })
    if (this.touchYEvents.length > 10) {
      this.touchYEvents.shift()
    }
  }

  computeYVelocity(): number {
    if (this.touchYEvents.length >= 2) {
      let velocitySum = 0
      for (let index = 0; index < this.touchYEvents.length - 1; index++) {
        const curTouchEvent = this.touchYEvents[index]
        const preTouchEvent = this.touchYEvents[index + 1]
        const costTime = curTouchEvent.timestamp - preTouchEvent.timestamp
        const dy = curTouchEvent.touches[0].y - preTouchEvent.touches[0].y
        const velocity = Math.pow(dy * 100000000 / costTime, 2) / 10 * (dy >= 0 ? 1 : -1)
        velocitySum += velocity
      }
      const avgVelocity = velocitySum / this.touchYEvents.length
      return avgVelocity
    } else {
      return 1
    }
  }


  beginTrackXVelocity(event: TouchEvent) {
    this.touchXEvents.splice(0, this.touchXEvents.length)
    this.lastXDirection = 1
    this.touchXEvents.unshift(event)
  }

  addXMovement(event: TouchEvent) {
    if (this.touchXEvents.length > 0) {
      const lastTouchEvent = this.touchXEvents[0]
      const dx = event.touches[0].x - lastTouchEvent.touches[0].x
      const direction = dx < 0 ? 1 : 2
      if (direction != this.lastXDirection) {
        this.touchXEvents.splice(0, this.touchXEvents.length)
      }
      this.lastXDirection = direction
    }
    this.touchXEvents.unshift(event)
    this.touchXEvents.forEach((item: TouchEvent, index: number) => {
      if (event.timestamp - item.timestamp > 50000000) {
        this.touchXEvents.splice(index, 1)
      }
    })
    if (this.touchXEvents.length > 10) {
      this.touchXEvents.shift()
    }
  }


  computeXVelocity(): number {
    if (this.touchXEvents.length >= 2) {
      let velocitySum = 0
      for (let index = 0; index < this.touchXEvents.length - 1; index++) {
        const curTouchEvent = this.touchXEvents[index]
        const preTouchEvent = this.touchXEvents[index + 1]
        const costTime = curTouchEvent.timestamp - preTouchEvent.timestamp
        const dx = curTouchEvent.touches[0].x - preTouchEvent.touches[0].x
        const velocity = Math.pow(dx * 100000000 / costTime, 2) / 10 * (dx >= 0 ? 1 : -1)
        velocitySum += velocity
      }
      const avgVelocity = velocitySum / this.touchXEvents.length
      return avgVelocity
    } else {
      return 1
    }
  }

  performFling(velocity: number, frameCallback: (updateOffsetEachFrame: number) => void): number {
    if (Math.abs(velocity) >= 100) {
      // 17ms更新一次
      const updateCycle = 17
      // 最长惯性滑动时间
      const maxFlingTime = 2500
      const maxUpdateOffsetEachFrame = 30
      const updateCount = Math.min(Math.ceil(maxFlingTime / updateCycle), Math.ceil(Math.abs(velocity) / 50))
      let curCount = 0
      let flingTimerId = 0
      flingTimerId = setInterval(() => {
        curCount++
        const decayFactor = (updateCount - curCount) * 1.0 / updateCount
        const updateOffsetEachFrame = velocity < 0 ? maxUpdateOffsetEachFrame * decayFactor : -maxUpdateOffsetEachFrame * decayFactor
        frameCallback(updateOffsetEachFrame)
        if (curCount >= updateCount) {
          clearInterval(flingTimerId)
        }
      }, updateCycle)
      return flingTimerId
    } else {
      return -1
    }
  }

}