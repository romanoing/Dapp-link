<template>
<div style="background:#f2f2f5; padding:10px;">
  <div id='comment'>
    <el-input style="margin-top:10px;" type="textarea" :autosize="{ minRows: 2, maxRows: 10}" placeholder="畅所欲言..." v-model="content" ref='inputRef'>
    </el-input>
    <el-row :gutter="20">
      <el-col :span="6" :offset="18">
        <el-button class='submit' plain size="small" @click="submit">发表</el-button>
      </el-col>
    </el-row>
  </div>
  <div class='comments-container'>
    <div style="margin:10px;" v-for='(comment) in comments' :key="comment[0].toNumber()" >
      <el-card v-if="comment[1].toNumber()==chosenPostId">
        <div>
          <el-row :gutter="20">
            <el-col :span="2">
              <div>{{ comment[3] }}:</div>
            </el-col>
            <el-col :span="13" :offset="3">
              <div>{{ comment[4] }}</div>
            </el-col>
          </el-row>
          <el-row :gutter="20">
            <el-col :span="9" :offset="0">
              <span class='time'>{{ comment[2] }}</span>
            </el-col>
          </el-row>
        </div>
      </el-card>
    </div>

  </div>
</div>
</template>

<script>
import mixin from '../libs/mixinViews';

import {
  focus
} from 'vue-focus';
export default {
  mixins: [mixin],
  data() {
    return {
      name: '',
      content: '',
      date: '',
      comments: [],
      loginUser: '',
      focused: false,
      editingId: '',
      tmoConn:null
    }
  },
  props: ['chosenPostId'],


  created () {
    this.loginUser = this.$store.state.userInfo[1];
    this.tmoConn= setInterval(() => {
      this.getCommentList();
    }, 500);
  },
  methods: {
    submit() {
      //更新评论
      console.log(this.editingId)
      let that = this
      this.getDate()
      window.bc.contract().sendComment(this.content, this.chosenPostId, this.date, this.$store.state.userInfo[1], {
        from: window.bc.web3().eth.coinbase,
        gas: 800000
      }, (err, hash) => {
        console.log("tx hash:" + hash)
        if (err) {
          console.error(err)
          this.$message.error('评论失败')
        } else {
          that.$message({
            message: '评论成功',
            type: 'success'
          })
          this.content = ''
          this.getCommentList();
        }
      })
    },
    getCommentList: function () {
      console.log('get comment');
      if (this.blockchainIsConnected()) {
        console.log('get blockchainIsConnected');
        clearInterval(this.tmoConn)
        this.comments = []
        this.getAllComment(comment => {
          this.isLoading = false
          if (comment != null)
            this.comments.push(comment)
          console.log(comment)
        })
      }
      //过滤
      this.comments = this.comments.filter(function (item, index, array) { //返回数组，filter函数获取满足条件的项
         console.log('comment post id'+item[1].toNumber())
        return item[1].toNumber() == this.chosenPostId;
      });
    },
    getAllComment: function (callback) {
      console.log('get getAllPost');
      window.bc.contract().getNumberOfComments.call((err, total) => {
        var tot = 0
        if (total) tot = total.toNumber()
        console.log('total comments: ' + total);
        if (tot > 0) {
          for (var i = tot; i >= 0; i--) {
            window.bc.contract().getCommentById.call(i, (error, comment) => {
              callback(comment)
            })
          }
        }
      })
    },

    reply(name) {
      this.content = '@' + name + ': '
      this.$refs.textBox.focus()
      this.$refs.inputRef.$el.children[0].focus();
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
    deleteComment: function (id) {
      let self = this
      this.$confirm('是否确定删除该评论?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        self.$http.post('/api/deleteComment', {
          _id: id
        }).then(
          response => {
            self.$message({
              type: 'success',
              message: '删除成功!'
            });
            self.fetchData()
          },
          response => {
            console.log(response)
          }
        )
      }).catch(() => {
        this.$message({
          type: 'info',
          message: '已取消删除'
        });
      });
    },
    editComment: function (id, index) {
      // console.log('id='+id)
      console.log(this.$router.path)
      this.content = this.comments[index].content
      this.$refs.inputRef.$el.children[0].focus();
      this.editingId = id
      // console.log('')
    },
    hideComment: function (id) {
    },
    displayComment: function (id) {
      this.$http.post('/api/admin/displayComment', {
        _id: id
      }).then(res => {
        this.$message({
          type: 'success',
          message: '显示成功'
        })
        this.fetchData()
      }, res => {
        console.log(res)
      })
    }
  }

}
</script>

<style>
.comments-container {
  border: 0;
  box-shadow: none;
  text-align: left;
}

.new-comment {
  text-align: left;
  padding: 30px;
}

.comment-instr {
  padding-bottom: 10px;
}

.comment-head {}

.comment-name {
  color: #66bfe7;
}

.comments-item {
  padding: 15px 20px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.09);
  margin:
}

.submit {
  outline: none;
  /* position: relative; */
  margin: 10px;
  float: right;
  align: right;
}

.nocomment {
  text-align: center;
  margin-bottom: 20px;
}

.summary {
  margin: 10px;
}

.comment-num {
  padding-left: 20px;
}

.hiddenHint {
  margin-left: 10px;
  color: #9e9e9e;
}
</style>
