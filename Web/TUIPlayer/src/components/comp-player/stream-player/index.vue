<!--
 * @Description: 播放器组件
 * @Date: 2021-10-31 16:52:52
 * @LastEditTime: 2021-11-09 15:56:52
-->
<template lang="pug">
div.rtc-stream-container
  cdn-stream(ref="cdnStream" v-if="lineType === LINE_TYPE.CDN")
  rtc-stream(ref="rtcStream" v-if="lineType === LINE_TYPE.RTC")
  leb-stream(ref="lebStream" v-if="lineType === LINE_TYPE.LEB")
</template>

<script>
import rtcStream from './comp-rtc-stream';
import lebStream from './comp-leb-stream';
import cdnStream from './comp-cdn-stream';
import { LINE_TYPE } from '@/constants/room';
import { mapState } from 'vuex';
export default {
  name: 'compStreamPlayer',
  data() {
    return {
      LINE_TYPE,
    };
  },
  components: {
    rtcStream,
    lebStream,
    cdnStream,
  },
  computed: {
    ...mapState({
      lineType: 'lineType',
    }),
  },
  methods: {
    // 用户退出直播间时调用
    handleExit() {
      switch (this.lineType) {
        case LINE_TYPE.RTC:
          this.$refs.rtcStream.handleLeave();
          break;
        case LINE_TYPE.LEB:
          this.$refs.lebStream.destroyPlayer();
          break;
        case LINE_TYPE.CDN:
          this.$refs.cdnStream.destroyPlayer();
          break;
        default:
          break;
      }
    },
  },
};
</script>

<style lang="stylus" scoped>
.palyer-rtc-container
  width 100%
  height 100%
  position relative
  overflow hidden
  .rtc-stream-container
    width 100%
    height 100%
    overflow hidden
  .stream-control
    width 100%
    height 50px
    transition transform 0.2s ease-out
    &.show
      transform translateY(0)
    &.hide
      transform translateY(50px)
</style>
