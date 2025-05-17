/**
 * 用户路由
 */
const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');

// 用户注册
router.post('/register', userController.register);

// 用户登录
router.post('/login', userController.login);

// 获取用户信息
router.get('/:id', userController.findOne);

// 更新用户信息
router.put('/:id', userController.update);

// 添加评论
router.post('/comment', userController.addComment);

// 获取用户评论
router.get('/:id/comments', userController.getComments);

// 添加收藏
router.post('/favorite', userController.addFavorite);

// 取消收藏
router.delete('/favorite/:userId/:artifactId', userController.removeFavorite);

// 获取用户收藏
router.get('/:id/favorites', userController.getFavorites);

module.exports = router;
////ceshi////