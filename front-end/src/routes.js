import Vue from 'vue'
import Router from 'vue-router'
import Profile from '@/views/Profile'
import List from '@/views/List'
import posts from '@/views/posts'
import Register from '@/views/Register'
import sidebar from '@/components/sidebar'
import setting from '@/views/setting'

Vue.use(Router)

export default new Router({
  routes: [{
      path: '/',
      name: 'home',
      components: {
        default: posts
      }
    },
    {
      path: '/profile',
      name: 'Profile',
      components: {
        default: Profile

      }
    },
    {
      path: '/register',
      name: 'Register',
      component: Register
    },
    {
      path: '/setting',
      name: 'setting',
      components: {
        default: setting
      }
    },
    {
      path: '/users',
      name: 'List',
      components: {
        default: List
      }
    },
    {
      path: '*',
      redirect: '/'
    }

  ],
  linkActiveClass: 'active'
})