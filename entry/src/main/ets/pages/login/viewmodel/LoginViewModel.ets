import { BaseViewModel, LogUtil, RequestOptions, RouterUrls, ViewState } from 'lib_common';
import router from '@ohos.router';
import {
  ApiConstant,
  UserManager,
  AccountInfoResultBean,
  UserDetailResultBean,
  QrcodeAuthResultBean,
  QrcodeKeyResultBean,
  QrcodeValueResultBean,
  UserInfoBean
} from '../../..';


/**
 * 登陆ViewModel
 */
export class LoginViewModel extends BaseViewModel {
  checkAuthTimerId: number = -1

  async qrcodeAuth(viewState: ViewState,
                   authStepCallback: (step: LoginAuthStep) => void): Promise<QrcodeValueResultBean> {
    if (this.checkAuthTimerId != -1) {
      clearInterval(this.checkAuthTimerId)
      this.checkAuthTimerId = -1
    }
    const qrcodeKeyResult: QrcodeKeyResultBean = await this.get<QrcodeKeyResultBean>(
      new RequestOptions({
        url: ApiConstant.URL_QRCODE_KEY,
        data: { "timeStamp": new Date().getTime() },
        viewState: viewState
      }))
    if (qrcodeKeyResult) {
      const qrcodeValueResult = await this.get<QrcodeValueResultBean>(
        new RequestOptions({
          url: ApiConstant.URL_QRCODE_VALUE,
          data: {
            "key": qrcodeKeyResult.data.unikey,
            "timeStamp": new Date().getTime()
          },
          viewState: viewState
        }))
      if (qrcodeValueResult) {
        authStepCallback(LoginAuthStep.GENERATE_QRCODE_SUCCESS)
        this.checkAuthLoop(qrcodeKeyResult.data.unikey, viewState, authStepCallback)
      }
      return qrcodeValueResult
    }
  }


  private async checkAuthLoop(unikey: string,
                              viewState: ViewState,
                              authStepCallback: (step: LoginAuthStep) => void) {
    this.checkAuthTimerId = setInterval(async () => {
      LogUtil.debug(`LoginViewModel::checkAuthLoop done`)
      const result: QrcodeAuthResultBean = await this.get<QrcodeAuthResultBean>(new RequestOptions({
        url: ApiConstant.URL_CHECK_QRCODE,
        data: {
          "key": unikey,
          "timeStamp": new Date().getTime()
        },
        successCondition: (result: QrcodeAuthResultBean) => {
          return result.code == 803
        },
        interceptWhenNoSuccess: false
      }))
      LogUtil.debug(`LoginViewModel::checkAuthLoop::result::${JSON.stringify(result)}`)
      if (result.code == 803) {
        clearInterval(this.checkAuthTimerId)
        this.checkAuthTimerId = -1
        this.getAccountInfo(result.cookie, viewState, authStepCallback)
      } else if (result.code === 802) {
        authStepCallback(LoginAuthStep.AUTH_ING)
      }
    }, 4000)
  }

  private async getAccountInfo(cookie: string,
                               viewState: ViewState,
                               authStepCallback: (step: LoginAuthStep) => void) {
    authStepCallback(LoginAuthStep.SYNC_USER_INFO)
    const accountInfoResult: AccountInfoResultBean = await this.get<AccountInfoResultBean>(
      new RequestOptions({
        url: ApiConstant.URL_ACCOUNT_INFO,
        data: { "cookie": cookie, },
        viewState: viewState
      }))
    LogUtil.debug(`LoginViewModel::getAccountInfo::${JSON.stringify(accountInfoResult)}`)

    if (accountInfoResult) {
      const userDetailResult: UserDetailResultBean = await this.get<UserDetailResultBean>(
        new RequestOptions({
          url: ApiConstant.URL_USER_DETAIL,
          data: { "uid": accountInfoResult.account.id },
          viewState: viewState
        }))
      if (userDetailResult) {
        const userInfo = new UserInfoBean({
          cookie: cookie,
          detail: userDetailResult
        })
        UserManager.setUserInfo(userInfo)
        router.replaceUrl({ url: RouterUrls.Index })
      }
    }
  }
}

/**
 * 登陆认证步骤枚举
 */
export enum LoginAuthStep {
  // 生成二维码中
  GENERATE_QRCODE_ING,
  // 生成二维码成功
  GENERATE_QRCODE_SUCCESS,
  // 授权中
  AUTH_ING,
  // 同步用户信息中
  SYNC_USER_INFO
}

export const loginViewModel = new LoginViewModel();

