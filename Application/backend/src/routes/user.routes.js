/**
 * 用户路由
 */
module.exports = app => {
    const users = require("../controllers/user.controller.js");
    const router = require("express").Router();

    // 用户注册
    router.post("/register", users.register);

    // 用户登录
    router.post("/login", users.login);

    // 获取用户信息
    router.get("/:id", users.findOne);

    // 更新用户信息
    router.put("/:id", users.update);

    // 添加评论
    router.post("/comments", users.addComment);

    // 获取用户评论
    router.get("/:id/comments", users.getComments);

    // 添加收藏
    router.post("/favorites", users.addFavorite);

    // 取消收藏
    router.delete("/:userId/favorites/:artifactId", users.removeFavorite);

    // 获取用户收藏
    router.get("/:id/favorites", users.getFavorites);

    app.use('/api/users', router);
}; 