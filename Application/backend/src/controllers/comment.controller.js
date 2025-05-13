/**
 * 评论控制器
 */
const db = require("../models");
const { Comment, Post } = db;
const { Op } = require("sequelize");

// 创建评论
exports.create = async (req, res) => {
    try {
        console.log('创建评论请求数据:', req.body);
        
        // 验证请求数据
        if (!req.body.post_id || !req.body.content || !req.body.user_id) {
            return res.status(400).json({
                message: "评论内容和帖子ID不能为空"
            });
        }

        // 验证关联的帖子是否存在
        const post = await Post.findByPk(req.body.post_id);
        if (!post) {
            return res.status(404).json({
                message: `未找到ID为 ${req.body.post_id} 的帖子`
            });
        }

        // 创建评论
        const comment = await Comment.create({
            comment_id: req.body.comment_id,
            post_id: req.body.post_id,
            user_id: req.body.user_id,
            nickname: req.body.nickname,
            img_url: req.body.img_url,
            content: req.body.content,
            create_time: req.body.create_time,
            create_timestamp: req.body.create_timestamp
        });

        console.log('评论创建成功:', comment);

        // 状态码201表示资源创建成功
        res.status(201).json({
            message: "评论发布成功",
            data: comment
        });
    } catch (error) {
        console.error('评论创建失败:', error);
        res.status(500).json({
            message: "评论创建失败",
            error: error.message
        });
    }
};

// 获取评论列表
exports.findAll = async (req, res) => {
    try {
        const { post_id, page = 1, pageSize = 10 } = req.query;
        const offset = (page - 1) * pageSize;
        
        console.log('获取评论列表请求参数:', { post_id, page, pageSize, offset });

        // 构建查询条件
        const where = {};
        if (post_id) {
            where.post_id = post_id;
        }

        // 查询评论
        const { count, rows } = await Comment.findAndCountAll({
            where,
            limit: parseInt(pageSize),
            offset: parseInt(offset),
            order: [['create_timestamp', 'DESC']]
        });

        console.log('查询结果:', { count, rowsCount: rows.length });

        // 处理空结果
        if (count === 0) {
            return res.json({
                total: 0,
                currentPage: parseInt(page),
                pageSize: parseInt(pageSize),
                data: []
            });
        }

        res.json({
            total: count,
            currentPage: parseInt(page),
            pageSize: parseInt(pageSize),
            data: rows
        });
    } catch (error) {
        console.error('获取评论列表失败:', error);
        res.status(500).json({
            message: "获取评论列表失败",
            error: error.message
        });
    }
};

// 获取单个评论
exports.findOne = async (req, res) => {
    try {
        const comment = await Comment.findByPk(req.params.id);
        if (!comment) {
            return res.status(404).json({
                message: "未找到该评论"
            });
        }

        res.json(comment);
    } catch (error) {
        console.error('获取评论详情失败:', error);
        res.status(500).json({
            message: "获取评论详情失败",
            error: error.message
        });
    }
};

// 更新评论
exports.update = async (req, res) => {
    try {
        const comment = await Comment.findByPk(req.params.id);
        if (!comment) {
            return res.status(404).json({
                message: "未找到该评论"
            });
        }

        // 只允许更新评论内容
        await comment.update({
            content: req.body.content
        });

        res.json({
            message: "评论更新成功",
            data: comment
        });
    } catch (error) {
        console.error('更新评论失败:', error);
        res.status(500).json({
            message: "更新评论失败",
            error: error.message
        });
    }
};

// 删除评论
exports.delete = async (req, res) => {
    try {
        const comment = await Comment.findByPk(req.params.id);
        if (!comment) {
            return res.status(404).json({
                message: "未找到该评论"
            });
        }

        await comment.destroy();

        res.json({
            message: "评论删除成功"
        });
    } catch (error) {
        console.error('删除评论失败:', error);
        res.status(500).json({
            message: "删除评论失败",
            error: error.message
        });
    }
}; 