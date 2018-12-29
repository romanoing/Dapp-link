// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import Vuex from 'vuex'
import App from './App'
import router from './routes'
import ElementUI from 'element-ui'
import VueResource from 'vue-resource'
import VuePaginate from 'vue-paginate'
import 'element-ui/lib/theme-chalk/index.css';

Vue.config.productionTip = false
Vue.use(ElementUI)
Vue.use(VuePaginate)
Vue.use(VueResource)
Vue.use(Vuex)
  // Vue.use(Vuex)

window.Event = new Vue(); // global event
Vue.config.productionTip = false;
// import mixinn from './libs/mixinViews';

// Vue.mixin(mixinn)

const store = new Vuex.Store({
  state: {
    // domain:'http://test.example.com', //保存后台请求的地址，修改时方便
    userInfo: [],
    userIsRegistered: true,
  },
  mutations: {
    //更新用户信息
    updateUserInfo(state, newUserInfo) {
      state.userInfo = newUserInfo;
    },
    setUnregister(state, isRes) {
      state.userIsRegistered = isRes;
    }
  }
})



/* eslint-disable no-new */

new Vue({
  el: '#app',
  // mixins: [mixin],
  router,
  components: { App },
  template: '<App/>',
  store,
  // watch: {
  //   "$route": 'checkRegister'
  // },
  created() {
    // this.checkRegister()
  },
  methods: {
    // checkRegister() {
    //   this.tmoConn = setInterval(() => {
    //     if (this.blockchainIsConnected()) {
    //       clearInterval(this.tmoConn)
    //       window.bc.contract().isRegistered.call((error, res) => {
    //         if (error) {
    //           console.error(error);
    //         } else {
    //           if (this.$store.userIsRegistered == false) //没有注册
    //           {
    //             this.$store.commit('setUnregister', false);
    //             console.log("unresgister")
    //             this.$router.push('/register')
    //           } else {
    //             console.log("resgister")
    //             this.$router.push('/')
    //             this.$store.commit('setUnregister', true);
    //           }
    //         }
    //       })
    //     }
    //   }, 500)
    // }
  }
})

export default Vue;