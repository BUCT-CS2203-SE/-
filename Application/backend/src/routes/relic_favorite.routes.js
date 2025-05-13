/**
 * 文物收藏路由
 */
const express = require("express");
const router = express.Router();
const relicFavorites = require("../controllers/relic_favorite.controller.js");

// 创建新收藏
router.post("/", relicFavorites.create);

// 获取文物收藏
router.get("/relic/:id", relicFavorites.getFavorites);

// 获取用户收藏
router.get("/user/:id", relicFavorites.getUserFavorites);

// 判断用户是否收藏某文物
router.get('/user/:userId/:relicId', relicFavorites.isFavorite);

// 取消收藏
router.delete("/:userId/:relicId", relicFavorites.delete);

module.exports = router; 