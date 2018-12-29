<template>
<div>
  <top-menu v-on:getOwnProfile='getOwnProfile' v-show="this.$store.state.userIsRegistered"></top-menu>
  <h2 v-show="!bcConnected && !this.bcConnectionError">
    Connecting...
  </h2>
  <div class="main-content" v-show="this.bcConnected && !this.bcConnectionError">
    <router-view></router-view>
  </div>
  <div v-show="this.bcConnectionError" class="top-20">
    <h2>连接失败</h2>
    <h3 v-show="this.bcSmartContractAddressError">
      It seems like the address of the smart contract is wrong!
    </h3>
    <p>
      Please check:
    </p>
    <ul>
      <li>The blockchain is running.</li>
      <li>The port in your settings (file: <b>libs/mixinViews.js</b>) match with the blockchain configuration.</li>
      <li>The smart contract compiled JSON (file: <b>assets/UsersContract.json</b>) is updated.</li>
    </ul>
  </div>
</div>
</template>

<script>
// importing common function
import mixin from './libs/mixinViews';
import TopMenu from './components/TopMenu';

export default {
  components: {
    TopMenu
  },

  mixins: [mixin],
  //   controller: [controller],
  name: 'App',
  watch: {
    "$route": 'checkRegister'
  },
  data() {
    return {
      bcConnected: false, // true when the connection with the blockchain is established, plus the contract ABI + address is correctli initialized
      bcConnectionError: false,
      bcSmartContractAddressError: false
    }
  },
  created() {
    //   console.log("this.$store.userIsRegistered"+this.$store.userIsRegistered)
    this.checkRegister()
  },
  methods: {
    checkRegister() {
      this.tmoConn = setInterval(() => {
        if (this.blockchainIsConnected()) {
          clearInterval(this.tmoConn)
          window.bc.contract().isRegistered.call((error, res) => {
            if (error) {
              console.error(error);
            } else {
              if (res == false) //没有注册
              {
                this.$store.commit('setUnregister', false);
                console.log("unresgister")
                this.$router.push('/register')
              } else {
                // console.log("resgister")
                // this.$router.push('/')
                this.$store.commit('setUnregister', true);
                //获取用户名：
                this.getOwnProfile();
              }
            }
          })
        }
      }, 500)
    },
    getOwnProfile: function () {
      this.tmoReg = setInterval(() => {
        if (this.blockchainIsConnected()) {
          clearInterval(this.tmoReg)
          window.bc.contract().getOwnProfile.call((err, res) => {
            if (err)
              console.log(err)
            else {
              this.$store.commit('updateUserInfo', res)
              // console.log('username:' + res[1])
              // console.log('username store:' + this.$store.state.userInfo[1])
            }
          })
        }
      }, 500)
    }
  },
}
</script>

<style>
.time {
  font-size: 13px;
  color: #999;
}
</style>
