<template>
<div style="margin:auto auto;">
  <el-card class="box-card" style="width:600px; margin:auto auto;">
    <div slot="header" class="clearfix">
      <span>我的信息</span>
      <!-- <el-button style="float: right; padding: 3px 0" type="text">修改信息</el-button> -->
    </div>
    <div class="text item">姓名: {{ userName }}</div>
    <div class="text item">个性签名: {{ status }}</div>
    <div class="text item">地址: {{ coinbase }}</div>
    <div class="text item">余额: {{ balance }} ETH</div>
    <div class="text item">动态数量: {{ postNumber }}</div>
    <div class="text item">电话号码: {{ telephone }}</div>
    <div class="text item">邮箱: {{ email }}</div>
  </el-card>

</div>
</template>

<script>
import mixin from '../libs/mixinViews';

export default {
  mixins: [mixin],
  data() {
    return {
      userName: '', // variable binded with the name's input field
      postNumber: 0, // varialbe binded to the status's input filed
      coinbase: '0x0', // address of the user
      balance: 0, // balance of the user
      status:"",
      telephone:"",
      email:"",
      tmoConn: null, // contain the intervalID given by setInterval

      submitting: false, // true when the submit is pressed
      successSave: false, // it show the success message
      errorSubmit: false, // it shows the erro message
    }
  },


  methods: {
    getProfile() {
      window.bc.contract().getOwnProfile((error, userDet) => {
        this.userName = userDet[1]
        this.postNumber = userDet[3].toNumber()
        this.status = userDet[4]
        this.email = userDet[5]
        this.telephone = userDet[6]
      })
    },

    /**
     * Updates the user's details when the button is pressed.
     */
    performSubmit() {
      this.submitting = true
      this.errorSubmit = false;
      this.successSave = false;

      // calling the method updateUser from the smart contract
      window.bc.contract().updateUser(
        this.userName,
        this.userStatus, {
          from: window.bc.web3().eth.coinbase,
          gas: 800000
        },
        (err, txHash) => {
          this.handleSubmitResult(err, txHash)
        }
      )
    },

    /**
     * Handle the result of the response of updateUser.
     */
    handleSubmitResult(err, txHash) {
      this.submitting = false
      if (err) {
        console.error(err)
        this.errorSubmit = true;
      } else if (txHash) {
        this.errorSubmit = false;
        this.successSave = true;
      }
    },

    /**
     * It loads the general info (address and balance of the user).
     */
    getInfoBc() {
      window.bc.loadInfo().then(info => {
        this.coinbase = info.coinbase
        this.balance = window.bc.weiToEther(info.balance)
      })
    },

    /**
     * It loads the user information once connected to the blockchian
     */
    checkConnectionAndLoad() {
      if (this.blockchainIsConnected()) {
        // stopping the interval
        clearInterval(this.tmoConn)
        this.loadEverything()
      }
    },

    /**
     * Load the user's info: user name, status and general info
     */
    loadEverything() {
      // checking if the user is registered
      window.bc.contract().isRegistered.call((error, res) => {
        if (error) {
          console.error(error)
          this.$router.push("/register")
        }
        // if the user is registered it will load the profile page
        else if (res) {
          this.getProfile()
          this.getInfoBc()
        }

        // if the user not registered the user will be redirected to the Register page
        else this.$router.push("/register")
      })
    }
  },

  created() {
    // it will call the function checkConnectionAndLoad every 500ms
    // until the connection to the blockchain is enstablished
    this.tmoConn = setInterval(() => {
      this.checkConnectionAndLoad()
    }, 500)
  }
}
</script>

<style>

  .text {
    font-size: 14px;
  }

  .item {
    margin-bottom: 18px;
  }

</style>
