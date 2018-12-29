<template>
<div id='content' style="margin-top:20px;">
  <el-row style="margin:auto auto;">
    <el-col>
      <el-input label="李家俊是傻逼" type="textarea" style="width: 50%;margin:auto auto;" :autosize="{ minRows: 3, maxRows: 4}" placeholder="分享你的新鲜事" v-model="content" ref='inputRef'>
      </el-input>
    </el-col>
  </el-row>
  <el-row :gutter="20">
    <el-col :span="6" :offset="14">
      <el-button style="margin:10px;" icon='el-icon-news' @click="sendPost">发布</el-button>
    </el-col>
  </el-row>
  <div v-for="(item,index) in postList" :key='item[0].toNumber()'>
    <el-card class="box-card" shadow="always">
      <el-row :gutter="20">
        <el-col :span="3" :offset="0">
          <span class='author'> {{item[3]}}</span>
        </el-col>
      </el-row>
      <div>
        <div>{{ item[2] }}</div>
      </div>
      <el-row :gutter="20">
        <el-col :span="9" :offset="16">
          <i class="el-icon-time"></i>
          <span class='time'>{{ item[1] }}</span>
        </el-col>
      </el-row>
      <el-row :gutter="20">
        <el-col :span="8">
          <el-button type="text" @click="contribution(index)">打赏</el-button>
          <el-dialog title="打赏" :visible.sync="dialogFormVisible">
            <div style="margin-bottom:10px;">作者名称：{{author_name}}</div>
            <div style="margin-bottom:10px;">作者地址：{{author_addr}}</div>
            <div style="margin-bottom:10px;">你的余额：{{balance}} ETH</div>
            <el-input autocomplete="off" v-model="value" placeholder="请输入金额"></el-input>
            <div slot="footer" class="dialog-footer">
              <el-button @click="dialogFormVisible = false">取 消</el-button>
              <el-button type="primary" @click="sendCoin(value,author_addr)">确 定</el-button>
            </div>
          </el-dialog>
        </el-col>

        <el-col :span="8">
          <el-button icon='el-icon-news' @click="showComment(index)" type='text'>评论</el-button>
        </el-col>
        <el-col :span="6">
          <el-button icon="el-icon-star-off" type='text'>点赞</el-button>
        </el-col>
      </el-row>
      <post-comment v-bind:chosen-post-id="item[0].toNumber()" v-show="isCommentShow[index]"></post-comment>
    </el-card>
  </div>
  <!-- </paginate>    -->
  <!-- <div class="el-pagination">
    <paginate-links for="posts" :limit="2" :show-step-links="true"></paginate-links>
  </div> -->
</div>
</template>

<script>
import postComment from './postComment'
import mixin from '../libs/mixinViews';

