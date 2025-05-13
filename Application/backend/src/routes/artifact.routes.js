/**
 * 文物路由
 */
const express = require('express');
const router = express.Router();
const artifacts = require("../controllers/artifact.controller.js");

// 创建新文物
router.post("/", artifacts.create);

// 获取所有文物（带分页和筛选）
router.get("/", artifacts.findAll);

// 获取所有文物（不分页）
router.get("/all", artifacts.getAll);

// 获取单个文物详情
router.get("/:id", artifacts.findOne);

// 更新文物
router.put("/:id", artifacts.update);

// 删除文物
router.delete("/:id", artifacts.delete);

// 获取文物评论
router.get("/:id/comments", artifacts.getComments);

// 获取文物图片
router.get("/:id/photos", artifacts.getPhotos);

// 添加文物图片
router.post("/:id/photos", artifacts.addPhoto);

// 删除文物图片
router.delete("/photos/:photoId", artifacts.deletePhoto);

module.exports = router; 