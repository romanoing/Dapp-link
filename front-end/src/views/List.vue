<template>
<div>
  <div class="clearfix"></div>
  <div class='list'>
    <el-row :gutter="20">
      <el-col :span="18" :offset="6">
        <el-table :data="users" :row-click=click-item style="margin:auto auto;">
          <el-table-column label="名字" sortable width="180">
            <template slot-scope="scope"><span style="margin-left: 0px">{{ scope.row[1] }}</span>
            </template>
          </el-table-column>
           <el-table-column label="个性签名" sortable width="180">
            <template slot-scope="scope"><span style="margin-left: 10px">{{ scope.row[4] }}</span>
            </template>
          </el-table-column>
          <el-table-column label="动态数" sortable width="180">
            <template slot-scope="scope"><span style="margin-left: 10px">{{ parseInt(scope.row[3]) }}</span>
            </template>
          </el-table-column>
           <el-table-column label="邮箱" sortable width="180">
            <template slot-scope="scope"><span style="margin-left: 0px">{{ scope.row[5] }}</span>
            </template>
          </el-table-column>
        </el-table>
      </el-col>
    </el-row>
  </div>
</div>
</template>

<script>
import mixin from '../libs/mixinViews';

export default {
  mixins: [mixin],

  data() {
    return {
      users: [], // array that stores all the registered users
      isLoading: true, // true when the user list is loading form the blockchain
      bcConnected: false, // blockchain is connected ()
      tmoConn: null, // contain the intervalID given by setInterval
    }
  },

  methods: {
    getUserList() {
      if (this.blockchainIsConnected()) {
        // it shows the loading message
        this.isLoading = true
        // stopping the interval
        clearInterval(this.tmoConn)
        // getting all the users from the blockchain
        this.getAllUsers(userProfile => {
          this.isLoading = false
          this.users.push(userProfile)
          console.log(userProfile)
        })

      }
    },

    reloadList() {
      this.users = []

      this.getUserList()
    },


    getAllUsers(callback) {
      window.bc.contract().getNumberOfAccounts.call((err, total) => {
        var tot = 0
        if (total) tot = total.toNumber()
        if (tot > 0) {
          for (var i = 1; i < tot + 1; i++) {
            window.bc.contract().getUserById.call(i, (error, userProfile) => {
              callback(userProfile)
            })
          }
        }
      })
    }
  },

  created() {
    this.tmoConn = setInterval(() => {
      this.getUserList()
    }, 1000)
  }
}
</script>

<style>
.btn-top {
  margin-top: 10px;
}

.list {
  margin: auto;
  text-align: center;
  /* width: 600px; */
}
</style>
