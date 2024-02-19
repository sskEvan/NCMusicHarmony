import { ViewStateEmpty } from './ViewStateEmpty'
import { ViewStateError } from './ViewStateError'
import { ViewStateLoading } from './ViewStateLoading'

@Component
export default struct ViewStateLayout {
  @State viewState: ViewState = new ViewState(ViewStateType.LOADING)
  onLoadData: (viewState: ViewState) => void = () => {
  }

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

