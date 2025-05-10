/**
 * 文物路由
 */
module.exports = app => {
    const artifacts = require("../controllers/artifact.controller.js");
    const router = require("express").Router();

    // 创建新文物
    router.post("/", artifacts.create);

    // 获取所有文物（带分页和筛选）
    router.get("/", artifacts.findAll);

    // 搜索文物
    router.get("/search", artifacts.search);

    // 获取单个文物详情
    router.get("/:id", artifacts.findOne);

    // 更新文物
    router.put("/:id", artifacts.update);

    // 删除文物
    router.delete("/:id", artifacts.delete);

    // 获取文物评论
    router.get("/:id/comments", artifacts.getComments);

    app.use('/api/artifacts', router);
}; 