export default {
  name: 'posts',
  mixins: [mixin],
  data() {
    return {
      postList: [],
      paginate: ['posts'],
      isCommentShow: [],
      ishowcomment: false,
      content: '',
      date: '',
      isLoading: true,
      tmoConn: null,
      dialogFormVisible: false,
      value: 0,
      author_addr: '',
      author_name: '',
      balance: 0
    }
  },

  mounted: function () {},
  created() {
    this.tmoConn = setInterval(() => {
      this.getPostList();
    }, 500)
  },
  methods: {
    showComment: function (index) {
      if (typeof this.isCommentShow[index] != 'undefined' && this.isCommentShow[index] == true) {
        this.isCommentShow[index] = false;
        this.$set(this.isCommentShow, index, false)
      } else {
        this.$set(this.isCommentShow, index, true)
        console.log("is show comment index: " + index + this.isCommentShow[index]);
      }
    },
    sendPost: function () {
      let that = this
      this.getDate();
      window.bc.contract().sendPost(this.content, this.date, this.$store.state.userInfo[1], {
        from: window.bc.web3().eth.coinbase,
        gas: 800000
      }, (err, id) => {
        console.log(id)
        if (err) {
          console.error(err)
          this.errorSubmit = true
          this.$message.error('发表失败')
        } else {
          that.$message({
            message: '发表成功',
            type: 'success'
          })
          this.content = ''
          this.tmoConn = setInterval(() => {
            this.getPostList();
          }, 500)
        }
      })

    },
    getDate: function () {
      let mydate, y, m, d, hh, mm, ss;
      mydate = new Date()
      y = mydate.getFullYear()
      m = mydate.getMonth() + 1
      d = mydate.getDate()
      hh = mydate.getHours()
      mm = mydate.getMinutes()
      ss = mydate.getSeconds()
      if (m < 10) m = '0' + m
      if (d < 10) d = '0' + d
      if (hh < 10) hh = '0' + hh
      if (mm < 10) mm = '0' + mm
      if (ss < 10) ss = '0' + ss
      this.date = y + '-' + m + '-' + d + ' ' + hh + ':' + mm + ':' + ss
    },
    getPostList: function () {
      console.log('get post');
      if (this.blockchainIsConnected()) {
        console.log('get blockchainIsConnected');
        this.isLoading = true
        clearInterval(this.tmoConn)
        this.postList = []
        this.getAllPost(post => {
          this.isLoading = false
          if (post != null)
            this.postList.push(post)
          console.log(post)
        })
      }
      // this.postList = this.postList.reverse();
    },
    getAllPost: function (callback) {
      console.log('get getAllPost');
      window.bc.contract().getNumberOfPosts.call((err, total) => {
        var tot = 0
        if (total) tot = total.toNumber()
        console.log('total post: ' + total);
        if (tot > 0) {
          // getting the user one by one
          for (var i = tot; i >= 0; i--) {
            window.bc.contract().getPostById.call(i, (error, post) => {
              callback(post)
            })
          }
        }
      })
    },
    contribution: function (index) {
      this.dialogFormVisible = true
      this.author_name = this.postList[index][3];
      this.author_addr = ''
      window.bc.loadInfo().then(info => {
        this.balance = window.bc.weiToEther(info.balance)
      })
      window.bc.contract().getNameOfAddress.call(this.author_name, (err, addr) => {
        if (err)
          console.log(err)
        else
          this.author_addr = addr;
      })

    },
    sendCoin: function (val, addr) {
      let that = this
      console.log(val)
      console.log(addr)
      this.dialogFormVisible = false;
      window.bc.web3().eth.sendTransaction({
        from: window.bc.web3().eth.coinbase,
        to: addr,
        value: web3.toWei(val, 'ether')
      }, function (err, tx) {
        console.log(tx)
        if (err)
          console.log(err)
        else {
          that.$message({
            message: '打赏成功',
            type: 'success'
          })
        }
      })
    }

  },
  components: {
    postComment
  }
}
</script>

<style>
.author-card {
  width: 100px;
  padding: 0px;
}

.box-card {
  margin: auto;
  margin-bottom: 10px;
  margin-top: 10px;
  width: 600px;
}

.time {
  font-size: 13px;
  color: #999;
}

.author {
  color: #909399;
  padding: 0px;
}

#content {
  margin-left: auto;
  margin-right: auto;
  text-align: center;

}

ul {
  list-style-type: none;
  padding: 0;
}

.el-card__body {
  padding-bottom: 10px;
}

li {
  display: inline-block;
  border-radius: 2px;
}

/*分页样式*/

.el-pagination {
  margin-bottom: 20px;
}

.number {
  font-size: 12px;
  line-height: 22px;
  height: 22px;
  min-width: 22px;
}

.left-arrow {
  margin-right: 8px;
}

.right-arrow {
  margin-left: 8px;
}

.active {
  border-color: #20a0ff;
  background-color: #20a0ff;
  color: #fff;
  cursor: default;
}

.disabled {
  color: #e4e4e4;
  background-color: #fff;
  cursor: not-allowed;
}

.hidden {
  margin-top: 50px;
}
</style>
