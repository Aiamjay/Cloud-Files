export default {
  state: {
    storageValue: 0, //  文件已占用的存储空间大小
  },
  mutations: {
    /**
     * 保存文件已占用的存储空间大小
     * @param {object} state Vuex 的 state 对象
     * @param {number} data 存储大小
     */
    setStorageValue(state, data) {
      state.storageValue = data;
    },
  },
  actions: {
    /**
     * 获取文件已占用的存储空间
     */
    showStorage(context) {
    },
  },
}
