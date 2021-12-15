<template lang="pug">
  div#app
    div#header
      comp-header
    div#content
      div#left
        comp-player(ref="player" v-if="ready")
      div#right
        comp-message(ref="message")
</template>

<script>
import compHeader from '@/components/comp-header';
import compPlayer from '@/components/comp-player';
import compMessage from '@/components/comp-message';
import api from '@/net/api';
import {
  SET_SDK_APP_ID,
  SET_USER_SIG,
  SET_PLAYER_DOMAIN,
  SET_ROOM_ID,
  SET_ROOM_NAME,
  UPDATE_USER_INFO,
  SET_ANCHOR_USER_ID,
} from '@/constants/mutation-types';
import { mapState } from 'vuex';
export default {
  name: 'App',
  data() {
    return {
      ready: false,
    };
  },
  computed: {
    ...mapState({
      userInfo: 'userInfo',
      roomId: 'roomId',
    }),
  },
  components: {
    compHeader,
    compPlayer,
    compMessage,
  },
  methods: {
    async login() {
      const searchParams = new URLSearchParams(location.search);

      const schoolId = searchParams.get('school_id');
      const sdkappid = searchParams.get('sdkappid');
      const token = searchParams.get('token');
      const userId = searchParams.get('user_id');
      const classId = searchParams.get('class_id');
      api.setToken(token);
      const schoolInfo = await api.getSchoolInfo(schoolId);
      const classInfo = await api.getClassInfo(classId);
      const userInfo = await api.getUserInfo(userId);
      const userSig = await api.getUserSig(classId);

      if (schoolInfo.data && schoolInfo.data.error_code === 0
        && classInfo.data && classInfo.data.error_code === 0
        && userInfo.data && userInfo.data.error_code === 0
        && userSig.data && userSig.data.error_code === 0
      ) {
        const roomInfo = classInfo.data.class_info.rtc_class_info || classInfo.data.class_info.live_class_info;
        // eslint-disable-next-line max-len
        this.handlePlayerInfo(sdkappid, userSig.data.user_sig, classId, roomInfo.name, userInfo.data.users[0], new URL(roomInfo.live_url).hostname);
      }
    },

    handlePlayerInfo(sdkappid, userSig, roomId, roomName, userInfo,  playerDomain) {
      this.$store.commit(SET_SDK_APP_ID, sdkappid);
      this.$store.commit(SET_USER_SIG, userSig);
      this.$store.commit(SET_PLAYER_DOMAIN, playerDomain);
      this.$store.commit(SET_ROOM_ID, roomId);
      this.$store.commit(SET_ROOM_NAME, roomName);
      this.$store.commit(SET_ANCHOR_USER_ID, `${roomId}_mix`);
      this.$store.commit(UPDATE_USER_INFO, {
        userId: userInfo.user_id,
        userName: userInfo.nickname,
        userAvatar: userInfo.avatar,
      });
      this.ready = true;
    },
    // 退出直播间
    async handleExit() {
      // 处理退出直播间
    },
    // 退出登录
    async handleLogout() {
      // 处理退出登录
    },
  },
  created() {
    this.login();
    this.$eventBus.$on('exit', this.handleExit);
    this.$eventBus.$on('logout', this.handleLogout);
  },
  beforeDestroy() {
    this.$eventBus.$off('exit', this.handleExit);
    this.$eventBus.$on('logout', this.handleLogout);
  },
};
</script>

<style lang="stylus">
@import '~assets/style/black-element-ui.styl';
#app
  font-family Avenir, Helvetica, Arial, sans-serif
  -webkit-font-smoothing antialiased
  -moz-osx-font-smoothing grayscale
  text-align center
  background-color $backgroundColor
  color $fontColor
  width 100%
  height 100%
  position absolute
  #header
    width 100%
    height 52px
    background-color $themeColor
  #content
    width 100%
    position absolute
    left 0
    bottom 0
    top 52px
    display flex
    #left
      height 100%
      flex-grow 1
      background-color $backgroundColor
    #right
      width 30%
      min-width 300px
      max-width 406px
      height 100%
      background-color $IMThemeColor
</style>
