/*
 * @Description: 这里是 TUIPlayer 应用的基础信息配置
 * @Date: 2021-10-19 16:53:28
 * @LastEditTime: 2021-11-03 10:28:09
 */

/**
 * 腾讯云 SDKAppId，需要替换为您自己账号下的 SDKAppId。
 *
 * 进入腾讯云实时音视频[控制台](https://console.cloud.tencent.com/rav ) 创建应用，即可看到 SDKAppId，
 * 它是腾讯云用于区分客户的唯一标识。
 */
export const sdkAppId = 12323123;
/**
* 签名过期时间，建议不要设置的过短
* <p>
* 时间单位：秒
* 默认时间：7 x 24 x 60 x 60 = 604800 = 7 天
*/
export const expireTime = 604800;

/**
* 计算签名用的加密密钥，获取步骤如下：
*
* step1. 进入腾讯云实时音视频[控制台](https://console.cloud.tencent.com/rav )，如果还没有应用就创建一个，
* step2. 单击“应用配置”进入基础配置页面，并进一步找到“帐号体系集成”部分。
* step3. 点击“查看密钥”按钮，就可以看到计算 UserSig 使用的加密的密钥了，请将其拷贝并复制到如下的变量中
*
* 注意：该方案仅适用于调试Demo，正式上线前请将 UserSig 计算代码和密钥迁移到您的后台服务器上，以避免加密密钥泄露导致的流量盗用。
* 文档：https://cloud.tencent.com/document/product/647/17275#Server
*/
export const secretKey = '13123';

/**
* 设置房间信息，请保证TUIPusher&TUIPlayer房间信息一致
*
*/
export const roomInfo = {
  // 房间id, TUIPusher和TUIPlayer的roomId应保持一致
  roomId: 10012345,
  // 房间昵称
  roomName: '我的直播间',
};

/**
* 设置推流端用户信息, 请保证TUIPusher&TUIPlayer主播信息一致
*
* 注意：web端屏幕分享流和音视频流为两个Client, 屏幕分享流用户id为`share_${userId}`
*/
export const anchorUserInfo = {
  // 用户ID
  userId: 'user_anchor',
  // 用户昵称
  userName: '主播',
  // 用户头像
  userAvatar: '',
};

// 拉流端用户信息
export const userInfo = {
  // 用户ID
  userId: 'user_audience',
  // 用户昵称
  userName: `观众${Math.floor(Math.random() * 100)}`,
  // 用户头像
  userAvatar: '',
};

// 播放域名
export const playerDomain = '';
