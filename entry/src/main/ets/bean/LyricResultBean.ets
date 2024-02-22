import { BaseResultBean } from 'lib_common'


/**
 * 歌词请求结果实体类
 */
export class LyricResultBean extends BaseResultBean {
  transUser?: LyricContributorBean
  lyricUser?: LyricContributorBean
  lrc?: LrcBean
  tlyric?: LrcBean
}

export class LyricContributorBean {
  id: number
  status: number
  demand: number
  userid: number
  nickname: string
  uptime: number
}

/**
 [00:00.000] 作词 : 潘源良
 [00:01.000] 作曲 : Eric Kwok
 [00:02.000] 编曲 : 张子坚
 [00:03.000] 制作人 : Eric Kwok
 [00:16.490]你 何以始终不说话
 [00:22.580]尽管讲出不快吧
 [00:26.170]事与冀盼有落差
 [00:29.010]请不必惊怕
 [00:31.240]我 仍然会冷静聆听
 [00:37.240]仍然紧守于身边
 [00:41.040]与你进退也共鸣
 [00:45.130]时日会蔓延再蔓延
 [00:49.290]某些不可改变的改变
 [00:52.730]与一些不要发现的发现
 [00:56.370]就这么放大了缺点
 [01:00.210]来让我问谁可决定
 [01:03.760]那些东西叫作完美至善
 [01:07.460]我只懂得 爱你在每天
 [01:14.090]当潮流爱新鲜
 [01:17.730]当旁人爱标签
 [01:21.380]幸得伴着你我
 [01:24.310]是窝心的自然
 [01:28.810]当闲言再尖酸
 [01:32.450]给他妒忌多点
 [01:36.100]因世上的至爱
 [01:38.970]是不计较条件
 [01:43.370]谁又可清楚看见
 [01:59.620]美 难免总有些缺憾
 [02:05.440]若果不甘心去问
 [02:09.190]问到最尾叫内心
 [02:11.870]也长出裂痕
 [02:14.250]笑 何妨与你又重温
 [02:20.800]仍然我说我庆幸
 [02:24.340]你永远胜过别人
 [02:28.550]期待美没完爱没完
 [02:32.640]放开不必打算的打算
 [02:36.130]作一些可以约定的约定
 [02:39.770]就抱紧以后每一天
 [02:43.680]其实你定然都发现
 [02:47.210]我有很多未达完美事情
 [02:50.810]我只懂得 再努力每天
 [02:57.490]当潮流爱新鲜
 [03:01.130]当旁人爱标签
 [03:04.820]幸得伴着你我
 [03:07.750]是窝心的自然
 [03:12.160]当闲言再尖酸
 [03:15.850]给他妒忌多点
 [03:19.500]因世上的至爱
 [03:22.530]是不计较条件
 [03:26.890]谁又可清楚看见
 */
export class LrcBean {
  version: number
  lyric: string
}

export class LyricModel {
  time: number
  lyric ?: string
  tLyric ?: string

  constructor(time: number, lyric? : string, tLyric?: string) {
    this.time = time
    this.lyric = lyric
    this.tLyric = tLyric
  }
}

