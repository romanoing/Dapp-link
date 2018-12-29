# 简介
基于以太坊区块链简单的去中心化社交网络(`truffle+vue+web3.js`)。  
功能：注册账户、发表动态、评论动态、打赏、查看个人信息、查看用户等
## 结构
```
├─build
│  └─contracts  //合约编译结果
├─contracts //智能合约
├─front-end  //前端代码
│  ├─build
│  ├─config
│  ├─src 
│  │  ├─components  //vue 组件
│  │  ├─libs //自定义的库文件 
│  │  └─views  //显示的页面
│  └─static 
├─migrations //存放部署文件
├─ test //合约的测试文件
└─ truffle.js //配置文件目录
```
## 环境
```
windows 10 
Truffle v4.1.14 (core: 4.1.14)
Solidity v0.4.24 (solc-js)
node v8.4.0
npm 6.5.0
vue 2.8.2
```

## 运行
1. 运行 `ganache`


2. `truffle console --network ganache` 进入控制台  
注：如果要运行 `testrpc` 或其他私链，请在 `truffle.js` 进行配置，启动的时候 `truffle console -network` 你的私链名称  
3. 在控制台输入 `migrate --reset -complie-all`  
编译并部署合约到私链上：

4. 进入 `front-end` 目录，
- `npm install` 安装依赖
- `npm run dev` 运行

浏览器访问  `http://localhost:8080`
详细报告请查看 `/reports` 目录
