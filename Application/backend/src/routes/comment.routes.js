/**
 * 评论路由
 */
const express = require('express');
const router = express.Router();
const comments = require("../controllers/comment.controller.js");

// 创建评论
router.post("/", comments.create);

// 获取所有评论（分页）
router.get("/", comments.findAll);

// 获取单个评论
router.get("/:id", comments.findOne);

// 更新评论
router.put("/:id", comments.update);

// 删除评论
router.delete("/:id", comments.delete);

module.exports = router; 