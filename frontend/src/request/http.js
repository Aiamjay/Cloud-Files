import axios from 'axios'
import router from "@/router";
import globalFunction from "@/globalFunctions";
import { MessageBox } from 'element-ui';
// 请求超时时间
axios.defaults.timeout = 10000 * 5

// 请求基础 URL
axios.defaults.baseURL = '/api'

// POST 请求头
axios.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded'

// 请求拦截器
axios.interceptors.request.use(
  (config) => {
    config.headers['token'] = globalFunction.getCookies('token')
    return config
  },
  (error) => {
    console.log(error)
    return Promise.reject(error)
  }
)

// 响应拦截器
axios.interceptors.response.use(
  (response) => {
    if (response.status === 200) {
      return Promise.resolve(response)
    }
  },
  // 服务器状态码不是200的情况
  (error) => {
    if (error.response.status) {
      console.log(error.response)
      switch (error.response.status) {
        case 401:
          loginTip()
          break
        default:
          return Promise.reject(error.response)
      }
    }
  }
)

/**
 * 封装 get方法 对应 GET 请求
 * @param {string} url 请求url
 * @param {object} params 查询参数
 * @returns {Promise}
 */
export function get(url, params) {
  return new Promise((resolve, reject) => {
    axios
      .get(url, {
        params: params,
      })
      .then((res) => {
        resolve(res.data)
      })
      .catch((err) => {
        reject(err.data)
      })
  })
}

/**
 * 封装 post 方法，对应 POST 请求
 * @param {string} url 请求url
 * @param {object} data 请求体
 * @param {boolean | undefined} info 请求体是否为 FormData 格式
 * @returns {Promise}
 */
export function post(url, data = {}, info) {
  return new Promise((resolve, reject) => {
    let newData = data
    if (info) {
      //  转formData格式
      newData = new FormData()
      for (const i in data) {
        newData.append(i, data[i])
      }
    }
    axios
      .post(url, newData)
      .then((res) => {
        resolve(res.data)
      })
      .catch((err) => {
        reject(err.data)
      })
  })
}

// 登录提醒
const loginTip = function() {
  MessageBox.alert('Please login', 'Hint', {
    confirmButtonText: 'confirm',
    callback: () => {
      router.push({
        path: '/login',
        query: { redirect: router.currentRoute.fullPath },  //  将当前页面的url传递给login页面进行操作
      })
    },
  });
}
