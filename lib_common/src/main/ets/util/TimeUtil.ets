export class TimeUtil {

  static formatCurrentDate() {
    const currentDate: Date = new Date();

    const year: number = currentDate.getFullYear();
    const month: number = currentDate.getMonth() + 1; // 月份从0开始，需要加1
    const day: number = currentDate.getDate();
    const hours: number = currentDate.getHours();
    const minutes: number = currentDate.getMinutes();
    const seconds: number = currentDate.getSeconds();

    // 使用模板字符串拼接日期和时间
    const formattedDate: string = `${year}${TimeUtil.padZero(month)}${TimeUtil.padZero(day)} ${TimeUtil.padZero(hours)}:${TimeUtil.padZero(minutes)}:${TimeUtil.padZero(seconds)}`;

    return formattedDate;
  }

  static padZero(num: number): string {
    return num < 10 ? `0${num}` : `${num}`;
  }

  static formatDate(timestamp) {
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = ("0" + (date.getMonth() + 1)).slice(-2);
    const day = ("0" + date.getDate()).slice(-2);
    const hours = ("0" + date.getHours()).slice(-2);
    const minutes = ("0" + date.getMinutes()).slice(-2);
    const seconds = ("0" + date.getSeconds()).slice(-2);

    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
  }

  static msToTime(ms: number) {
    const seconds = Math.floor((ms / 1000) % 60);
    const minutes = Math.floor((ms / (1000 * 60)) % 60);
    return  (minutes < 10 ? '0' + minutes : minutes) + ':' + (seconds < 10 ? '0' + seconds : seconds);
  }

}