import { ViewStateEmpty } from './ViewStateEmpty'
import { ViewStateError } from './ViewStateError'
import { ViewStateLoading } from './ViewStateLoading'

/**
 * 页面状态切换组件
 */
@Component
export struct ViewStateLayout {
  @State viewState: ViewState = new ViewState(ViewStateType.LOADING)
  // 数据加载回调
  onLoadData: (viewState: ViewState) => void = () => {}

  // 重新加载
  onRetry() {
    this.onLoadData(this.viewState)
  }

  @BuilderParam
  ContentBuilder: () => void = () => {
  }

  aboutToAppear() {
    this.onLoadData(this.viewState)
  }

  build() {
    Stack() {
      if (this.viewState.type === ViewStateType.LOADING) {
        ViewStateLoading()
      } else if (this.viewState.type === ViewStateType.EMPTY) {
        ViewStateEmpty({ retryCallback: () => {
          this.onRetry()
        } })
      } else if (this.viewState.type === ViewStateType.ERROR) {
        ViewStateError({
          errorCode: this.viewState.errorCode,
          errorMessage: this.viewState.errorMessage,
          retryCallback: () => {
            this.onRetry()
          }
        })
      } else {
        this.ContentBuilder()
      }
    }.width("100%").height("100%")
  }
}

@Observed
export class ViewState {
  public errorCode: number = 0
  public errorMessage: string = ""
  public type: ViewStateType

  constructor(type: ViewStateType) {
    this.type = type
  }
}

export enum ViewStateType {
  LOADING = 0,
  SUCCESS = 1,
  EMPTY = 2,
  ERROR = 3
}

