<!--
 * @Description: 播放器控制组件
 * @Date: 2021-10-31 16:34:20
 * @LastEditTime: 2021-11-09 15:55:33
-->
<template lang="pug">
  div.stream-control-container
    div.left-container
      //- 开始播放按钮
      div.playing.control-item(v-if="playState === PLAY_STATE.PAUSED" @click="handlePlay")
        svg-icon.icon(icon-name="play")
      //- 暂停播放按钮
      div.paused.control-item(v-if="playState === PLAY_STATE.PLAYING" @click="handlePause")
        svg-icon.icon(icon-name="pause")
      //- 分享按钮
      //comp-share
    div.right-container
      //- 线路选择组件
      //comp-line-check
      //- 全屏/取消全屏组件
      comp-full-screen
</template>

<script>
import { mapState } from 'vuex';
import { UPDATE_PLAY_STATE } from '@/constants/mutation-types';
import { PLAY_STATE } from '@/constants/room';
import compShare from './comp-share';
import compLineCheck from './comp-line-check';
import compFullScreen from './comp-full-screen';
export default {
  name: 'compStreamControl',
  data() {
    return {
      PLAY_STATE,
      isFullScreen: false,
      showLineOptions: false,
    };
  },
  components: {
    compShare,
    compLineCheck,
    compFullScreen,
  },
  computed: {
    ...mapState({
      playState: 'playState',
    }),
  },
  methods: {
    handlePlay() {
      this.$store.commit(UPDATE_PLAY_STATE, 'playing');
    },
    handlePause() {
      this.$store.commit(UPDATE_PLAY_STATE, 'paused');
    },
  },
};
</script>

<style lang="stylus" scoped>
.stream-control-container
  width 100%
  height 100%
  position absolute
  bottom 0
  background-image linear-gradient(140deg, rgba(21,27,48,0.70) 0%, rgba(28,33,49,0.90) 100%)
  box-shadow 0 0 3px 0 rgba(32,32,32,0.40)
  .left-container
    position absolute
    height 100%
    left 30px
    display flex
    align-items center
    > div:not(:last-child)
      margin-right 30px
  .right-container
    position absolute
    height 100%
    right 30px
    display flex
    align-items center
    > div:not(:first-child)
      margin-left 30px
  >>> .control-item
    &:hover
      color $highLightColor
      .icon
        fill $highLightColor
  >>> .icon
    cursor pointer
    width 32px
    height 32px
    fill $fontColor
</style>

<i18n>
{
	"en": {
		"Link 1: TRTC ultra-low-latency streaming": "Link 1: TRTC ultra-low-latency streaming",
    "Link 2: LEB": "Link 2: LEB",
    "Link 3: LVB": "Link 3: LVB"
	},
	"zh": {
		"Link 1: TRTC ultra-low-latency streaming": "线路一：TRTC超低延时观看",
    "Link 2: LEB": "线路二：快直播观看",
    "Link 3: LVB": "线路三：标准直播观看"
	}
}
</i18n>
