/**
 * 文物评论路由
 */
const express = require("express");
const router = express.Router();
const relicComments = require("../controllers/relic_comment.controller.js");

// 创建新评论
router.post("/", relicComments.create);

// 获取文物评论
router.get("/relic/:id", relicComments.getComments);

// 获取用户评论
router.get("/user/:id", relicComments.getUserComments);

// 删除评论
router.delete("/:id", relicComments.delete);

module.exports = router; 