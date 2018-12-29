<template>
<div id="sign-wrap">
  <h1>欢迎来到 link</h1>
  <div style="margin:auto auto; width:300px">
    <el-form :model="userForm" :rules="rules" ref="userForm" label-width="100px">
      <el-form-item label="用户名" prop="name">
        <el-input v-model="userForm.name" placeholder="请输入用户名"></el-input>
      </el-form-item>
      <el-form-item label="邮箱" prop="email">
        <el-input v-model="userForm.email" placeholder="请输入邮箱"></el-input>
      </el-form-item>
      <el-form-item label="电话号码" prop="telephone">
        <el-input v-model="userForm.telephone" placeholder="请输入电话"></el-input>
      </el-form-item>
      <el-form-item label="个性签名" prop="status">
        <el-input v-model="userForm.status" placeholder="请输入个性签名"></el-input>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" style="margin:auto auto;" @click="submitForm('userForm')">注册</el-button>
        <el-button @click="resetForm('userForm')">重置</el-button>
      </el-form-item>
    </el-form>
  </div>
</div>
</template>

<script>
export default {
  name: '',
  data() {
    return {
      userForm: {
        name: '',
        telephone: '',
        email: '',
        status:'',
      },
      rules: {
        name: [{
            required: true,
            message: '请输入用户名',
            trigger: 'blur'
          },
          {
            min: 6,
            max: 12,
            message: '长度在 6 到 12 个字符',
            trigger: 'blur'
          }
        ],
        telephone: [{
          required: true,
          message: '请输入电话号码',
          trigger: 'blur'
        }, {
          pattern: /^1(3|4|5|7|8)\d{9}$/,
          message: '请输入合法的电话号码',
          trigger: 'blur'
        }],
        email: [{
          required: true,
          message: '请输入邮箱',
          trigger: 'blur'
        }, {
          pattern: /^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$/,
          message: '请输入合法的邮箱',
          trigger: 'blur'
        }],
        status:[{
          required:true
        }]
      }
    }
  },
  created () {
    if (this.$store.state.userIsRegistered == true) {
      console.log('already reigster,go back to home')
      this.$router.push('/')
    }
  },
  // mounted: function () {
    
  // },
  methods: {
    submitForm: function (formName) {
      this.$refs[formName].validate((valid) => {
        if (valid) {
          this.signup();
        } else {
          this.$message.error('请输入合法的信息');
          return false;
        }
      });
    },
    signup: function () {
      let that = this;
      var event = window.bc.contract().newUserRegistered(function (error, id) {
        console.log("user id：" + id);
      });
      event.stopWatching();
      window.bc.contract().registerUser(that.userForm.name, that.userForm.status,that.userForm.email,that.userForm.telephone,{
        from: window.bc.web3().eth.coinbase,
        gas: 800000
      }, (err, id) => {
        console.log(id)
        if (err) {
          console.error(err)
          this.errorSubmit = true
          this.$message.error('注册失败')
        } else {
          that.$message({
            message: '注册成功',
            type: 'success'
          })
          this.$store.commit('setUnregister', true);
          this.$emit('getOwnProfile');
          this.$router.push('/')
        }
      })
    },
    resetForm(formName) {
      this.$refs[formName].resetFields();
    }
  }
}
</script>

<style>
#sign-wrap {
  /* width: 300px; */
  text-align: center;
  margin: 100px auto;
}

#sign-wrap h1 {
  color: #383a42;
  padding: 10px;
}

.signup-title {
  position: relative;
  left: 40px;
}

/*#sign-wrap div {
  padding-bottom: 20px;
}*/
</style>
