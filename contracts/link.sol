pragma solidity ^0.4.10;
pragma experimental ABIEncoderV2;
import "./StringUtils.sol";
contract link {
  using StringUtils for *;
  //状态的结构
  struct Post{
    uint postId;
    string date;
    string content;
    string author;
    uint likeNumber;//点赞数
    mapping(uint=>address) likeAddress;//点赞的用户地址
    // Comment[] comments;
    mapping (uint=>Comment) comments;
    uint commentSize;
  }

  struct Comment{ //评论
    uint commentId;
    uint postId;
    string date; 
    string author;
    string content;    
  }

  struct User{
    address addr;
    string name;
    uint postNumber;
    string status;
    string telephone;
    string email;
    mapping(uint=>Post)userPosts;
  }

  User[] public users; //用户
  Post[] public posts;//评论
  Comment[] public comments;
  uint commentCounter = 0;
  uint postCounter = 0;

  address admin;
  mapping (address => uint) public usersIds;
  event CoinTransfer(address sender, address receiver, uint amount);
  constructor() public {
    addUser(0x0, "name","status","telephone","email"); //第一个账户为空
    admin = msg.sender;
  }

  modifier onlyOwner(){
    if(msg.sender!=admin){
      revert("require admin");
    }
    _;
  }

  event newUserRegistered(uint id);
  modifier checkSenderIsRegistered {
    	require(isRegistered());
    	_;
  }



  function isRegistered() public view returns (bool)
  {
    return (usersIds[msg.sender] != 0);
  }
  //注册账户
  function registerUser(string _name,string _status,string _email,string _telephone) public returns (uint){
    uint userId = usersIds[msg.sender];
    require (userId == 0,"already exits");
    usersIds[msg.sender] = users.length;
    uint newUserId = users.length++;
    users[newUserId] = User({addr:msg.sender,name:_name,postNumber:0,status:_status,email:_email,telephone:_telephone});
    emit newUserRegistered(newUserId);
    return newUserId;
  }
  //点赞文章
  function likePost(uint postId) public {
    posts[postId].likeAddress[posts[postId].likeNumber] = msg.sender; 
    ++posts[postId].likeNumber; //增加点赞数
  }

  //发表动态
  function sendPost(string _content,string _date,string _author) public {
    require(bytes(_content).length <= 200,"content is too long"); //动态长度限制
    for(uint p = 0; p < users.length; p++){
      if(users[p].addr == msg.sender){
        Post memory postTmp = Post({
          postId: getPostID(),
          date: _date,
          content:_content,
          author:_author,
          likeNumber: 0,
          commentSize:0
          }
        );
        users[p].userPosts[users[p].postNumber] = postTmp;
        users[p].postNumber++;
        posts.push(postTmp);
      }
    }
  }



  function addUser(address _wAddr, string _userName,string _status,string _telephone,string _email) private  returns(uint){
    uint userId = usersIds[msg.sender];
    require (userId == 0,"already exits");
    usersIds[msg.sender] = users.length;
    uint newUserId = users.length++;
    users[newUserId] = User({addr:msg.sender,name:_userName,status:_status,telephone:_telephone,email:_email,postNumber:0});
    emit newUserRegistered(newUserId);
    return newUserId;
  }


  //评论动态
  function sendComment(string content,uint postId,string date,string author) public returns(uint) {  
    uint commentId = comments.length++;
    // uint commentIdInPost = posts[postId].commentSize++;
    //连续赋值 不确定行不行...
    comments[commentId] = Comment(getCommentID(),postId,date,author,content);
    return commentId;
    // posts[postId].comments[commentIdInPost] = comments[commentId] = Comment(getCommentID(),postId,date,author,content);
    // Comment memory commentTmp = Comment(getCommentID(),postId,now,msg.sender,content);
    // comments.push(commentTmp);
  }

 //打赏用户
  function sendCoin(address receiver) public payable returns(bool sufficient){
    receiver.transfer(msg.value);
    return true;
  }

  //设置名字
  function setName(string _name) public{
    for (uint i = 0; i < users.length; i++) {
      if(users[i].addr == msg.sender)
        users[i].name = _name;
    } 
  }
  //根据文章 id 查询文章内容
  function getPostContentById(uint postId) public view returns (string content){
    content = posts[postId].content;
  }

//根据用户id,文章发表顺序查询文章内容
  function getPostContentByuserIdAndPostId(uint userId,uint postId) public view returns (string content){
    content = users[userId].userPosts[postId].content;
  }

  //根据文章 id 和 评论id 信息
  function getCommentBypostIdAndCommentId(uint postId,uint commentId)public view returns (string content){
    content = posts[postId].comments[commentId].content;
  }

  function getCommentByCommentId(uint id) public view returns (string){
    return comments[id].content;
  }

  //获取文章的评论数目和点赞数目 
  function getCommentAndLikeNumberByPostId(uint postId) public view returns(uint commentSize,uint likeSize) {
    commentSize = posts[postId].commentSize;
    likeSize = posts[postId].likeNumber;
  }


  //根据名称获取账户地址
  function getNameOfAddress(string name) public view returns (address addr) {
    addr = 0;
    for (uint i = 0; i < users.length; i++) {
      if(StringUtils.equal(users[i].name,name))
        addr = users[i].addr;
    }
  }

  //根据地址获取账户名称
  function getAddressOfName(address addr) public view returns(string name){
    name = "user not exist";
    for (uint i = 0; i < users.length; i++) {
      if(users[i].addr==addr)
        name = users[i].name;
    }
    return name;
  }

  //获取账户数量
  function getNumberOfAccounts() public view returns (uint count) {
    count = users.length;
  }

  //获取评论数量
    //获取账户数量
  function getNumberOfPosts() public view returns (uint count) {
    count = posts.length;
  }
  function getNumberOfComments() public view returns (uint count) {
    count = comments.length;
  }

  //点赞
  function getPostID() private returns(uint) { return ++postCounter; }

  function getCommentID()private returns(uint){return ++commentCounter;}

  //根据用户id获取用户信息 
  function getUserById(uint _id) public view
    returns(
    	uint,
    	string,
    	address,
    	uint,
      string,
      string,
      string
    ) {
    	// checking if the ID is valid
    require((_id > 0) || (_id <= users.length),"user id don't exist");
    User memory i = users[_id];
    return (
      _id,
      i.name,
      i.addr,
      i.postNumber,
      i.status,
      i.email,
      i.telephone
    );
  }

  function getOwnProfile()  public view checkSenderIsRegistered
    returns(
    	uint,
    	string,
    	address,
    	uint,
      string,
      string,
      string
    ) {
    uint id = usersIds[msg.sender];
    return getUserById(id);
  }
  function getPostById(uint _id) public view
    returns(
    	uint,
    	string,
    	string,
      string,
    	uint,
      uint
    ) {
    	// checking if the ID is valid
    require((_id >= 0) || (_id <= posts.length),"post id don't exist");
    Post memory i = posts[_id];
    return (
      _id,
      i.date,
      i.content,
      i.author,
      i.likeNumber,
      i.commentSize
    );
  }

  function getCommentById(uint _id) public view returns( uint,
    uint,
    string,
    string,
    string
    ){
    require((_id > 0) || (_id <= comments.length),"comment id don't exist");
    Comment memory c = comments[_id];
    return (
     _id,
     c.postId,
     c.date,
     c.author,
     c.content
    );
  }
}


