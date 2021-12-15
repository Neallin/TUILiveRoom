import axios from 'axios';

const ROOT = 'https://tcic-api.qcloudclass.com';
export default {
  token: null,
  cache: {},
  setToken(token) {
    this.token = token;
  },
  async getSchoolInfo(schoolId) {
    return axios.post(`${ROOT}/v1/school/getInfo`, {
      school_id: schoolId,
      scene: 'default',
    }, {
      params: {
        random: +new Date(),
        token: this.token,
      },
    });
  },
  async getClassInfo(classId) {
    return axios.post(`${ROOT}/v1/class/getInfo`, {
      class_id: classId,
      all_task: 0,
    }, {
      params: {
        random: +new Date(),
        token: this.token,
      },
    });
  },
  async getUserInfo(userId) {
    return axios.post(`${ROOT}/v1/user/list`, {
      user_ids: [userId],
    }, {
      params: {
        random: +new Date(),
        token: this.token,
      },
    });
  },
  async getUserSig(classId) {
    return axios.post(`${ROOT}/v1/member/join`, {
      class_id: classId,
      device: 1,
      platform: 5,
      role: 0,
      version: "1.5.0",
    }, {
      params: {
        random: +new Date(),
        token: this.token,
      },
    });
  },
};
