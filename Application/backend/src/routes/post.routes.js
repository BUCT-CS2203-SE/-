/**
 * 帖子路由
 */
const express = require('express');
const router = express.Router();
const posts = require("../controllers/post.controller.js");

// 创建帖子
router.post("/", posts.create);

// 获取所有帖子（分页）
router.get("/", posts.findAll);

// 获取所有帖子（不分页）
router.get("/all", posts.getAll);

// 获取单个帖子
router.get("/:id", posts.findOne);

// 更新帖子
router.put("/:id", posts.update);

// 删除帖子
router.delete("/:id", posts.delete);

// 获取帖子评论
router.get("/:id/comments", posts.getComments);

// 更新帖子点赞数
router.put("/:id/likes", posts.updateLikes);

// 取消点赞
router.put("/:id/unlike", posts.unlike);

// 更新收藏状态
router.put("/:id/favorite", posts.updateFavorite);

// 取消收藏
router.put("/:id/unfavorite", posts.unfavorite);

module.exports = router; 