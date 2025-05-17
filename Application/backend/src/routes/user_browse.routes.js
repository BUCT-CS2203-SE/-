/**
 * 用户浏览历史路由
 */
const express = require('express');
const router = express.Router();
const userBrowses = require("../controllers/user_browse.controller.js");

// 添加浏览记录
router.post("/", userBrowses.create);

// 获取用户的最近浏览记录
router.get("/user/:id/recent", userBrowses.getRecentBrowses);

// 获取用户的浏览历史
router.get("/user/:id", userBrowses.getUserBrowses);

// 获取文物的浏览记录
router.get("/relic/:id", userBrowses.getRelicBrowses);

// 清空用户的浏览历史
router.delete("/user/:id", userBrowses.clearUserBrowses);

// 删除单条浏览记录
router.delete("/:id", userBrowses.delete);

module.exports = router; 