<template>
<div class="header">
  <el-menu :default-active="$route.path" router class="el-menu-demo" mode="horizontal">
    <el-menu-item index="/">首页</el-menu-item>
    <el-menu-item index="/profile" exact>个人信息</el-menu-item>
    <el-menu-item index="/users" exact>用户列表</el-menu-item>
    <el-input type="text" placeholder="搜索一下" class='search' v-model="text"></el-input>
    <el-button plain @click="search">搜索</el-button>
    <li>
      <strong :class="connectedClass">
                    {{ bcConnected ? 'Connected' : 'Not Connected' }}
        </strong>
    </li>
  </el-menu>

</div>
</template>

<script>
// importing common function
import mixin from '../libs/mixinViews';

export default {
  mixins: [mixin],

  data() {
    return {
      tmoConn: null, // contain the intervalID given by setInterval
      tmoReg: null, // contain the intervalID given by setInterval
      connectedClass: 'text-danger', // bootstrap class for the connection status (red when not connected, green when connected)
      userIsRegistered: false, // true when the user that is visiting the page is registered
      text:"",
    }
  },

  methods: {
    /**
     * It checks if the visiting user is regitered calling every 500ms the function isRegistered
     * from the smart contract until the connection with the smart contract is established.
     */
    checkUserIsRegistered() {
      this.tmoConn = setInterval(() => {
        // checking first if the connection with the blockchain is established
        if (this.blockchainIsConnected()) {
          // stopping the setInterval
          clearInterval(this.tmoConn)
          // showing the connected message on the top bar and setting the class too
          this.connectedClass = 'text-success'

          window.bc.contract().isRegistered.call((error, res) => {
            if (error) {
              console.error(error);
            } else {
              this.userIsRegistered = res
              if (this.userIsRegistered == false) //没有注册
                this.$router.push('/register')
            }
          })
        }
      }, 500)
    },

    /**
     * Check if the user is registered calling the function of the smart contract isRegistered.
     * This function is used when the user is signing up.
     * The difference with the previous function is:
     *      - the function checkUserIsRegistered tries to check if the user is registered
     *        until the connection with the blockchain is established.
     *      - the function checkUntilUserIsRegistered tries to check if the user is registered
     *        until the user is registered.
     *
     * NOTE: in order to check if the user has been registered successfully the function has to check
     * several time because the block can take several minutes in order to be mined (depending on the
     * configuration of the blockchain you are using).
     */
    checkUntilUserIsRegistered() {
      this.tmoReg = setInterval(() => {
        if (this.blockchainIsConnected()) {
          window.bc.contract().isRegistered.call((error, res) => {
            if (error) {
              console.error(error)
            } else if (res) {
              // stopping the setInterval
              clearInterval(this.tmoReg)
              this.userIsRegistered = res
            }
          })
        }
      }, 1000)
    },
    search() {
      // this.$router.push({
      //   name: 'SearchResult',
      //   params: {
      //     text: this.text
      //   },
      //   hash: '#search'
      // })
      // this.text = ''
    }
  },

  created() {
    // when the event userregistered is fired (from the view Register.vue)
    // it runs the function checkUntilUserIsRegistered
    Event.$on('userregistered', this.checkUntilUserIsRegistered);

    this.checkUserIsRegistered()
  }
}
</script>

<style>
.search {
  margin-top: 0.68rem;
  margin-right: 0.625rem;
  margin-left: 150px;
  width: 200px !important;
}

.header {
  margin: auto;
  margin-bottom: 20px;
  width: 800px;
}

.search .icon-search {
  cursor: pointer;
  font-size: 1.875rem;
  color: #ffffff;
  position: absolute;
  right: 0.5rem;
  top: 0.2rem;
}
</style>
